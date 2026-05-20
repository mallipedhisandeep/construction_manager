import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/services/firebase_service.dart';

import 'site_model.dart';

class SiteDao {
  final FirebaseService _firebase =
      FirebaseService.instance;

  // ==============================
  // INSERT SITE
  // ==============================

  Future<void> insertSite(
    SiteModel site,
  ) async {
    try {
      await _firebase.sites.add(
        site.toMap(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==============================
  // UPDATE SITE
  // ==============================

  Future<void> updateSite(
    SiteModel site,
  ) async {
    try {
      if (site.id == null) {
        return;
      }

      await _firebase.sites
          .doc(site.id)
          .set(
            site.toMap(),
            SetOptions(
              merge: true,
            ),
          );
    } catch (e) {
      rethrow;
    }
  }

  // ==============================
  // DELETE SITE
  // ==============================

  Future<void> deleteSite(
    String id,
  ) async {
    try {
      await _firebase.sites
          .doc(id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ==============================
  // GET ALL SITES
  // ==============================

  Future<List<SiteModel>>
      getAllSites() async {
    try {
      final snapshot =
          await _firebase.sites
              .orderBy(
                'site_name_search',
              )
              .get();

      return snapshot.docs.map(
        (doc) {
          return SiteModel.fromMap(
            doc.data(),
            doc.id,
          );
        },
      ).toList();
    } catch (e) {
      debugPrint(
        'GET SITES ERROR => $e',
      );

      return [];
    }
  }

  // ==============================
  // REALTIME STREAM
  // ==============================

  Stream<List<SiteModel>>
      watchSites() {
    return _firebase.sites
        .orderBy(
          'site_name_search',
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return SiteModel.fromMap(
              doc.data(),
              doc.id,
            );
          },
        ).toList();
      },
    );
  }

  // ==============================
  // GET BY ID
  // ==============================

  Future<SiteModel?> getById(
    String id,
  ) async {
    try {
      final doc =
          await _firebase.sites
              .doc(id)
              .get();

      if (!doc.exists) {
        return null;
      }

      return SiteModel.fromMap(
        doc.data()
            as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      debugPrint(
        'GET SITE ERROR => $e',
      );

      return null;
    }
  }
}