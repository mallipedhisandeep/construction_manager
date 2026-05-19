import 'package:flutter/material.dart';

import '../data/site_dao.dart';
import '../data/site_model.dart';

import 'site_details_page.dart';
import 'site_form_page.dart';

class SitesListPage
    extends StatefulWidget {

  const SitesListPage({
    super.key,
  });

  @override
  State<SitesListPage> createState() =>
      _SitesListPageState();
}

class _SitesListPageState
    extends State<SitesListPage> {

  final SiteDao _dao =
      SiteDao();

  List<SiteModel> sites = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    load();
  }

  // ==============================
  // LOAD SITES
  // ==============================

  Future<void> load() async {

    try {

      final loadedSites =
          await _dao.getAllSites();

      setState(() {

        sites = loadedSites;

        isLoading = false;
      });

    } catch (e) {

      debugPrint(
        'LOAD SITES ERROR => $e',
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  // ==============================
  // UI
  // ==============================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text('Sites'),
      ),

      floatingActionButton:
          FloatingActionButton(

        child:
            const Icon(Icons.add),

        onPressed: () async {

          final changed =
              await Navigator.push(

            context,

            MaterialPageRoute(
              builder: (_) =>
                  const SiteFormPage(),
            ),
          );

          if (changed == true) {
            load();
          }
        },
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : sites.isEmpty

              ? const Center(
                  child: Text(
                    'No sites added',
                  ),
                )

              : RefreshIndicator(

                  onRefresh: load,

                  child: ListView.builder(

                    itemCount:
                        sites.length,

                    itemBuilder:
                        (_, i) {

                      final site =
                          sites[i];

                      return Card(

                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: ListTile(

                          title: Text(

                            site.siteName,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle:
                              Column(

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              if (site.location !=
                                      null &&
                                  site.location!
                                      .isNotEmpty)

                                Text(
                                  site.location!,
                                ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                'Floors: '
                                '${site.floorsCount}'
                                ' | '
                                '${site.status}',
                              ),
                            ],
                          ),

                          trailing:
                              const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 16,
                          ),

                          onTap: () async {

                            final changed =
                                await Navigator.push(

                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    SiteDetailsPage(
                                  site: site,
                                ),
                              ),
                            );

                            if (changed == true) {
                              load();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}