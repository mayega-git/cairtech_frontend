import 'package:intl/intl.dart';

/// Formatters localisés FR-FR pour BBCMS.
///
/// La devise V1 est XAF (Franc CFA), conformément aux décisions backend
/// (NUMERIC(15,2) côté DB → 2 décimales côté UI). Les horodatages backend
/// arrivent en UTC (TIMESTAMPTZ) et doivent être convertis en local avant
/// affichage.
class Fmt {
  Fmt._();

  static const String locale = 'fr_FR';

  static String date(DateTime dt) =>
      DateFormat('dd/MM/yyyy', locale).format(dt.toLocal());

  static String dateShort(DateTime dt) =>
      DateFormat('d MMM', locale).format(dt.toLocal());

  static String dateLong(DateTime dt) =>
      DateFormat('EEEE d MMMM yyyy', locale).format(dt.toLocal());

  static String time(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}h'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  static String dateTime(DateTime dt) => '${date(dt)} · ${time(dt)}';

  /// Format ISO yyyy-MM-dd attendu par le backend (LocalDate).
  static String isoDate(DateTime dt) =>
      DateFormat('yyyy-MM-dd').format(dt);

  /// Heure ISO HH:mm:ss attendue par le backend pour les champs LocalTime.
  static String isoTime(DateTime dt) =>
      DateFormat('HH:mm:ss').format(dt);

  /// "il y a 3 j", "dans 2 h", etc.
  static String relative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());
    final past = diff.isNegative ? -diff : diff;
    final sign = diff.isNegative ? 'dans ' : 'il y a ';
    if (past.inMinutes < 1) return 'à l\'instant';
    if (past.inMinutes < 60) return '$sign${past.inMinutes} min';
    if (past.inHours < 24) return '$sign${past.inHours} h';
    if (past.inDays < 30) return '$sign${past.inDays} j';
    if (past.inDays < 365) return '$sign${(past.inDays / 30).floor()} mois';
    return '$sign${(past.inDays / 365).floor()} an(s)';
  }

  /// Montant entier avec séparateur de milliers FR ("10 000").
  static String amount(double v, {int decimals = 0}) {
    final pattern = decimals == 0
        ? '#,##0'
        : '#,##0.${'0' * decimals}';
    return NumberFormat(pattern, locale).format(v);
  }

  /// Montant + devise ("10 000 XAF").
  static String amountWithCurrency(double v, String currency,
          {int decimals = 0}) =>
      '${amount(v, decimals: decimals)} $currency';

  /// Forme compacte pour les KPI ("1,5 M" / "12 K" / "350").
  static String amountCompact(double v) {
    final f = NumberFormat.compactCurrency(
      locale: locale,
      symbol: '',
      decimalDigits: 1,
    );
    final s = f.format(v).trim();
    return s.replaceAll(',0', '');
  }

  /// Pourcentage "47 %" (entier) ou "47,3 %" (1 décimale).
  static String percent(double ratio, {int decimals = 0}) {
    final pct = ratio * 100;
    final pattern = decimals == 0 ? '0' : '0.${'0' * decimals}';
    return '${NumberFormat(pattern, locale).format(pct)} %';
  }

  /// Pourcentage déjà sur base 100 (ex. score 47.3 → "47 %").
  static String percentBase100(double v, {int decimals = 0}) {
    final pattern = decimals == 0 ? '0' : '0.${'0' * decimals}';
    return '${NumberFormat(pattern, locale).format(v)} %';
  }
}
