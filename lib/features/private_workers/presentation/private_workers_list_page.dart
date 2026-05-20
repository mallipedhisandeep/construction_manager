import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/private_worker_dao.dart';
import '../data/private_worker_model.dart';

import 'add_edit_private_worker_page.dart';
import 'private_worker_details_page.dart';

class PrivateWorkersListPage
    extends StatefulWidget {

  const PrivateWorkersListPage({
    super.key,
  });

  @override
  State<PrivateWorkersListPage>
      createState() =>
          _PrivateWorkersListPageState();
}

class _PrivateWorkersListPageState
    extends State<
        PrivateWorkersListPage> {

  final PrivateWorkerDao _dao =
      PrivateWorkerDao();

  List<PrivateWorker> workers = [];

  bool loading = true;

  final TextEditingController
      searchController =
      TextEditingController();

  String searchText = '';

  @override
  void initState() {

    super.initState();

    load();
  }

  @override
  void dispose() {

    searchController.dispose();

    super.dispose();
  }

  Future<void> load() async {

    try {

      final data =
          await _dao.getAll();

      workers = data;

    } catch (e) {

      debugPrint(
        'PRIVATE WORKERS LOAD ERROR => $e',
      );

    } finally {

      loading = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> callWorker(
    String phone,
  ) async {

    final uri =
        Uri.parse(
      'tel:$phone',
    );

    await launchUrl(uri);
  }

  List<PrivateWorker>
      get filteredWorkers {

    if (searchText
        .trim()
        .isEmpty) {

      return workers;
    }

    final query =
        searchText
            .trim()
            .toLowerCase();

    return workers.where((worker) {

      return worker.name
                  .toLowerCase()
                  .contains(query) ||

          worker.workType
              .toLowerCase()
              .contains(query) ||

          worker.phone
              .toLowerCase()
              .contains(query);

    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final filtered =
        filteredWorkers;

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          'Private Workers',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        child:
            const Icon(
          Icons.add,
        ),

        onPressed:
            () async {

          final ok =
              await Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const AddEditPrivateWorkerPage(),
            ),
          );

          if (ok == true) {
            load();
          }
        },
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Column(

              children: [

                Padding(

                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  child: TextField(

                    controller:
                        searchController,

                    decoration:
                        InputDecoration(

                      hintText:
                          'Search worker...',

                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),

                    onChanged: (value) {

                      setState(() {
                        searchText =
                            value;
                      });
                    },
                  ),
                ),

                Expanded(

                  child: filtered.isEmpty

                      ? const Center(
                          child: Text(
                            'No private workers found',
                          ),
                        )

                      : RefreshIndicator(

                          onRefresh: load,

                          child: ListView.builder(

                            padding:
                                const EdgeInsets.only(
                              bottom: 100,
                            ),

                            itemCount:
                                filtered.length,

                            itemBuilder:
                                (_, index) {

                              final worker =
                                  filtered[index];

                              return Card(

                                margin:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                child: ListTile(

                                  leading:
                                      CircleAvatar(

                                    backgroundColor:
                                        Colors.deepPurple,

                                    child: Text(

                                      worker.name
                                              .isNotEmpty

                                          ? worker
                                              .name[0]
                                              .toUpperCase()

                                          : '?',

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  title:
                                      Text(

                                    worker.name,

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  subtitle:
                                      Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [

                                      Text(
                                        worker.workType,
                                      ),

                                      if (worker.phone
                                          .isNotEmpty)

                                        Text(
                                          worker.phone,
                                        ),
                                    ],
                                  ),

                                  trailing:
                                      Row(

                                    mainAxisSize:
                                        MainAxisSize.min,

                                    children: [

                                      if (worker.phone
                                          .isNotEmpty)

                                        IconButton(

                                          icon:
                                              const Icon(
                                            Icons.call,
                                            color:
                                                Colors.green,
                                          ),

                                          onPressed: () {

                                            callWorker(
                                              worker.phone,
                                            );
                                          },
                                        ),

                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                    ],
                                  ),

                                  onTap:
                                      () async {

                                    final changed =
                                        await Navigator.push(
                                      context,

                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PrivateWorkerDetailsPage(
                                          worker:
                                              worker,
                                        ),
                                      ),
                                    );

                                    if (changed ==
                                        true) {

                                      load();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}