import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseService._internal();

  static final FirebaseService instance =
      FirebaseService._internal();

  // ==============================
  // FIREBASE INSTANCES
  // ==============================

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage storage =
      FirebaseStorage.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  // ==============================
  // COLLECTION REFERENCES
  // ==============================

  CollectionReference get workers =>
      firestore.collection('workers');

  CollectionReference get attendance =>
      firestore.collection('attendance');

  CollectionReference get sites =>
      firestore.collection('sites');

  CollectionReference get privateWorkers =>
      firestore.collection('private_workers');

  CollectionReference get privateWork =>
      firestore.collection('private_work');

  CollectionReference get privateWorkerPayments =>
      firestore.collection('private_worker_payments');

  CollectionReference get siteAgreements =>
      firestore.collection('site_agreements');

  CollectionReference get siteFloorFiles =>
      firestore.collection('site_floor_files');

  CollectionReference get siteElevations =>
      firestore.collection('site_elevations');
}