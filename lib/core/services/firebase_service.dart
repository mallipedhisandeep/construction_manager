import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  FirebaseService._internal();

  static final FirebaseService instance =
      FirebaseService._internal();

  // =========================
  // INSTANCES
  // =========================

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage storage =
      FirebaseStorage.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  // =========================
  // COLLECTIONS
  // =========================

  CollectionReference<Map<String, dynamic>>
      get workers =>
          firestore.collection('workers');

  CollectionReference<Map<String, dynamic>>
      get attendance =>
          firestore.collection('attendance');

  CollectionReference<Map<String, dynamic>>
      get sites =>
          firestore.collection('sites');

  CollectionReference<Map<String, dynamic>>
      get privateWorkers =>
          firestore.collection(
            'private_workers',
          );

  CollectionReference<Map<String, dynamic>>
      get privateWork =>
          firestore.collection(
            'private_work',
          );

  CollectionReference<Map<String, dynamic>>
      get privateWorkerPayments =>
          firestore.collection(
            'private_worker_payments',
          );

  CollectionReference<Map<String, dynamic>>
      get siteAgreements =>
          firestore.collection(
            'site_agreements',
          );

  CollectionReference<Map<String, dynamic>>
      get siteFloorFiles =>
          firestore.collection(
            'site_floor_files',
          );

  CollectionReference<Map<String, dynamic>>
      get siteElevations =>
          firestore.collection(
            'site_elevations',
          );

  // =========================
  // HELPERS
  // =========================

  Timestamp now() {
    return Timestamp.now();
  }

  String newId(
    String collection,
  ) {
    return firestore
        .collection(collection)
        .doc()
        .id;
  }

  // =========================
  // ERROR MESSAGE
  // =========================

  String errorMessage(
    Object error,
  ) {
    if (error is FirebaseException) {
      return error.message ??
          'Firebase error';
    }

    return error.toString();
  }
}