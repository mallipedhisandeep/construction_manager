import 'package:flutter/material.dart';

import '../../../core/services/supabase_service.dart';

import 'site_model.dart';

class SiteDao {

  final SupabaseService _supabase =
      SupabaseService.instance;

  // ==============================
  // INSERT SITE
  // ==============================

  Future<void> insertSite(
    SiteModel site,
  ) async {

    try {

      await _supabase.sites.insert(
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

      await _supabase.sites
          .update(
            site.toMap(),
          )
          .eq(
            'id',
            site.id!,
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

      await _supabase.sites
          .delete()
          .eq(
            'id',
            id,
          );

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

      final response =
          await _supabase.sites
              .select()
              .order(
                'site_name_search',
              );

      return (response as List)
          .map((item) {

        return SiteModel.fromMap(
          item,
          item['id'].toString(),
        );

      }).toList();

    } catch (e) {

      debugPrint(
        'GET SITES ERROR => $e',
      );

      return [];
    }
  }

  // ==============================
  // GET BY ID
  // ==============================

  Future<SiteModel?> getById(
    String id,
  ) async {

    try {

      final response =
          await _supabase.sites
              .select()
              .eq(
                'id',
                id,
              )
              .single();

      return SiteModel.fromMap(
        response,
        response['id'].toString(),
      );

    } catch (e) {

      debugPrint(
        'GET SITE ERROR => $e',
      );

      return null;
    }
  }
}