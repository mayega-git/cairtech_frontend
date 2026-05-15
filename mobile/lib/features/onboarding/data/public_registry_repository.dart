import 'package:equatable/equatable.dart';

import '../../../core/api/dio_client.dart';

/// Vue lite d'un Bible Club pour les sélecteurs publics (cf
/// /api/v1/bbcms/public/bible-clubs).
class BibleClubLite extends Equatable {
  final String id;
  final String name;
  final String? schoolName;

  const BibleClubLite({required this.id, required this.name, this.schoolName});

  factory BibleClubLite.fromJson(Map<String, dynamic> j) => BibleClubLite(
        id: j['id'] as String,
        name: j['name'] as String,
        schoolName: j['schoolName'] as String?,
      );

  @override
  List<Object?> get props => [id, name, schoolName];
}

/// Vue lite d'un Niveau (L1..L7) pour les sélecteurs publics.
class LevelLite extends Equatable {
  final String id;
  final String name;
  final String type; // L1..L7

  const LevelLite({required this.id, required this.name, required this.type});

  factory LevelLite.fromJson(Map<String, dynamic> j) => LevelLite(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
      );

  @override
  List<Object?> get props => [id, name, type];
}

/// Repository des endpoints publics (utilisés sans authentification).
class PublicRegistryRepository {
  final DioClient client;
  PublicRegistryRepository(this.client);

  Future<List<BibleClubLite>> listBibleClubs() async {
    final res = await client.dio.get('/public/bible-clubs');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => BibleClubLite.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LevelLite>> listLevels(String bibleClubId) async {
    final res = await client.dio.get('/public/bible-clubs/$bibleClubId/levels');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => LevelLite.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
