import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/storage_service.dart';

import '../data/site_agreement_dao.dart';
import '../data/site_agreement_model.dart';

import '../data/site_dao.dart';

import '../data/site_elevation_dao.dart';
import '../data/site_elevation_model.dart';

import '../data/site_model.dart';

import 'floor_files_page.dart';
import 'site_form_page.dart';

class SiteDetailsPage
    extends StatefulWidget {
  final SiteModel site;

  const SiteDetailsPage({
    super.key,
    required this.site,
  });

  @override
  State<SiteDetailsPage>
      createState() =>
          _SiteDetailsPageState();
}

class _SiteDetailsPageState
    extends State<
        SiteDetailsPage> {
  final SiteDao _dao =
      SiteDao();

  final SiteAgreementDao
      _agreementDao =
      SiteAgreementDao();

  final SiteElevationDao
      _elevationDao =
      SiteElevationDao();

  bool isDeleting = false;

  // =========================
  // PICK FILE
  // =========================

  Future<PlatformFile?> pickFile() async {
    try {
      final result =
          await FilePicker.platform
              .pickFiles(
        withData: true,
      );

      if (result == null ||
          result.files.isEmpty) {
        return null;
      }

      return result.files.single;
    } catch (e) {
      debugPrint(
        'PICK FILE ERROR => $e',
      );

      return null;
    }
  }

  // =========================
  // FORMAT DATE
  // =========================

  String _formatTimestamp(
    Timestamp? timestamp,
  ) {
    if (timestamp == null) {
      return '-';
    }

    final date =
        timestamp.toDate();

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(site.siteName),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _row(
              'Location',
              site.location,
            ),

            _row(
              'Owner',
              site.ownerName,
            ),

            _ownerPhoneRow(),

            _row(
              'Start Date',
              site.startDate,
            ),

            _row(
              'Budget',
              site.budget
                  .toString(),
            ),

            _row(
              'Floors',
              site.floorsCount
                  .toString(),
            ),

            _row(
              'Status',
              site.status,
            ),

            _row(
              'Notes',
              site.notes,
            ),

            const SizedBox(
              height: 24,
            ),

            // ======================
            // AGREEMENTS
            // ======================

            const Text(
              'Agreements',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            StreamBuilder<
                List<
                    SiteAgreementModel>>(
              stream:
                  _agreementDao
                      .watchBySite(
                site.id!,
              ),

              builder:
                  (_, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot
                    .hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                  );
                }

                final list =
                    snapshot.data ??
                        [];

                if (list.isEmpty) {
                  return const Text(
                    'No agreements added',
                  );
                }

                return Column(
                  children:
                      list.map(
                    (
                      agreement,
                    ) {
                      return Card(
                        child:
                            ListTile(
                          leading:
                              const Icon(
                            Icons
                                .description,
                          ),

                          title: Text(
                            agreement
                                .fileName,
                          ),

                          subtitle:
                              Text(
                            _formatTimestamp(
                              agreement
                                  .createdAt,
                            ),
                          ),

                          onTap:
                              () async {
                            await launchUrl(
                              Uri.parse(
                                agreement
                                    .filePath,
                              ),
                              mode:
                                  LaunchMode.externalApplication,
                            );
                          },

                          trailing:
                              Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.open_in_new,
                                ),
                                onPressed:
                                    () async {
                                  await launchUrl(
                                    Uri.parse(
                                      agreement
                                          .filePath,
                                    ),
                                    mode:
                                        LaunchMode.externalApplication,
                                  );
                                },
                              ),

                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.red,
                                ),
                                onPressed:
                                    () async {
                                  try {
                                    await StorageService.instance
                                        .deleteFile(
                                      agreement
                                          .filePath,
                                    );

                                    await _agreementDao
                                        .deleteAgreement(
                                      agreement
                                          .id!,
                                    );
                                  } catch (e) {
                                    debugPrint(
                                      'DELETE AGREEMENT ERROR => $e',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton.icon(
              icon: const Icon(
                Icons.upload_file,
              ),
              label: const Text(
                'Add Agreement',
              ),
              onPressed:
                  _addAgreement,
            ),

            const SizedBox(
              height: 24,
            ),

            // ======================
            // FLOORS
            // ======================

            const Text(
              'Floors',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  site.floorsCount,
              itemBuilder:
                  (_, i) {
                final floorName =
                    i == 0
                        ? 'Ground Floor'
                        : '$i Floor';

                return Card(
                  child: ListTile(
                    title:
                        Text(
                      floorName,
                    ),

                    trailing:
                        const Icon(
                      Icons.folder,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FloorFilesPage(
                            siteId:
                                site.id!,
                            floorNo:
                                i,
                            floorName:
                                floorName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(
              height: 24,
            ),

            // ======================
            // ELEVATIONS
            // ======================

            const Text(
              'Elevations',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            StreamBuilder<
                List<
                    SiteElevationModel>>(
              stream:
                  _elevationDao
                      .watchBySite(
                site.id!,
              ),

              builder:
                  (_, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot
                    .hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                  );
                }

                final list =
                    snapshot.data ??
                        [];

                if (list.isEmpty) {
                  return const Text(
                    'No elevations added',
                  );
                }

                return Column(
                  children:
                      list.map(
                    (
                      elevation,
                    ) {
                      return Card(
                        child:
                            ListTile(
                          leading:
                              const Icon(
                            Icons.image,
                          ),

                          title: Text(
                            elevation
                                .fileName,
                          ),

                          subtitle:
                              Text(
                            _formatTimestamp(
                              elevation
                                  .createdAt,
                            ),
                          ),

                          onTap:
                              () async {
                            await launchUrl(
                              Uri.parse(
                                elevation
                                    .filePath,
                              ),
                              mode:
                                  LaunchMode.externalApplication,
                            );
                          },

                          trailing:
                              Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.open_in_new,
                                ),
                                onPressed:
                                    () async {
                                  await launchUrl(
                                    Uri.parse(
                                      elevation
                                          .filePath,
                                    ),
                                    mode:
                                        LaunchMode.externalApplication,
                                  );
                                },
                              ),

                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.red,
                                ),
                                onPressed:
                                    () async {
                                  try {
                                    await StorageService.instance
                                        .deleteFile(
                                      elevation
                                          .filePath,
                                    );

                                    await _elevationDao
                                        .delete(
                                      elevation
                                          .id!,
                                    );
                                  } catch (e) {
                                    debugPrint(
                                      'DELETE ELEVATION ERROR => $e',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton.icon(
              icon:
                  const Icon(
                Icons.add,
              ),

              label: const Text(
                'Add Elevation',
              ),

              onPressed:
                  () async {
                try {
                  final picked =
                      await pickFile();

                  if (picked ==
                      null) {
                    return;
                  }

                  final Uint8List?
                      bytes =
                      picked.bytes;

                  if (bytes ==
                      null) {
                    return;
                  }

                  final firebaseFileName =
                      '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

                  final url =
                      await StorageService
                          .instance
                          .uploadWebFile(
                    bytes: bytes,
                    folder:
                        'elevations',
                    fileName:
                        firebaseFileName,
                  );

                  if (url ==
                          null ||
                      url.isEmpty) {
                    return;
                  }

                  await _elevationDao
                      .insert(
                    SiteElevationModel(
                      siteId:
                          widget
                              .site
                              .id!,
                      fileName:
                          picked.name,
                      filePath:
                          url,
                      createdAt:
                          Timestamp.now(),
                    ),
                  );
                } catch (e) {
                  debugPrint(
                    'ADD ELEVATION ERROR => $e',
                  );
                }
              },
            ),

            const SizedBox(
              height: 30,
            ),

            ElevatedButton.icon(
              icon:
                  const Icon(
                Icons.edit,
              ),

              label: const Text(
                'Edit Site',
              ),

              onPressed:
                  () async {
                final navigator =
                    Navigator.of(
                  context,
                );

                final changed =
                    await navigator
                        .push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SiteFormPage(
                      site: site,
                    ),
                  ),
                );

                if (!mounted) {
                  return;
                }

                if (changed ==
                    true) {
                  navigator.pop(
                    true,
                  );
                }
              },
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton.icon(
              icon:
                  const Icon(
                Icons.delete,
              ),

              label: isDeleting
                  ? const Text(
                      'Deleting...',
                    )
                  : const Text(
                      'Delete Site',
                    ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              onPressed:
                  isDeleting
                      ? null
                      : _deleteSite,
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // DELETE SITE
  // =========================

  Future<void> _deleteSite() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title:
                const Text(
              'Delete Site',
            ),
            content:
                const Text(
              'Are you sure you want to delete this site?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child:
                    const Text(
                  'Cancel',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child:
                    const Text(
                  'Delete',
                ),
              ),
            ],
          ),
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      await _dao.deleteSite(
        widget.site.id!,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      debugPrint(
        'DELETE SITE ERROR => $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  // =========================
  // ADD AGREEMENT
  // =========================

  Future<void> _addAgreement() async {
    try {
      final result =
          await FilePicker.platform
              .pickFiles(
        withData: true,
        type:
            FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
        ],
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final picked =
          result.files.first;

      final Uint8List? bytes =
          picked.bytes;

      if (bytes == null) {
        return;
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

      final url =
          await StorageService
              .instance
              .uploadWebFile(
        bytes: bytes,
        folder:
            'agreements',
        fileName: fileName,
      );

      if (url == null ||
          url.isEmpty) {
        return;
      }

      final agreement =
          SiteAgreementModel(
        siteId:
            widget.site.id!,
        filePath: url,
        fileName:
            picked.name,
        createdAt:
            Timestamp.now(),
      );

      await _agreementDao
          .insertAgreement(
        agreement,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Agreement uploaded',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'ADD AGREEMENT ERROR => $e',
      );
    }
  }

  // =========================
  // ROW
  // =========================

  Widget _row(
    String label,
    String? value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Text(
        '$label : ${value ?? '-'}',
        style:
            const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  // =========================
  // OWNER PHONE
  // =========================

  Widget _ownerPhoneRow() {
    final phone =
        widget.site.ownerPhone;

    if (phone == null ||
        phone.isEmpty) {
      return _row(
        'Owner Phone',
        '-',
      );
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Owner Phone : $phone',
              style:
                  const TextStyle(
                fontSize: 16,
              ),
            ),
          ),

          IconButton(
            icon:
                const Icon(
              Icons.call,
              color:
                  Colors.green,
            ),
            onPressed:
                () async {
              final uri =
                  Uri.parse(
                'tel:$phone',
              );

              await launchUrl(
                uri,
              );
            },
          ),
        ],
      ),
    );
  }
}