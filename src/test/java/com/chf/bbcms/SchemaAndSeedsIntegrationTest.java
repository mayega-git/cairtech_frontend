package com.chf.bbcms;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.r2dbc.core.DatabaseClient;
import reactor.test.StepVerifier;

/**
 * Vérifie que le schéma Liquibase complet s'applique
 * et que les seeds (permissions + rôles + settings) sont chargés.
 */
class SchemaAndSeedsIntegrationTest extends AbstractIntegrationTest {

    @Autowired
    private DatabaseClient databaseClient;

    @Test
    void permissions_catalog_is_loaded() {
        databaseClient.sql("SELECT count(*) AS n FROM bbcms_permission")
                .map((row, m) -> row.get("n", Long.class))
                .one()
                .as(StepVerifier::create)
                .assertNext(n -> org.junit.jupiter.api.Assertions.assertTrue(n >= 60,
                        "Expected at least 60 permissions, got " + n))
                .verifyComplete();
    }

    @Test
    void system_admin_role_has_all_permissions() {
        databaseClient.sql("""
                        SELECT (SELECT count(*) FROM bbcms_role_permission WHERE role_id = '11111111-0000-0000-0000-000000000001') AS assigned,
                               (SELECT count(*) FROM bbcms_permission) AS total
                        """)
                .map((row, m) -> new long[]{row.get("assigned", Long.class), row.get("total", Long.class)})
                .one()
                .as(StepVerifier::create)
                .assertNext(arr -> org.junit.jupiter.api.Assertions.assertEquals(arr[1], arr[0],
                        "SYSTEM_ADMIN should have ALL permissions"))
                .verifyComplete();
    }

    @Test
    void faithfulness_threshold_is_seeded() {
        databaseClient.sql("SELECT value FROM bbcms_setting WHERE key = 'faithfulness.threshold.percentage'")
                .map((row, m) -> row.get("value", String.class))
                .one()
                .as(StepVerifier::create)
                .expectNext("50")
                .verifyComplete();
    }
}
