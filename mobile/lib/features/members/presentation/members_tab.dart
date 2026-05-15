import 'package:flutter/material.dart';

import '../../shell/presentation/app_shell.dart';

class MembersTabPage extends StatelessWidget {
  const MembersTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTab(
      title: 'Annuaire des membres',
      subtitle:
          'Liste groupée, recherche, filtre par niveau / département / statut, '
          'fiche détaillée — branché en Phase 5.',
      icon: Icons.group_outlined,
    );
  }
}
