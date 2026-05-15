import 'package:equatable/equatable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Représentation du payload JWT BBCMS courant.
///
/// Le backend (BbcmsAuthenticationToken) inclut: sub (userId), bibleClubId,
/// levelId, roles, permissions, type=access, iat, exp.
class CurrentUser extends Equatable {
  final String userId;
  final String email;
  final String? bibleClubId;
  final String? levelId;
  final String userType; // VISITOR, STUDENT, PROFESSIONAL, NATIONAL_LEADER
  final List<String> roles;
  final List<String> permissions;
  final String? firstNames;
  final String? nextNames;

  const CurrentUser({
    required this.userId,
    required this.email,
    required this.userType,
    required this.roles,
    required this.permissions,
    this.bibleClubId,
    this.levelId,
    this.firstNames,
    this.nextNames,
  });

  factory CurrentUser.fromJwt(String token) {
    final Map<String, dynamic> claims = JwtDecoder.decode(token);
    return CurrentUser(
      userId: claims['sub']?.toString() ?? '',
      email: claims['email']?.toString() ?? '',
      userType: claims['userType']?.toString() ?? 'VISITOR',
      bibleClubId: claims['bibleClubId']?.toString(),
      levelId: claims['levelId']?.toString(),
      roles: (claims['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      permissions:
          (claims['permissions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      firstNames: claims['firstNames']?.toString(),
      nextNames: claims['nextNames']?.toString(),
    );
  }

  bool hasPermission(String code) => permissions.contains(code);

  bool hasAnyPermission(Iterable<String> codes) =>
      codes.any((c) => permissions.contains(c));

  bool get isLeaderNational => roles.contains('NATIONAL_LEADER') || roles.contains('SYSTEM_ADMIN');
  bool get isLeaderBbc => roles.contains('BBC_LEADER');
  bool get isStudent => userType == 'STUDENT';
  bool get isProfessional => userType == 'PROFESSIONAL';

  String get displayName {
    final parts = [firstNames, nextNames].where((s) => s != null && s.isNotEmpty);
    return parts.isEmpty ? email : parts.join(' ');
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        userType,
        bibleClubId,
        levelId,
        roles,
        permissions,
        firstNames,
        nextNames,
      ];
}
