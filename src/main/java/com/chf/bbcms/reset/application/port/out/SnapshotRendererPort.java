package com.chf.bbcms.reset.application.port.out;

import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.reset.domain.BibleClubResetSnapshot;

/**
 * Port out pour générer une représentation imprimable d'un snapshot reset.
 * Implémenté par SnapshotPdfGenerator (OpenPDF).
 */
public interface SnapshotRendererPort {

    RenderedDocument render(BibleClub bbc, BibleClubResetSnapshot snapshot);

    record RenderedDocument(byte[] bytes, String fileName, String contentType) {}
}
