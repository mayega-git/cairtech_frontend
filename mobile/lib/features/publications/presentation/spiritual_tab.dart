import 'package:flutter/material.dart';

import '../../shell/presentation/app_shell.dart';

class SpiritualTabPage extends StatelessWidget {
  const SpiritualTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTab(
      title: 'Vie spirituelle',
      subtitle:
          'Verset du jour, annonces, chaîne de prière, programmes d\'intercession — '
          'branché en Phase 6.',
      icon: Icons.menu_book_outlined,
    );
  }
}
