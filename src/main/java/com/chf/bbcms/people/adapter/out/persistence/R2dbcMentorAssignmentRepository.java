package com.chf.bbcms.people.adapter.out.persistence;

import com.chf.bbcms.people.application.port.out.MentorAssignmentRepository;
import com.chf.bbcms.people.domain.MentorAssignment;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

@Repository
public class R2dbcMentorAssignmentRepository implements MentorAssignmentRepository {

    private final DatabaseClient client;

    public R2dbcMentorAssignmentRepository(DatabaseClient client) {
        this.client = client;
    }

    @Override
    public Flux<MentorAssignment> findByMember(UUID memberId) {
        return client.sql("SELECT * FROM bbcms_mentor_assignment WHERE member_id = :id")
                .bind("id", memberId)
                .map((row, m) -> mapRow(row))
                .all();
    }

    @Override
    public Flux<MentorAssignment> findByBibleClub(UUID bibleClubId) {
        return client.sql("SELECT * FROM bbcms_mentor_assignment WHERE bible_club_id = :id")
                .bind("id", bibleClubId)
                .map((row, m) -> mapRow(row))
                .all();
    }

    @Override
    public Mono<MentorAssignment> save(MentorAssignment a) {
        return client.sql("""
                        INSERT INTO bbcms_mentor_assignment(member_id, bible_club_id, date_start, date_end)
                        VALUES (:m, :b, :s, :e)
                        ON CONFLICT (member_id, bible_club_id)
                        DO UPDATE SET date_start = EXCLUDED.date_start, date_end = EXCLUDED.date_end
                        """)
                .bind("m", a.memberId())
                .bind("b", a.bibleClubId())
                .bind("s", a.dateStart())
                .bind("e", a.dateEnd() == null ? null : a.dateEnd())
                .then()
                .thenReturn(a);
    }

    @Override
    public Mono<Void> delete(UUID memberId, UUID bibleClubId) {
        return client.sql("DELETE FROM bbcms_mentor_assignment WHERE member_id = :m AND bible_club_id = :b")
                .bind("m", memberId)
                .bind("b", bibleClubId)
                .then();
    }

    private MentorAssignment mapRow(io.r2dbc.spi.Row row) {
        return new MentorAssignment(
                row.get("member_id", UUID.class),
                row.get("bible_club_id", UUID.class),
                row.get("date_start", LocalDate.class),
                row.get("date_end", LocalDate.class)
        );
    }
}
