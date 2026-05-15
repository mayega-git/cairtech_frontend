import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AvatarSize { sm, md, lg }

/// Avatar circulaire : photo réseau si [imageUrl] sinon initiales.
class Avatar extends StatelessWidget {
  final String name;
  final AvatarSize size;
  final Color? color;
  final String? imageUrl;

  const Avatar({
    super.key,
    required this.name,
    this.size = AvatarSize.md,
    this.color,
    this.imageUrl,
  });

  double get _dim => switch (size) {
        AvatarSize.sm => 28,
        AvatarSize.md => 40,
        AvatarSize.lg => 64,
      };

  double get _fontSize => switch (size) {
        AvatarSize.sm => 11,
        AvatarSize.md => 14,
        AvatarSize.lg => 22,
      };

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.ink;
    return Container(
      width: _dim,
      height: _dim,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _fallback(bgColor),
              errorWidget: (_, __, ___) => _fallback(bgColor),
            )
          : _fallback(bgColor),
    );
  }

  Widget _fallback(Color bgColor) => Center(
        child: Text(
          _initials,
          style: AppTypography.sans(
            size: _fontSize,
            weight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      );
}
