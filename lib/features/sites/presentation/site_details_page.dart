import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  State<SiteDetailsPage> createState() =>
      _SiteDetailsPageState();
}

class _SiteDetailsPageState
    extends State<SiteDetailsPage> {

  final SiteDao _dao =
      SiteDao();

  final SiteAgreementDao
      _agreementDao =
      SiteAgreementDao();

  final SiteElevationDao
      _elevationDao =
      SiteElevationDao();

  late Future<List<SiteElevationModel>>
      _elevationFuture;

  bool isDeleting = false;

  // ==============================
  // INIT
  // ==============================

  @override
  void initState() {

    super.initState();

    _loadElevations();
  }

  void _loadElevations() {

    _elevationFuture =
        _elevationDao.getBySite(
      widget.site.id!,
    );
  }

  // ==============================
  // FILE PICKER
  // ==============================

  Future<PlatformFile?>
      pickFile() async {

    final result =
        await FilePicker.platform
            .pickFiles();

    if (result == null) {
      return null;
    }

    return result.files.single;
  }

  // ==============================
  // UI
  // ==============================

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

            // ======================
            // SITE INFO
            // ======================

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
              site.budget.toString(),
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

            FutureBuilder<
                List<
                    SiteAgreementModel>>(

              future:
                  _agreementDao
                      .getBySite(
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

                if (!snapshot
                        .hasData ||
                    snapshot.data!
                        .isEmpty) {

                  return const Text(
                    'No agreements added',
                  );
                }

                final list =
                    snapshot.data!;

                return Column(

                  children:
                      list.map(
                    (agreement) {

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

                          subtitle: Text(
                            agreement
                                .createdAt,
                          ),

                          trailing:
                              Row(

                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              IconButton(

                                icon:
                                    const Icon(
                                  Icons
                                      .open_in_new,
                                ),

                                onPressed:
                                    () async {

                                  final uri =
                                      Uri.parse(
                                    agreement
                                        .filePath,
                                  );

                                  await launchUrl(
                                    uri,
                                  );
                                },
                              ),

                              IconButton(

                                icon:
                                    const Icon(
                                  Icons
                                      .delete,
                                  color:
                                      Colors.red,
                                ),

                                onPressed:
                                    () async {

                                  await _agreementDao
                                      .deleteAgreement(
                                    agreement
                                        .id!,
                                  );

                                  setState(() {});
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
                        Text(floorName),

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

            FutureBuilder<
                List<
                    SiteElevationModel>>(

              future:
                  _elevationFuture,

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

                if (!snapshot
                        .hasData ||
                    snapshot.data!
                        .isEmpty) {

                  return const Text(
                    'No elevations added',
                  );
                }

                final list =
                    snapshot.data!;

                return Column(

                  children:
                      list.map(
                    (elevation) {

                      return Card(

                        child:
                            ListTile(

                          leading:
                              const Icon(
                            Icons.image,
                          ),

                          title: Text(

                            elevation
                                .filePath
                                .split('/')
                                .last,
                          ),

                          subtitle: Text(
                            elevation
                                .createdAt,
                          ),

                          trailing:
                              Row(

                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              IconButton(

                                icon:
                                    const Icon(
                                  Icons
                                      .open_in_new,
                                ),

                                onPressed:
                                    () async {

                                  final uri =
                                      Uri.parse(
                                    elevation
                                        .filePath,
                                  );

                                  await launchUrl(
                                    uri,
                                  );
                                },
                              ),

                              IconButton(

                                icon:
                                    const Icon(
                                  Icons
                                      .delete,
                                  color:
                                      Colors.red,
                                ),

                                onPressed:
                                    () async {

                                  await _elevationDao
                                      .delete(
                                    elevation
                                        .id!,
                                  );

                                  setState(
                                    _loadElevations,
                                  );
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
                Icons.add,
              ),

              label: const Text(
                'Add Elevation',
              ),

              onPressed: () async {

                final file =
                    await pickFile();

                if (file == null) {
                  return;
                }

                await _elevationDao
                    .insert(

                  SiteElevationModel(

                    siteId:
                        widget.site.id!,

                    filePath:
                        file.path!,

                    createdAt:
                        DateTime.now()
                            .toIso8601String(),
                  ),
                );

                setState(
                  _loadElevations,
                );
              },
            ),

            const SizedBox(
              height: 30,
            ),

            // ======================
            // EDIT SITE
            // ======================

            ElevatedButton.icon(

              icon: const Icon(
                Icons.edit,
              ),

              label: const Text(
                'Edit Site',
              ),

              onPressed: () async {

                final changed =
                    await Navigator.push(

                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        SiteFormPage(
                      site: site,
                    ),
                  ),
                );

                if (changed == true &&
                    mounted) {

                  Navigator.pop(
                    context,
                    true,
                  );
                }
              },
            ),

            const SizedBox(
              height: 10,
            ),

            // ======================
            // DELETE SITE
            // ======================

            ElevatedButton.icon(

              icon: const Icon(
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

  // ==============================
  // DELETE SITE
  // ==============================

  Future<void> _deleteSite() async {

    final confirm =
        await showDialog<bool>(

      context: context,

      builder: (_) =>
          AlertDialog(

        title:
            const Text(
          'Delete Site',
        ),

        content:
            const Text(
          'Are you sure you want '
          'to delete this site?',
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

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );

    } catch (e) {

      debugPrint(
        'DELETE SITE ERROR => $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  // ==============================
  // ADD AGREEMENT
  // ==============================

  Future<void>
      _addAgreement() async {

    final result =
        await FilePicker.platform
            .pickFiles(

      type: FileType.custom,

      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result == null) {
      return;
    }

    final file =
        result.files.first;

    final agreement =
        SiteAgreementModel(

      siteId:
          widget.site.id!,

      filePath:
          file.path!,

      fileName:
          file.name,

      createdAt:
          DateTime.now()
              .toIso8601String(),
    );

    await _agreementDao
        .insertAgreement(
      agreement,
    );

    setState(() {});
  }

  // ==============================
  // ROW
  // ==============================

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

        '$label : '
        '${value ?? '-'}',

        style:
            const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  // ==============================
  // OWNER PHONE
  // ==============================

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
              color: Colors.green,
            ),

            onPressed: () async {

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