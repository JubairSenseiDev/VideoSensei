import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../domain/models/compression_result.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/codec_choice.dart';

part 'history_repository.g.dart';

// ── Drift table ──────────────────────────────────────────────────────────────

class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get inputPath => text()();
  TextColumn get inputName => text()();
  IntColumn get inputSize => integer()();
  TextColumn get outputPath => text().nullable()();
  IntColumn get outputSize => integer().nullable()();
  TextColumn get presetKey => text()();
  TextColumn get status => text()(); // 'success' | 'failed' | 'cancelled'
  TextColumn get ffmpegCommand => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get encodingSeconds => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [HistoryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'videosensei_history');
  }
}

QueryExecutor _openConnection() => driftDatabase(name: 'videosensei_history');

// ── Providers ─────────────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

// ── Repository ────────────────────────────────────────────────────────────────

class HistoryRepository {
  final AppDatabase _db;

  HistoryRepository(this._db);

  Future<List<HistoryEntry>> getAll({int limit = 100}) {
    return (_db.select(_db.historyEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> insert(CompressionResult result) async {
    await _db.into(_db.historyEntries).insert(
          HistoryEntriesCompanion.insert(
            inputPath: result.inputFile.path,
            inputName: result.inputFile.name,
            inputSize: result.inputFile.size,
            outputPath: Value(result.outputPath),
            outputSize: Value(result.outputSize),
            presetKey: result.preset.key.name,
            status: result.status.name,
            ffmpegCommand: Value(result.ffmpegCommand),
            errorMessage: Value(result.errorMessage),
            encodingSeconds:
                Value(result.encodingDuration?.inSeconds),
          ),
        );
  }

  Future<void> deleteById(int id) async {
    await (_db.delete(_db.historyEntries)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> clearAll() => _db.delete(_db.historyEntries).go();
}

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(appDatabaseProvider)),
);
