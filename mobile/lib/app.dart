import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class CairtechApp extends StatefulWidget {
  const CairtechApp({super.key});

  @override
  State<CairtechApp> createState() => _CairtechAppState();
}

class _CairtechAppState extends State<CairtechApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BBCMS — CHF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
