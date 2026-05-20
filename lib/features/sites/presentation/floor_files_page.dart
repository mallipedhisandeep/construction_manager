import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/storage_service.dart';

import '../data/site_floor_file_dao.dart';
import '../data/site_floor_file_model.dart';

class FloorFilesPage extends StatefulWidget {
  final String siteId;

  final int floorNo;

  final String floorName;

  const FloorFilesPage({
    super.key,
    required this.siteId,
    required this.floorNo,
    required this.floorName,
  });

  @override
  State<FloorFilesPage> createState() =>
      _FloorFilesPageState();
}

class _FloorFilesPageState
    extends State<FloorFilesPage> {
  final SiteFloorFileDao _dao =
      SiteFloorFileDao();

  bool isUploading = false;

  Future<void> _addFile() async {
    try {
      setState(() {
        isUploading = true;
      });

      final count =
          await _dao.countFiles(
        widget.siteId,
        widget.floorNo,
      );

      if (count >= 4) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Only 4 files allowed per floor',
            ),
          ),
        );

        return;
      }

      final result =
          await FilePicker.platform
              .pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.any,
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final pickedFile =
          result.files.single;

      final bytes =
          pickedFile.bytes;

      if (bytes == null) {
        return;
      }

      final firebaseFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

      final url =
          await StorageService.instance
              .uploadWebFile(
        bytes: bytes,
        folder: 'floor_files',
        fileName:
            firebaseFileName,
      );

      if (url == null) {
        return;
      }

      final model =
          SiteFloorFileModel(
        siteId:
            widget.siteId,
        floorNo:
            widget.floorNo,
        fileName:
            pickedFile.name,
        filePath: url,
        uploadedAt:
            Timestamp.now(),
      );

      await _dao.insert(
        model,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'File uploaded',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'ADD FLOOR FILE ERROR => $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _delete(
    SiteFloorFileModel file,
  ) async {
    try {
      await StorageService.instance
          .deleteFile(
        file.filePath,
      );

      await _dao.delete(
        file.id!,
      );
    } catch (e) {
      debugPrint(
        'DELETE FLOOR FILE ERROR => $e',
      );
    }
  }

  Future<void> _openFile(
    String url,
  ) async {
    final uri =
        Uri.parse(url);

    await launchUrl(uri);
  }

  String _formatTimestamp(
    Timestamp? timestamp,
  ) {
    if (timestamp == null) {
      return '-';
    }

    final date =
        timestamp.toDate();

    return
        '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.floorName),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed:
            isUploading
                ? null
                : _addFile,

        child: isUploading
            ? const SizedBox(
                height: 22,
                width: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.upload_file,
              ),
      ),

      body:
          StreamBuilder<
              List<
                  SiteFloorFileModel>>(
        stream: _dao.watchFiles(
          widget.siteId,
          widget.floorNo,
        ),

        builder:
            (context, snapshot) {
          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final files =
              snapshot.data ?? [];

          if (files.isEmpty) {
            return const Center(
              child: Text(
                'No files uploaded for this floor',
              ),
            );
          }

          return ListView.builder(
            itemCount:
                files.length,

            itemBuilder:
                (_, i) {
              final file =
                  files[i];

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                child: ListTile(
                  leading:
                      const Icon(
                    Icons
                        .insert_drive_file,
                  ),

                  title: Text(
                    file.fileName,
                  ),

                  subtitle: Text(
                    'Uploaded: '
                    '${_formatTimestamp(file.uploadedAt)}',
                  ),

                  onTap: () {
                    _openFile(
                      file.filePath,
                    );
                  },

                  trailing:
                      IconButton(
                    icon:
                        const Icon(
                      Icons.delete,
                      color:
                          Colors.red,
                    ),

                    onPressed: () {
                      _delete(file);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}