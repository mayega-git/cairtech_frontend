import 'package:cairtech_app/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  group('Fmt.isoDate', () {
    test('formate yyyy-MM-dd pour le backend (LocalDate)', () {
      expect(Fmt.isoDate(DateTime(2026, 1, 5)), '2026-01-05');
      expect(Fmt.isoDate(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });

  group('Fmt.date', () {
    test('formate dd/MM/yyyy en FR', () {
      expect(Fmt.date(DateTime(2026, 1, 5)), '05/01/2026');
    });
  });

  group('Fmt.amount', () {
    test('utilise l\'espace insécable FR comme séparateur de milliers', () {
      // intl FR utilise l'espace insécable (U+202F) en >= 0.19
      final s = Fmt.amount(10000);
      expect(s.replaceAll(RegExp(r'\s'), ' '), '10 000');
      expect(Fmt.amount(1234567), isNot(equals('1234567')));
    });

    test('respecte le nombre de décimales demandé', () {
      expect(Fmt.amount(10, decimals: 2).endsWith('00'), isTrue);
    });
  });

  group('Fmt.percent', () {
    test('multiplie par 100 et suffixe " %"', () {
      expect(Fmt.percent(0.47), '47 %');
      expect(Fmt.percent(1.0), '100 %');
      expect(Fmt.percent(0.473, decimals: 1).endsWith(' %'), isTrue);
    });
  });

  group('Fmt.percentBase100', () {
    test('garde la valeur telle quelle (déjà en %)', () {
      expect(Fmt.percentBase100(47), '47 %');
      expect(Fmt.percentBase100(47.3, decimals: 1).startsWith('47'), isTrue);
    });
  });

  group('Fmt.amountWithCurrency', () {
    test('concatène montant + devise XAF', () {
      final s = Fmt.amountWithCurrency(1500, 'XAF');
      expect(s.endsWith(' XAF'), isTrue);
    });
  });
}
