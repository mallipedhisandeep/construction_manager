import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../data/site_floor_file_model.dart';
import '../data/site_floor_file_dao.dart';

class FloorFilesPage extends StatefulWidget {
  final int siteId;
  final int floorNo;
  final String floorName;

  const FloorFilesPage({
    super.key,
    required this.siteId,
    required this.floorNo,
    required this.floorName,
  });

  @override
  State<FloorFilesPage> createState() => _FloorFilesPageState();
}

class _FloorFilesPageState extends State<FloorFilesPage> {
  final SiteFloorFileDao _dao = SiteFloorFileDao();

  late Future<List<SiteFloorFileModel>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _filesFuture = _dao.getFiles(widget.siteId, widget.floorNo);
  }

  // ================= PICK FILE =================
  Future<void> _addFile() async {
    try {
      final count = await _dao.countFiles(widget.siteId, widget.floorNo);
      if (count >= 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only 4 files allowed per floor')),
        );
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result == null) return;

      final path = result.files.single.path;
      if (path == null) return;

      final file = File(path);

      final model = SiteFloorFileModel(
        siteId: widget.siteId,
        floorNo: widget.floorNo,
        fileName: result.files.single.name,
        filePath: file.path,
        uploadedAt: DateTime.now().toIso8601String(),
      );

      await _dao.insert(model);

      setState(() => _reload());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ================= DELETE FILE =================
  Future<void> _delete(SiteFloorFileModel f) async {
    await _dao.delete(f.id!);

    final file = File(f.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    setState(() => _reload());
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.floorName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        child: const Icon(Icons.upload_file),
      ),
      body: FutureBuilder<List<SiteFloorFileModel>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final files = snapshot.data!;

          if (files.isEmpty) {
            return const Center(
              child: Text('No files uploaded for this floor'),
            );
          }

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (_, i) {
              final f = files[i];
              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(f.fileName),
                subtitle: Text(
                  'Uploaded: ${f.uploadedAt.split("T").first}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _delete(f),
                ),
              );
            },
          );
        },
      ),
    );
  }
}