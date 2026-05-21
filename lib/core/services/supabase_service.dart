import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._internal();

  static final SupabaseService instance =
      SupabaseService._internal();

  final SupabaseClient client =
      Supabase.instance.client;

  // =========================
  // TABLES
  // =========================

  SupabaseQueryBuilder get workers =>
      client.from('workers');

  SupabaseQueryBuilder get attendance =>
      client.from('attendance');

  SupabaseQueryBuilder get sites =>
      client.from('sites');

  SupabaseQueryBuilder get privateWorkers =>
      client.from('private_workers');

  SupabaseQueryBuilder get privateWork =>
      client.from('private_work');

  SupabaseQueryBuilder get privateWorkerPayments =>
      client.from(
        'private_worker_payments',
      );

  SupabaseQueryBuilder
      get siteAgreements =>
          client.from(
            'site_agreements',
          );

  SupabaseQueryBuilder
      get siteFloorFiles =>
          client.from(
            'site_floor_files',
          );

  SupabaseQueryBuilder
      get siteElevations =>
          client.from(
            'site_elevations',
          );

  // =========================
  // STORAGE
  // =========================

  SupabaseStorageClient get storage =>
      client.storage;

  // =========================
  // AUTH
  // =========================

  GoTrueClient get auth =>
      client.auth;

  // =========================
  // HELPERS
  // =========================

  DateTime now() {
    return DateTime.now();
  }

  String errorMessage(
    Object error,
  ) {
    if (error is PostgrestException) {
      return error.message;
    }

    if (error is AuthException) {
      return error.message;
    }

    if (error is StorageException) {
      return error.message;
    }

    return error.toString();
  }
}