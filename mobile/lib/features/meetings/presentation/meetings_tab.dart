import 'package:flutter/material.dart';

import '../../shell/presentation/app_shell.dart';

class MeetingsTabPage extends StatelessWidget {
  const MeetingsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTab(
      title: 'Réunions & présences',
      subtitle:
          'Liste filtrable des réunions, planification, pointage des présences, '
          'photos et résumé — branché en Phase 4.',
      icon: Icons.calendar_today_outlined,
    );
  }
}
