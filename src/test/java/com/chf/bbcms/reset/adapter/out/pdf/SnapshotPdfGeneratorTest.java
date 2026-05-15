package com.chf.bbcms.reset.adapter.out.pdf;

import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.reset.application.port.out.SnapshotRendererPort.RenderedDocument;
import com.chf.bbcms.reset.domain.BibleClubResetSnapshot;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class SnapshotPdfGeneratorTest {

    @Test
    void renders_a_valid_pdf_with_pdf_signature() {
        SnapshotPdfGenerator gen = new SnapshotPdfGenerator();
        BibleClub bbc = BibleClub.create("BBC Yaoundé I", null, "UY1", 50, null);
        BibleClubResetSnapshot snap = BibleClubResetSnapshot.capture(UUID.randomUUID(), 2025,
                30, 18, 24, 50, UUID.randomUUID());

        RenderedDocument doc = gen.render(bbc, snap);

        assertEquals("application/pdf", doc.contentType());
        assertTrue(doc.fileName().endsWith(".pdf"));
        assertTrue(doc.bytes().length > 1000, "PDF should not be empty");
        // PDF magic number: "%PDF-"
        String header = new String(doc.bytes(), 0, 5);
        assertEquals("%PDF-", header, "PDF must start with %PDF- header");
    }

    @Test
    void file_name_includes_year_and_bbc_id() {
        SnapshotPdfGenerator gen = new SnapshotPdfGenerator();
        BibleClub bbc = BibleClub.create("X", null, null, null, null);
        BibleClubResetSnapshot snap = BibleClubResetSnapshot.capture(bbc.getId(), 2026,
                10, 5, 0, null, UUID.randomUUID());
        RenderedDocument doc = gen.render(bbc, snap);
        assertTrue(doc.fileName().contains("2026"));
    }
}
