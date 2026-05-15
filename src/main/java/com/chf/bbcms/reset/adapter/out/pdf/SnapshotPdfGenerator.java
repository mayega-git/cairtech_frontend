package com.chf.bbcms.reset.adapter.out.pdf;

import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.reset.application.port.out.SnapshotRendererPort;
import com.chf.bbcms.reset.domain.BibleClubResetSnapshot;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.springframework.stereotype.Component;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;

/**
 * Génère un PDF natif pour les snapshots de reset annuel d'un Bible Club.
 * Implémente SnapshotRendererPort.
 */
@Component
public class SnapshotPdfGenerator implements SnapshotRendererPort {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ISO_INSTANT;
    private static final Color BBCMS_BLUE = new Color(0x1A, 0x3D, 0x7C);

    @Override
    public RenderedDocument render(BibleClub bbc, BibleClubResetSnapshot snap) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (Document document = new Document()) {
            PdfWriter.getInstance(document, out);
            document.open();

            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, BBCMS_BLUE);
            Font sectionFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13, BBCMS_BLUE);
            Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 11, Color.BLACK);

            Paragraph title = new Paragraph("BBCMS — Rapport annuel", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20);
            document.add(title);

            Paragraph header = new Paragraph(bbc.getName(), sectionFont);
            header.setSpacingAfter(8);
            document.add(header);

            document.add(new Paragraph("Année académique: " + snap.academicYear(), normalFont));
            document.add(new Paragraph("École rattachée: "
                    + (bbc.getSchoolName() == null ? "—" : bbc.getSchoolName()), normalFont));
            document.add(new Paragraph("Statut au moment du reset: " + bbc.getStatus(), normalFont));
            document.add(new Paragraph(" "));

            document.add(new Paragraph("Bilan", sectionFont));
            PdfPTable stats = new PdfPTable(2);
            stats.setWidthPercentage(70);
            stats.setHorizontalAlignment(Element.ALIGN_LEFT);
            stats.setSpacingBefore(8);
            addRow(stats, "Membres actifs", String.valueOf(snap.nbMembersBefore()), normalFont);
            addRow(stats, "Membres fidèles", String.valueOf(snap.nbFaithfulBefore()), normalFont);
            addRow(stats, "Réunions enregistrées", String.valueOf(snap.nbMeetings()), normalFont);
            addRow(stats, "Objectif annuel",
                    bbc.getGoalNbFaithful() == null ? "—" : String.valueOf(bbc.getGoalNbFaithful()),
                    normalFont);
            addRow(stats, "% atteint",
                    snap.percentageReached() == null ? "0,00 %"
                            : snap.percentageReached().toPlainString() + " %",
                    normalFont);
            document.add(stats);

            document.add(new Paragraph(" "));
            document.add(new Paragraph("Archivé le: " + DATE_FMT.format(snap.archivedAt()), normalFont));
            document.add(new Paragraph("Bible Club ID: " + bbc.getId(), normalFont));
            document.add(new Paragraph("Snapshot ID: "
                    + (snap.id() == null ? "(pending)" : snap.id().toString()), normalFont));

            Paragraph footer = new Paragraph(
                    "Document généré automatiquement par BBCMS — Communauté des Hommes de Foi",
                    FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 9, Color.DARK_GRAY));
            footer.setSpacingBefore(30);
            footer.setAlignment(Element.ALIGN_CENTER);
            document.add(footer);
        }
        String fileName = "bbc-%s-%d-snapshot.pdf".formatted(bbc.getId(), snap.academicYear());
        return new RenderedDocument(out.toByteArray(), fileName, "application/pdf");
    }

    private void addRow(PdfPTable table, String label, String value, Font font) {
        PdfPCell c1 = new PdfPCell(new Phrase(label, font));
        PdfPCell c2 = new PdfPCell(new Phrase(value, font));
        c1.setBorderColor(Color.LIGHT_GRAY);
        c2.setBorderColor(Color.LIGHT_GRAY);
        c1.setPadding(6);
        c2.setPadding(6);
        table.addCell(c1);
        table.addCell(c2);
    }
}
