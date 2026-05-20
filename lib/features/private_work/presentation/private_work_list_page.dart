import 'package:flutter/material.dart';

import '../data/private_work_dao.dart';
import '../data/private_work_model.dart';

import 'add_edit_private_work_page.dart';
import 'private_work_details_page.dart';

class PrivateWorkListPage
    extends StatefulWidget {

  const PrivateWorkListPage({
    super.key,
  });

  @override
  State<PrivateWorkListPage>
      createState() =>
          _PrivateWorkListPageState();
}

class _PrivateWorkListPageState
    extends State<
        PrivateWorkListPage> {

  final PrivateWorkDao _dao =
      PrivateWorkDao();

  List<PrivateWork> works = [];

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

      works = data;

    } catch (e) {

      debugPrint(
        'PRIVATE WORK LOAD ERROR => $e',
      );

    } finally {

      loading = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  List<PrivateWork>
      get filteredWorks {

    if (searchText
        .trim()
        .isEmpty) {

      return works;
    }

    final query =
        searchText
            .trim()
            .toLowerCase();

    return works.where((work) {

      return work.workerName
                  .toLowerCase()
                  .contains(query) ||

          work.workType
              .toLowerCase()
              .contains(query) ||

          work.siteName
              .toLowerCase()
              .contains(query) ||

          work.status
              .toLowerCase()
              .contains(query);

    }).toList();
  }

  Color _statusColor(
    String status,
  ) {

    switch (
        status.toLowerCase()) {

      case 'active':
        return Colors.green;

      case 'completed':
        return Colors.blue;

      case 'pending':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    final filtered =
        filteredWorks;

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          'Private Works',
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
                  const AddEditPrivateWorkPage(),
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
                          'Search private work...',

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
                            'No private works found',
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

                              final work =
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
                                        _statusColor(
                                      work.status,
                                    ),

                                    child:
                                        const Icon(
                                      Icons.work,
                                      color:
                                          Colors.white,
                                    ),
                                  ),

                                  title:
                                      Text(

                                    work.workerName,

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
                                        work.workType,
                                      ),

                                      Text(
                                        work.siteName,
                                      ),

                                      Text(
                                        'Status: ${work.status}',
                                      ),
                                    ],
                                  ),

                                  trailing:
                                      Row(

                                    mainAxisSize:
                                        MainAxisSize.min,

                                    children: [

                                      Icon(

                                        Icons.circle,

                                        size: 12,

                                        color:
                                            _statusColor(
                                          work.status,
                                        ),
                                      ),

                                      IconButton(

                                        icon:
                                            const Icon(
                                          Icons.edit,
                                        ),

                                        onPressed:
                                            () async {

                                          final ok =
                                              await Navigator.push(
                                            context,

                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AddEditPrivateWorkPage(
                                                work:
                                                    work,
                                              ),
                                            ),
                                          );

                                          if (ok ==
                                              true) {

                                            load();
                                          }
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
                                            PrivateWorkDetailsPage(
                                          work:
                                              work,
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