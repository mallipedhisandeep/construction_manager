import 'package:flutter/material.dart';
import '../data/site_dao.dart';
import '../data/site_model.dart';
import 'site_details_page.dart';
import 'site_form_page.dart';

class SitesListPage extends StatefulWidget {
  const SitesListPage({super.key});

  @override
  State<SitesListPage> createState() => _SitesListPageState();
}

class _SitesListPageState extends State<SitesListPage> {
  final _dao = SiteDao();
  List<SiteModel> sites = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    sites = await _dao.getAllSites();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sites')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SiteFormPage()),
          );
          load(); // 🔥 refresh after add
        },
      ),
      body: ListView.builder(
        itemCount: sites.length,
        itemBuilder: (_, i) {
          final site = sites[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                site.siteName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (site.location != null && site.location!.isNotEmpty)
                    Text(' ${site.location}'),
                  Text('Floors: ${site.floorsCount} | ${site.status}'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SiteDetailsPage(site: site),
                  ),
                );
                if (changed == true) load();
              },
            ),
          );
        },
      ),
    );
  }
}