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
  final _dao = PrivateWorkDao();

  List<PrivateWork> works = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    works = await _dao.getAll();

    loading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Private Works'),
      ),
      floatingActionButton:
          FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
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
          : works.isEmpty
              ? const Center(
                  child: Text(
                    'No private works',
                  ),
                )
              : ListView.builder(
                  itemCount:
                      works.length,
                  itemBuilder:
                      (_, index) {
                    final work =
                        works[index];

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          work.workerName,
                        ),
                        subtitle: Text(
                          '${work.workType} • ${work.siteName}',
                        ),
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color:
                                  work.status ==
                                          'Active'
                                      ? Colors
                                          .green
                                      : Colors
                                          .grey,
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
                                    builder:
                                        (_) =>
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
                          ],
                        ),
                        onTap: () async {
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
    );
  }
}