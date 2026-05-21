import 'dart:typed_data';
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

class SiteDetailsPage extends StatefulWidget {
  final SiteModel site;
  const SiteDetailsPage({super.key, required this.site});
  @override
  State<SiteDetailsPage> createState() => _SiteDetailsPageState();
}

class _SiteDetailsPageState extends State<SiteDetailsPage> {
  final _dao = SiteDao();
  final _agreementDao = SiteAgreementDao();
  final _elevationDao = SiteElevationDao();
  bool _deleting = false;
  bool _uploadingAgreement = false;
  bool _uploadingElevation = false;

  Future<PlatformFile?> _pickFile({List<String>? extensions}) async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: extensions != null ? FileType.custom : FileType.any,
      allowedExtensions: extensions,
    );
    return result?.files.single;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final site = widget.site;
    final isActive = site.status == 'Active';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(site.siteName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary, foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () async {
            final changed = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => SiteFormPage(site: site)));
            if (changed == true && mounted) Navigator.pop(context, true);
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Site Info Card
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isActive ? Colors.green : Colors.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.location_city_rounded,
                  color: isActive ? Colors.green : Colors.blue, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(site.siteName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isActive ? Colors.green : Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                  child: Text(site.status,
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold,
                      color: isActive ? Colors.green : Colors.blue)),
                ),
              ])),
            ]),
            const Divider(height: 24),
            _infoRow(Icons.location_on_rounded, 'Location', site.location, context),
            _infoRow(Icons.person_rounded, 'Owner', site.ownerName, context),
            _ownerPhoneRow(context),
            _infoRow(Icons.calendar_today_rounded, 'Start Date', site.startDate, context),
            _infoRow(Icons.layers_rounded, 'Floors', '${site.floorsCount}', context),
            _infoRow(Icons.currency_rupee_rounded, 'Budget',
              '₹${(site.budget / 100000).toStringAsFixed(2)} Lakhs', context),
            if (site.notes != null && site.notes!.isNotEmpty)
              _infoRow(Icons.notes_rounded, 'Notes', site.notes!, context),
          ]))),
          const SizedBox(height: 16),

          // Floors Section
          _sectionHeader('Floor Plans', Icons.layers_rounded, cs),
          Card(child: ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: site.floorsCount,
            itemBuilder: (_, i) {
              final name = i == 0 ? 'Ground Floor' : 'Floor $i';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer, radius: 18,
                  child: Text('$i', style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer))),
                title: Text(name),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.folder_rounded, color: cs.primary),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ]),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => FloorFilesPage(siteId: site.id!, floorNo: i, floorName: name))),
              );
            },
          )),
          const SizedBox(height: 16),

          // Agreements
          _sectionHeader('Agreements', Icons.description_rounded, cs),
          StreamBuilder<List<SiteAgreementModel>>(
            stream: _agreementDao.watchAllBySite(site.id!),
            builder: (_, snap) {
              final list = snap.data ?? [];
              return Card(child: Column(children: [
                if (list.isEmpty) const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No agreements added', style: TextStyle(color: Colors.grey))),
                ...list.map((a) => ListTile(
                  leading: const Icon(Icons.description_rounded, color: Colors.deepOrange),
                  title: Text(a.fileName, style: const TextStyle(fontSize: 13)),
                  subtitle: Text(_formatDate(a.createdAt), style: const TextStyle(fontSize: 11)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      onPressed: () => launchUrl(Uri.parse(a.filePath), mode: LaunchMode.externalApplication)),
                    IconButton(icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                      onPressed: () async {
                        await StorageService.instance.deleteFile(a.filePath);
                        await _agreementDao.deleteAgreement(a.id!);
                      }),
                  ]),
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _uploadingAgreement
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton.icon(
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Upload Agreement'),
                        onPressed: () async {
                          setState(() => _uploadingAgreement = true);
                          try {
                            final f = await _pickFile(extensions: ['pdf','jpg','jpeg','png']);
                            if (f?.bytes == null) return;
                            final url = await StorageService.instance.uploadWebFile(
                              bytes: f!.bytes!, folder: 'agreements',
                              fileName: '${DateTime.now().millisecondsSinceEpoch}_${f.name}');
                            if (url != null) await _agreementDao.insertAgreement(
                              SiteAgreementModel(siteId: site.id!, filePath: url, fileName: f.name, createdAt: DateTime.now()));
                          } finally { if (mounted) setState(() => _uploadingAgreement = false); }
                        },
                      ),
                ),
              ]));
            },
          ),
          const SizedBox(height: 16),

          // Elevations
          _sectionHeader('Elevations', Icons.image_rounded, cs),
          StreamBuilder<List<SiteElevationModel>>(
            stream: _elevationDao.watchAllBySite(site.id!),
            builder: (_, snap) {
              final list = snap.data ?? [];
              return Card(child: Column(children: [
                if (list.isEmpty) const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No elevations added', style: TextStyle(color: Colors.grey))),
                ...list.map((e) => ListTile(
                  leading: const Icon(Icons.image_rounded, color: Colors.purple),
                  title: Text(e.fileName, style: const TextStyle(fontSize: 13)),
                  subtitle: Text(_formatDate(e.createdAt), style: const TextStyle(fontSize: 11)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      onPressed: () => launchUrl(Uri.parse(e.filePath), mode: LaunchMode.externalApplication)),
                    IconButton(icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                      onPressed: () async {
                        await StorageService.instance.deleteFile(e.filePath);
                        await _elevationDao.delete(e.id!);
                      }),
                  ]),
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _uploadingElevation
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton.icon(
                        icon: const Icon(Icons.upload_rounded),
                        label: const Text('Upload Elevation'),
                        onPressed: () async {
                          setState(() => _uploadingElevation = true);
                          try {
                            final f = await _pickFile();
                            if (f?.bytes == null) return;
                            final url = await StorageService.instance.uploadWebFile(
                              bytes: f!.bytes!, folder: 'elevations',
                              fileName: '${DateTime.now().millisecondsSinceEpoch}_${f.name}');
                            if (url != null) await _elevationDao.insert(
                              SiteElevationModel(siteId: site.id!, fileName: f.name, filePath: url, createdAt: DateTime.now()));
                          } finally { if (mounted) setState(() => _uploadingElevation = false); }
                        },
                      ),
                ),
              ]));
            },
          ),
          const SizedBox(height: 24),

          // Delete Button
          _deleting
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(width: double.infinity, child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_rounded, color: Colors.red),
                label: const Text('Delete Site', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), minimumSize: const Size(double.infinity, 48)),
                onPressed: () async {
                  final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                    title: const Text('Delete Site'),
                    content: Text('Delete ${site.siteName}? This will also delete all files, floors, and agreements.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        child: const Text('Delete')),
                    ],
                  ));
                  if (confirm == true) {
                    setState(() => _deleting = true);
                    try {
                      await _dao.deleteSite(site.id!);
                      if (mounted) Navigator.pop(context, true);
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                      setState(() => _deleting = false);
                    }
                  }
                },
              )),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, ColorScheme cs) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
    child: Row(children: [
      Icon(icon, size: 18, color: cs.primary),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _infoRow(IconData icon, String label, String? value, BuildContext context) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
      ]),
    );
  }

  Widget _ownerPhoneRow(BuildContext context) {
    final phone = widget.site.ownerPhone;
    if (phone == null || phone.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(Icons.phone_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        const Text('Phone: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(child: Text(phone, style: const TextStyle(fontWeight: FontWeight.w500))),
        IconButton(
          icon: const Icon(Icons.call_rounded, color: Colors.green, size: 20),
          onPressed: () => launchUrl(Uri.parse('tel:$phone')),
          visualDensity: VisualDensity.compact,
        ),
      ]),
    );
  }

  String _formatDate(DateTime? dt) => dt == null ? '' : '${dt.day}/${dt.month}/${dt.year}';
}
