package com.chf.bbcms.bootstrap;

import com.chf.bbcms.authentication.application.port.out.PasswordHasher;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.event.EventListener;
import org.springframework.core.annotation.Order;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Seed idempotent de données fictives au démarrage (dev / staging) pour
 * permettre une démonstration immédiate du frontend.
 *
 * Ne s'exécute QUE si :
 *   - bbcms.bootstrap.dev-data.enabled = true (default), ET
 *   - aucun Bible Club n'existe en base (premier démarrage).
 *
 * Crée :
 *   - 3 Bible Clubs (UNIKIN, UPC, ULUB) avec leurs niveaux L1..L4
 *   - ~30 comptes utilisateurs (étudiants ACTIVE, 1 leader BBC par club,
 *     1 leader national supplémentaire, 2 professionnels)
 *   - ~20 réunions (mix RECORDED / PLANNED) sur les 8 dernières semaines
 *   - Scores de participation cohérents pour quelques étudiants fidèles
 *   - 1 verset du jour + 2 annonces spéciales
 *   - 1 chaîne de prière active
 *   - 1 programme d'évangélisation actif
 *   - 1 contribution financière en cours
 *
 * Tous les comptes seed utilisent {@link DevDataProperties#getDefaultPassword()}.
 * Le seed s'exécute APRÈS le SuperAdminBootstrap (Order=20).
 */
@Component
@Order(20)
@EnableConfigurationProperties(DevDataProperties.class)
public class DevDataSeeder {

    private static final Logger log = LoggerFactory.getLogger(DevDataSeeder.class);
    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");

    // Rôles seedés par 17-seed-roles.xml (UUID stables)
    private static final UUID ROLE_NATIONAL_LEADER = UUID.fromString("11111111-0000-0000-0000-000000000002");
    private static final UUID ROLE_BBC_LEADER     = UUID.fromString("11111111-0000-0000-0000-000000000003");
    private static final UUID ROLE_STUDENT        = UUID.fromString("11111111-0000-0000-0000-00000000000B");
    private static final UUID ROLE_PROFESSIONAL   = UUID.fromString("11111111-0000-0000-0000-00000000000C");

    private final DevDataProperties props;
    private final DatabaseClient db;
    private final PasswordHasher hasher;

    public DevDataSeeder(DevDataProperties props, DatabaseClient db, PasswordHasher hasher) {
        this.props = props;
        this.db = db;
        this.hasher = hasher;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onReady() {
        if (!props.isEnabled()) {
            log.info("Dev data seed disabled (bbcms.bootstrap.dev-data.enabled=false)");
            return;
        }
        // Le seed s'exécute après le SuperAdmin (qui est en ordre par défaut). On laisse
        // quelques secondes de marge en redémarrant l'écoulement de manière différée.
        Mono.defer(this::seedIfEmpty)
                .doOnError(ex -> log.error("Dev data seed failed: {}", ex.getMessage(), ex))
                .subscribe();
    }

    private Mono<Void> seedIfEmpty() {
        return db.sql("SELECT COUNT(*) AS n FROM bbcms_bible_club")
                .map((row, m) -> row.get("n", Long.class))
                .one()
                .defaultIfEmpty(0L)
                .flatMap(count -> {
                    if (count != null && count > 0) {
                        log.info("Dev data seed skipped — {} Bible Club(s) already in DB", count);
                        return Mono.empty();
                    }
                    log.info("🌱 Seeding dev data (Bible Clubs, members, meetings, …)");
                    return doSeed();
                });
    }

    private Mono<Void> doSeed() {
        return hasher.hash(props.getDefaultPassword())
                .flatMap(this::seedAll);
    }

    private Mono<Void> seedAll(String passwordHash) {
        return seedBibleClubs()
                .then(seedLevels())
                .then(seedUsersAndMembers(passwordHash))
                .then(seedMeetings())
                .then(seedAttendanceScores())
                .then(seedPublications())
                .then(seedPrayerChain())
                .then(seedEvangelism())
                .then(seedContribution())
                .then(seedEvent())
                .doOnSuccess(v -> log.info("✅ Dev data seed completed"));
    }

    // ─────────────────────────────────────────────────────────────────────
    //  BIBLE CLUBS
    // ─────────────────────────────────────────────────────────────────────

    private static final UUID BBC_UNIKIN = UUID.fromString("22222222-0000-0000-0000-000000000001");
    private static final UUID BBC_UPC    = UUID.fromString("22222222-0000-0000-0000-000000000002");
    private static final UUID BBC_ULUB   = UUID.fromString("22222222-0000-0000-0000-000000000003");

    private Mono<Void> seedBibleClubs() {
        return insertBbc(BBC_UNIKIN, "BBC · UNIKIN", "Université de Kinshasa", 150)
                .then(insertBbc(BBC_UPC, "BBC · UPC", "Université Protestante au Congo", 120))
                .then(insertBbc(BBC_ULUB, "BBC · ULUB", "Université Libre de Bruxelles", 100));
    }

    private Mono<Void> insertBbc(UUID id, String name, String school, int goal) {
        return db.sql("""
                INSERT INTO bbcms_bible_club (id, name, school_name, goal_nb_faithful, date_created,
                    status, created_by, updated_by)
                VALUES (:id, :name, :school, :goal, :dc, 'ACTIVE', :sys, :sys)
                """)
                .bind("id", id).bind("name", name).bind("school", school).bind("goal", goal)
                .bind("dc", LocalDate.now().minusYears(2)).bind("sys", SYSTEM)
                .then();
    }

    // ─────────────────────────────────────────────────────────────────────
    //  LEVELS — L1..L4 par BBC
    // ─────────────────────────────────────────────────────────────────────

    // UUID stables (BBC_ix-LEVEL_ix) — préfixe 33333333
    private UUID levelId(int bbcIdx, int level) {
        // construire un UUID stable: 33333333-bbcIdx-level-...
        return UUID.fromString("33333333-0000-000%d-000%d-000000000000".formatted(bbcIdx, level));
    }

    private Mono<Void> seedLevels() {
        Mono<Void> chain = Mono.empty();
        UUID[] bbcs = { BBC_UNIKIN, BBC_UPC, BBC_ULUB };
        String[] labels = { "L1 · Initiation", "L2 · Affermissement", "L3 · Engagement", "L4 · Service" };
        for (int i = 0; i < bbcs.length; i++) {
            for (int j = 0; j < labels.length; j++) {
                chain = chain.then(insertLevel(levelId(i + 1, j + 1), bbcs[i], labels[j], "L" + (j + 1)));
            }
        }
        return chain;
    }

    private Mono<Void> insertLevel(UUID id, UUID bbcId, String name, String type) {
        return db.sql("""
                INSERT INTO bbcms_level (id, bible_club_id, name, type, created_by, updated_by)
                VALUES (:id, :bbc, :name, :type, :sys, :sys)
                """)
                .bind("id", id).bind("bbc", bbcId).bind("name", name).bind("type", type)
                .bind("sys", SYSTEM)
                .then();
    }

    // ─────────────────────────────────────────────────────────────────────
    //  USERS + MEMBERS (étudiants, professionnels, leaders nationaux)
    // ─────────────────────────────────────────────────────────────────────

    // Étudiants — emails et noms fictifs, alternance gender/level
    private static final String[][] STUDENTS = {
            // {email, first, next, gender, bbcIdx, level}
            {"marie.lukombo@chf.org",       "Marie",   "Lukombo",     "FEMALE", "1", "3"},
            {"jean.kabongo@chf.org",        "Jean",    "Kabongo",     "MALE",   "1", "3"},
            {"patricia.mukendi@chf.org",    "Patricia","Mukendi",     "FEMALE", "1", "2"},
            {"daniel.tshisekedi@chf.org",   "Daniel",  "Tshisekedi",  "MALE",   "1", "3"},
            {"esther.lumbu@chf.org",        "Esther",  "Lumbu",       "FEMALE", "1", "1"},
            {"patrice.diur@chf.org",        "Patrice", "Diur",        "MALE",   "1", "2"},
            {"anne.mwenze@chf.org",         "Anne",    "Mwenze",      "FEMALE", "1", "1"},
            {"joseph.tshiala@chf.org",      "Joseph",  "Tshiala",     "MALE",   "1", "4"},
            {"daniella.kabamba@chf.org",    "Daniella","Kabamba",     "FEMALE", "1", "2"},
            {"aime.bokondji@chf.org",       "Aimé",    "Bokondji",    "MALE",   "1", "1"},

            {"mireille.diur@chf.org",       "Mireille","Diur",        "FEMALE", "2", "2"},
            {"emmanuel.kasanda@chf.org",    "Emmanuel","Kasanda",     "MALE",   "2", "3"},
            {"ruth.mbala@chf.org",          "Ruth",    "Mbala",       "FEMALE", "2", "1"},
            {"david.kabasele@chf.org",      "David",   "Kabasele",    "MALE",   "2", "2"},

            {"sarah.kimba@chf.org",         "Sarah",   "Kimba",       "FEMALE", "3", "1"},
            {"isaac.mwamba@chf.org",        "Isaac",   "Mwamba",      "MALE",   "3", "2"},
    };

    // Leaders BBC (rôle BBC_LEADER) — 1 par BBC, sont aussi étudiants L4
    private static final String[][] BBC_LEADERS = {
            {"president.unikin@chf.org",    "Joshua",  "Ekanga",      "MALE", "1", "4"},
            {"president.upc@chf.org",       "Rebecca", "Lutete",      "FEMALE","2","4"},
            {"president.ulub@chf.org",      "Caleb",   "Tshibanda",   "MALE", "3", "4"},
    };

    // Professionnels & mentors (sans BBC)
    private static final String[][] PROFESSIONALS = {
            {"mentor.mwamba@chf.org",       "Joseph",  "Mwamba",      "MALE",   "Pasteur",       "MENTOR"},
            {"pro.kongolo@chf.org",         "Daniel",  "Kongolo",     "MALE",   "Ingénieur",     "SIMPLE_PROFESSIONAL"},
    };

    private Mono<Void> seedUsersAndMembers(String passwordHash) {
        Mono<Void> chain = Mono.empty();
        for (String[] s : STUDENTS) {
            chain = chain.then(insertStudent(passwordHash, s[0], s[1], s[2], s[3],
                    Integer.parseInt(s[4]), Integer.parseInt(s[5])));
        }
        for (String[] l : BBC_LEADERS) {
            chain = chain.then(insertBbcLeader(passwordHash, l[0], l[1], l[2], l[3],
                    Integer.parseInt(l[4]), Integer.parseInt(l[5])));
        }
        for (String[] p : PROFESSIONALS) {
            chain = chain.then(insertProfessional(passwordHash, p[0], p[1], p[2], p[3], p[4], p[5]));
        }
        return chain;
    }

    private Mono<Void> insertStudent(String pwHash, String email, String first, String next,
                                     String gender, int bbcIdx, int level) {
        UUID userId = UUID.randomUUID();
        UUID memberId = UUID.randomUUID();
        UUID bbcId = bbcIdx == 1 ? BBC_UNIKIN : bbcIdx == 2 ? BBC_UPC : BBC_ULUB;
        UUID lvl = levelId(bbcIdx, level);
        // score entre 8 et 26, fidélité entre 40 et 95
        int score = 8 + (Math.abs(email.hashCode()) % 19);
        int totalElig = 26;
        BigDecimal pct = BigDecimal.valueOf((score * 100.0) / totalElig).setScale(2, java.math.RoundingMode.HALF_UP);

        return insertUser(userId, email, pwHash, first, next, gender, "STUDENT")
                .then(insertMember(memberId, userId, "STUDENT", bbcId, lvl, score, pct))
                .then(assignRole(userId, ROLE_STUDENT, bbcId));
    }

    private Mono<Void> insertBbcLeader(String pwHash, String email, String first, String next,
                                       String gender, int bbcIdx, int level) {
        UUID userId = UUID.randomUUID();
        UUID memberId = UUID.randomUUID();
        UUID bbcId = bbcIdx == 1 ? BBC_UNIKIN : bbcIdx == 2 ? BBC_UPC : BBC_ULUB;
        UUID lvl = levelId(bbcIdx, level);
        return insertUser(userId, email, pwHash, first, next, gender, "STUDENT")
                .then(insertMember(memberId, userId, "STUDENT", bbcId, lvl, 24, new BigDecimal("92.31")))
                .then(assignRole(userId, ROLE_STUDENT, bbcId))
                .then(assignRole(userId, ROLE_BBC_LEADER, bbcId))
                .then(db.sql("UPDATE bbcms_bible_club SET president_member_id = :m WHERE id = :id")
                        .bind("m", memberId).bind("id", bbcId).then());
    }

    private Mono<Void> insertProfessional(String pwHash, String email, String first, String next,
                                          String gender, String profession, String position) {
        UUID userId = UUID.randomUUID();
        UUID memberId = UUID.randomUUID();
        String kind = "MENTOR".equals(position) ? "MENTOR" : "PROFESSIONAL";
        return insertUser(userId, email, pwHash, first, next, gender, "PROFESSIONAL")
                .then(insertProfessionalMember(memberId, userId, kind, profession, position))
                .then(assignRole(userId, ROLE_PROFESSIONAL, null));
    }

    private Mono<Void> insertUser(UUID id, String email, String pwHash, String firstNames,
                                  String nextNames, String gender, String userType) {
        return db.sql("""
                INSERT INTO bbcms_user_account (id, email, password_hash, status, user_type,
                    first_names, next_names, gender, locale, created_by, updated_by)
                VALUES (:id, :email, :pw, 'ACTIVE', :ut, :fn, :nn, :g, 'fr', :sys, :sys)
                """)
                .bind("id", id).bind("email", email).bind("pw", pwHash).bind("ut", userType)
                .bind("fn", firstNames).bind("nn", nextNames).bind("g", gender).bind("sys", SYSTEM)
                .then();
    }

    private Mono<Void> insertMember(UUID id, UUID userId, String kind, UUID bbcId, UUID levelId,
                                    int score, BigDecimal pct) {
        return db.sql("""
                INSERT INTO bbcms_member (id, user_account_id, member_kind, bible_club_id, level_id,
                    participation_score, faithful_percentage, status, created_by, updated_by)
                VALUES (:id, :uid, :kind, :bbc, :lvl, :score, :pct, 'ACTIVE', :sys, :sys)
                """)
                .bind("id", id).bind("uid", userId).bind("kind", kind).bind("bbc", bbcId)
                .bind("lvl", levelId).bind("score", score).bind("pct", pct).bind("sys", SYSTEM)
                .then();
    }

    private Mono<Void> insertProfessionalMember(UUID id, UUID userId, String kind,
                                                String profession, String position) {
        return db.sql("""
                INSERT INTO bbcms_member (id, user_account_id, member_kind, participation_score,
                    profession, professional_position, status, created_by, updated_by)
                VALUES (:id, :uid, :kind, 0, :prof, :pos, 'ACTIVE', :sys, :sys)
                """)
                .bind("id", id).bind("uid", userId).bind("kind", kind)
                .bind("prof", profession).bind("pos", position).bind("sys", SYSTEM)
                .then();
    }

    private Mono<Void> assignRole(UUID userId, UUID roleId, UUID scopeBbcId) {
        var spec = db.sql("""
                INSERT INTO bbcms_user_role_assignment (user_account_id, role_id,
                    scope_bible_club_id, active, created_by, created_at, updated_by, updated_at, version)
                VALUES (:uid, :rid, :scope, true, :sys, :now, :sys, :now, 0)
                """)
                .bind("uid", userId).bind("rid", roleId)
                .bind("sys", SYSTEM).bind("now", Instant.now());
        if (scopeBbcId == null) {
            spec = spec.bindNull("scope", UUID.class);
        } else {
            spec = spec.bind("scope", scopeBbcId);
        }
        return spec.then();
    }

    // ─────────────────────────────────────────────────────────────────────
    //  MEETINGS — pour UNIKIN principalement, mix RECORDED/PLANNED/ONGOING
    // ─────────────────────────────────────────────────────────────────────

    private Mono<Void> seedMeetings() {
        Mono<Void> chain = Mono.empty();
        // 8 réunions passées (RECORDED) + 4 futures (PLANNED)
        String[][] meetings = {
                // {title, type, daysOffset, status, bbcIdx, level}
                {"Étude — Romains 1",        "CLASS_MEETING",     "-50", "RECORDED", "1", "3"},
                {"Étude — Romains 2",        "CLASS_MEETING",     "-43", "RECORDED", "1", "3"},
                {"Cellule de prière",        "PRAYER_MEETING",    "-36", "RECORDED", "1", "0"},
                {"Étude — Romains 3",        "CLASS_MEETING",     "-29", "RECORDED", "1", "3"},
                {"Évangélisation campus",    "GENERAL_MEETING",   "-22", "RECORDED", "1", "0"},
                {"Étude — Romains 4",        "CLASS_MEETING",     "-15", "RECORDED", "1", "3"},
                {"Culte mensuel BBC",        "GENERAL_MEETING",   "-8",  "RECORDED", "1", "0"},
                {"Étude — Romains 5",        "CLASS_MEETING",     "-1",  "RECORDED", "1", "3"},
                {"Cellule de prière",        "PRAYER_MEETING",    "1",   "PLANNED",  "1", "0"},
                {"Étude — Romains 8",        "CLASS_MEETING",     "3",   "PLANNED",  "1", "3"},
                {"Culte mensuel BBC",        "GENERAL_MEETING",   "10",  "PLANNED",  "1", "0"},
                {"Discipulat — L2",          "LEADERS_MEETING",   "4",   "PLANNED",  "1", "2"},
        };
        for (String[] m : meetings) {
            UUID id = UUID.randomUUID();
            int offset = Integer.parseInt(m[2]);
            int bbcIdx = Integer.parseInt(m[4]);
            int level = Integer.parseInt(m[5]);
            UUID bbcId = bbcIdx == 1 ? BBC_UNIKIN : bbcIdx == 2 ? BBC_UPC : BBC_ULUB;
            UUID lvl = level > 0 ? levelId(bbcIdx, level) : null;
            chain = chain.then(insertMeeting(id, m[0], m[1], LocalDate.now().plusDays(offset),
                    m[3], bbcId, lvl));
        }
        return chain;
    }

    private Mono<Void> insertMeeting(UUID id, String title, String type, LocalDate date,
                                     String status, UUID bbcId, UUID levelId) {
        int nbBelievers = "RECORDED".equals(status) ? (1 + Math.abs(title.hashCode()) % 5) : 0;
        boolean recorded = "RECORDED".equals(status);
        var spec = db.sql("""
                INSERT INTO bbcms_meeting (id, bible_club_id, level_id, title, type, planned_date,
                    planned_start_time, date_occurred, summary, nb_believers, max_pictures, status,
                    created_by, updated_by)
                VALUES (:id, :bbc, :lvl, :title, :type, :date, '16:00:00',
                    :dateOccurred, :summary, :nb, 20, :status, :sys, :sys)
                """)
                .bind("id", id).bind("bbc", bbcId)
                .bind("title", title).bind("type", type).bind("date", date)
                .bind("nb", nbBelievers).bind("status", status).bind("sys", SYSTEM);

        spec = levelId == null ? spec.bindNull("lvl", UUID.class) : spec.bind("lvl", levelId);
        spec = recorded ? spec.bind("dateOccurred", date) : spec.bindNull("dateOccurred", LocalDate.class);
        spec = recorded
                ? spec.bind("summary", "Étude approfondie et temps de prière communautaire.")
                : spec.bindNull("summary", String.class);
        return spec.then();
    }

    // ─────────────────────────────────────────────────────────────────────
    //  ATTENDANCE SCORES — pour démontrer le calcul de fidélité
    // ─────────────────────────────────────────────────────────────────────

    private Mono<Void> seedAttendanceScores() {
        int year = LocalDate.now().getMonthValue() >= 9
                ? LocalDate.now().getYear()
                : LocalDate.now().getYear() - 1;
        return db.sql("""
                INSERT INTO bbcms_attendance_score (id, member_id, bible_club_id, level_id,
                    academic_year, score, total_eligible, faithful_percentage, faithful,
                    last_computed_at)
                SELECT gen_random_uuid(), m.id, m.bible_club_id, m.level_id,
                       :year, m.participation_score, 26,
                       m.faithful_percentage,
                       (m.faithful_percentage >= 50)::boolean,
                       :now
                FROM bbcms_member m
                WHERE m.member_kind = 'STUDENT' AND m.status = 'ACTIVE'
                """)
                .bind("year", year).bind("now", Instant.now())
                .then();
    }

    // ─────────────────────────────────────────────────────────────────────
    //  PUBLICATIONS — 1 Daily Verse + 2 Announcements
    // ─────────────────────────────────────────────────────────────────────

    private Mono<Void> seedPublications() {
        return db.sql("""
                INSERT INTO bbcms_daily_verse_publication (id, title, reference, verse_text,
                    reflection_text, publish_date, status, audience, created_by, updated_by)
                VALUES (gen_random_uuid(), :title, :ref, :verse, :ref2, :date, 'PUBLISHED', 'CHF', :sys, :sys)
                """)
                .bind("title", "Le bon berger")
                .bind("ref", "Psaume 23.1")
                .bind("verse", "« L'Éternel est mon berger : je ne manquerai de rien. »")
                .bind("ref2", "Reposer en celui qui pourvoit, c'est l'attitude du disciple confiant.")
                .bind("date", LocalDate.now())
                .bind("sys", SYSTEM)
                .then()
                .then(db.sql("""
                INSERT INTO bbcms_special_announcement (id, title, content, type, publish_date,
                    status, audience, created_by, updated_by)
                VALUES (gen_random_uuid(), :title, :content, 'CONGRESS', :date, 'PUBLISHED', 'CHF', :sys, :sys)
                """)
                        .bind("title", "Camp national de jeunes")
                        .bind("content", "Du 15 au 22 août à Goma · 250 places. Inscriptions ouvertes via l'app.")
                        .bind("date", LocalDate.now().minusDays(2))
                        .bind("sys", SYSTEM)
                        .then())
                .then(db.sql("""
                INSERT INTO bbcms_special_announcement (id, title, content, type, publish_date,
                    status, audience, created_by, updated_by)
                VALUES (gen_random_uuid(), :title, :content, 'OTHER', :date, 'PUBLISHED', 'CHF', :sys, :sys)
                """)
                        .bind("title", "Nouveau cycle de discipulat L2")
                        .bind("content", "Démarrage 20 mai · 8 places · animé par Pasteur Mwamba.")
                        .bind("date", LocalDate.now().minusDays(1))
                        .bind("sys", SYSTEM)
                        .then());
    }

    // ─────────────────────────────────────────────────────────────────────
    //  PRAYER CHAIN — chaîne active de 24h sur UNIKIN
    // ─────────────────────────────────────────────────────────────────────

    private Mono<Void> seedPrayerChain() {
        UUID chainId = UUID.randomUUID();
        return db.sql("""
                INSERT INTO bbcms_prayer_chain (id, bible_club_id, title, date_start, date_end,
                    status)
                VALUES (:id, :bbc, :title, :start, :end, 'RUNNING')
                """)
                .bind("id", chainId).bind("bbc", BBC_UNIKIN)
                .bind("title", "Réveil de Pentecôte 2026")
                .bind("start", LocalDate.now())
                .bind("end", LocalDate.now().plusDays(1))
                .then()
                .then(seedPrayerSlots(chainId));
    }

    private Mono<Void> seedPrayerSlots(UUID chainId) {
        Mono<Void> chain = Mono.empty();
        Instant base = LocalDate.now().atStartOfDay().toInstant(java.time.ZoneOffset.UTC);
        for (int hour = 0; hour < 24; hour++) {
            Instant slotStart = base.plusSeconds(hour * 3600L);
            Instant slotEnd = base.plusSeconds((hour + 1) * 3600L);
            boolean covered = hour < 14;
            chain = chain.then(insertPrayerSlot(chainId, slotStart, slotEnd, covered));
        }
        return chain;
    }

    private Mono<Void> insertPrayerSlot(UUID chainId, Instant start, Instant end, boolean covered) {
        return db.sql("""
                INSERT INTO bbcms_prayer_slot (id, prayer_chain_id, dt_start, dt_end, covered)
                VALUES (gen_random_uuid(), :cid, :s, :e, :c)
                """)
                .bind("cid", chainId).bind("s", start).bind("e", end).bind("c", covered)
                .then();
    }

    // ─────────────────────────────────────────────────────────────────────
    //  EVANGELISM — programme actif "Campus en feu"
    // ─────────────────────────────────────────────────────────────────────

    private Mono<Void> seedEvangelism() {
        UUID progId = UUID.randomUUID();
        return db.sql("""
                INSERT INTO bbcms_evangelism_program (id, title, type, status, objective_believers,
                    total_preached, total_saved, total_encouraged, created_by, updated_by)
                VALUES (:id, :title, 'INTERNAL_BBC', 'ACTIVE', 150, 247, 38, 94, :sys, :sys)
                """)
                .bind("id", progId).bind("title", "Campus en feu — Mai 2026").bind("sys", SYSTEM)
                .then()
                .then(db.sql("""
                INSERT INTO bbcms_evangelism_program_dates (program_id, program_date)
                VALUES (:pid, :d1), (:pid, :d2), (:pid, :d3)
                """)
                        .bind("pid", progId)
                        .bind("d1", LocalDate.now().minusDays(2))
                        .bind("d2", LocalDate.now())
                        .bind("d3", LocalDate.now().plusDays(2))
                        .then())
                .then(db.sql("""
                INSERT INTO bbcms_evangelism_program_bbc (program_id, bible_club_id)
                VALUES (:pid, :bbc)
                """)
                        .bind("pid", progId).bind("bbc", BBC_UNIKIN)
                        .then());
    }

    // ─────────────────────────────────────────────────────────────────────
    //  FINANCE — Contribution active sur UNIKIN
    // ─────────────────────────────────────────────────────────────────────

    private Mono<Void> seedContribution() {
        UUID contribId = UUID.randomUUID();
        return db.sql("""
                INSERT INTO bbcms_financial_contribution (id, bible_club_id, title, description,
                    objective_amount, currency, total_contributed, status, date_open)
                VALUES (:id, :bbc, :title, :desc, 480.00, 'USD', 284.00, 'OPEN', :date)
                """)
                .bind("id", contribId).bind("bbc", BBC_UNIKIN)
                .bind("title", "Édifice Gospel — Construction salle")
                .bind("desc", "Objectif annuel : équiper la grande salle.")
                .bind("date", LocalDate.now().minusMonths(2))
                .then();
    }

    // ─────────────────────────────────────────────────────────────────────
    //  EVENTS — Congrès National à venir
    // ─────────────────────────────────────────────────────────────────────

    private Mono<Void> seedEvent() {
        return db.sql("""
                INSERT INTO bbcms_event (id, title, type, planned_start_dt, planned_end_dt,
                    location, max_pictures, status, created_by, updated_by)
                VALUES (gen_random_uuid(), :title, 'NATIONAL_CONGRESS', :s, :e, :loc, 100,
                    'REGISTRATION_OPEN', :sys, :sys)
                """)
                .bind("title", "Congrès National CHF 2026")
                .bind("s", Instant.now().plusSeconds(60L * 60 * 24 * 90))
                .bind("e", Instant.now().plusSeconds(60L * 60 * 24 * 93))
                .bind("loc", "Goma · Centre des Conférences")
                .bind("sys", SYSTEM)
                .then();
    }
}
