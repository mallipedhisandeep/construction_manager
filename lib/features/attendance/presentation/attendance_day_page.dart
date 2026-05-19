import 'package:flutter/material.dart';

import '../../workers/data/worker_model.dart';
import '../../workers/data/worker_dao.dart';

import '../../sites/data/site_model.dart';
import '../../sites/data/site_dao.dart';

import '../data/attendance_dao.dart';
import '../data/attendance_model.dart';
import '../data/attendance_month_summary.dart';

class AttendanceDayPage extends StatefulWidget {

  final int year;

  final int monthIndex;

  final String monthName;

  const AttendanceDayPage({
    super.key,
    required this.year,
    required this.monthIndex,
    required this.monthName,
  });

  @override
  State<AttendanceDayPage> createState() =>
      _AttendanceDayPageState();
}

class _AttendanceDayPageState
    extends State<AttendanceDayPage> {

  int selectedDay = 1;

  final WorkerDao _workerDao =
      WorkerDao();

  final SiteDao _siteDao =
      SiteDao();

  final AttendanceDao _attendanceDao =
      AttendanceDao();

  List<WorkerModel> workers = [];

  List<SiteModel> sites = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _fixSelectedDay();

    loadData();
  }

  // ==============================
  // LOAD DATA
  // ==============================

  Future<void> loadData() async {

    try {

      final loadedWorkers =
          await _workerDao.getAllWorkers();

      final loadedSites =
          await _siteDao.getAllSites();

      setState(() {

        workers = loadedWorkers;

        sites = loadedSites;

        isLoading = false;
      });

    } catch (e) {

      debugPrint(
        'Attendance load error: $e',
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  // ==============================
  // FIX DAY
  // ==============================

  void _fixSelectedDay() {

    final maxDay =
        DateUtils.getDaysInMonth(
      widget.year,
      widget.monthIndex + 1,
    );

    if (selectedDay > maxDay) {
      selectedDay = maxDay;
    }
  }

  // ==============================
  // WAGE CALCULATION
  // ==============================

  double _wage(
    WorkerModel worker,
    String type,
  ) {

    switch (type) {

      case '6-6':
        return worker.rate6to6;

      case '10-6':
        return worker.rate10to6;

      case '6-10':
        return worker.rate6to10;

      case '6-2':
        return worker.rate6to2;

      case '10-2':
        return worker.rate10to2;

      case '2-6':
        return worker.rate2to6;

      default:
        return 0;
    }
  }

  // ==============================
  // BALANCE TEXT
  // ==============================

  String getBalanceText(
    double balance,
  ) {

    if (balance > 0) {

      return
          'Balance to be given : '
          '₹${balance.toStringAsFixed(0)}';

    } else if (balance < 0) {

      return
          'Balance to be recieved : '
          '₹${balance.abs().toStringAsFixed(0)}';

    } else {

      return 'All settled';
    }
  }

  // ==============================
  // UI
  // ==============================

  @override
  Widget build(BuildContext context) {

    _fixSelectedDay();

    final totalDays =
        DateUtils.getDaysInMonth(
      widget.year,
      widget.monthIndex + 1,
    );

    return Scaffold(

      appBar: AppBar(
        title: Text(
          '${widget.monthName} '
          '${widget.year}',
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Row(
              children: [

                // ==================
                // LEFT DAYS
                // ==================

                SizedBox(
                  width: 70,

                  child: ListView.builder(

                    itemCount: totalDays,

                    itemBuilder:
                        (context, index) {

                      final day =
                          index + 1;

                      return Padding(

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 4,
                        ),

                        child: ChoiceChip(

                          label:
                              Text('$day'),

                          selected:
                              selectedDay ==
                                  day,

                          onSelected: (_) {

                            setState(() {
                              selectedDay =
                                  day;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                const VerticalDivider(
                  width: 1,
                ),

                // ==================
                // RIGHT WORKERS
                // ==================

                Expanded(
                  child: RefreshIndicator(

                    onRefresh: loadData,

                    child: ListView(
                      children:
                          _buildGroupedWorkers(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ==============================
  // GROUP WORKERS
  // ==============================

  List<Widget>
      _buildGroupedWorkers() {

    final workTypes = [
      'Centring',
      'Brickwork',
    ];

    final states = [
      'Telangana',
      'Andhra',
      'Bihar',
    ];

    final roles = [
      'Mason',
      'Helper',
    ];

    List<Widget> widgets = [];

    for (final wt in workTypes) {

      final wtWorkers =
          workers.where(
        (w) =>
            w.workType == wt,
      ).toList();

      if (wtWorkers.isEmpty) {
        continue;
      }

      widgets.add(
        _title(wt),
      );

      for (final state in states) {

        final stateWorkers =
            wtWorkers.where(
          (w) =>
              w.state == state,
        ).toList();

        if (stateWorkers.isEmpty) {
          continue;
        }

        widgets.add(
          _subtitle(state),
        );

        for (final role in roles) {

          final roleWorkers =
              stateWorkers.where(
            (w) =>
                w.role == role,
          ).toList();

          if (roleWorkers.isEmpty) {
            continue;
          }

          widgets.add(
            Padding(

              padding:
                  const EdgeInsets.only(
                left: 16,
                top: 6,
              ),

              child: Text(
                role,

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          );

          for (final worker
              in roleWorkers) {

            widgets.add(
              _workerTile(worker),
            );
          }
        }
      }
    }

    return widgets;
  }

  // ==============================
  // TITLES
  // ==============================

  Widget _title(String title) {

    return Padding(

      padding:
          const EdgeInsets.all(8),

      child: Text(

        title,

        style: const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget _subtitle(String title) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),

      child: Text(

        title,

        style: const TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  // ==============================
  // WORKER TILE
  // ==============================

  Widget _workerTile(
    WorkerModel worker,
  ) {

    return Card(

      margin:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),

      child: ListTile(

        title:
            Text(worker.name),

        subtitle: Text(
          '${worker.workType} • '
          '${worker.role}',
        ),

        trailing: Row(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            // MONTH SUMMARY
            IconButton(

              icon: const Icon(
                Icons.bar_chart,
              ),

              onPressed: () {

                _openMonthlySummary(
                  worker,
                );
              },
            ),

            // EDIT
            IconButton(

              icon: const Icon(
                Icons.edit,
              ),

              onPressed: () {

                _openDialog(worker);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // MONTHLY SUMMARY
  // ==============================

  void _openMonthlySummary(
    WorkerModel worker,
  ) async {

    try {

      final AttendanceMonthSummary
          summary =
          await _attendanceDao
              .getMonthlySummary(

        workerId:
            worker.id!,

        year:
            widget.year,

        month:
            widget.monthIndex + 1,
      );

      if (!mounted) return;

      showDialog(

        context: context,

        builder: (_) =>
            AlertDialog(

          title: Text(
            '${worker.name} '
            '— ${widget.monthName}',
          ),

          content:
              SingleChildScrollView(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                const Text(
                  'Days Worked',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                ...summary
                    .daysByType.entries
                    .map(
                      (e) => Text(
                        '${e.key}: '
                        '${e.value} days',
                      ),
                    ),

                const Divider(),

                Text(
                  'Opening Balance: '
                  '₹${summary.openingBalance.toStringAsFixed(0)}',
                ),

                Text(
                  'Total Earned: '
                  '₹${summary.totalEarned.toStringAsFixed(0)}',
                ),

                Text(
                  'Total Taken: '
                  '₹${summary.totalAdvance.toStringAsFixed(0)}',
                ),

                const Divider(),

                Text(

                  getBalanceText(
                    summary.balance,
                  ),

                  style: TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 16,

                    color:
                        summary.balance > 0

                            ? Colors.green

                            : summary.balance <
                                    0
                                ? Colors.red
                                : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(
                  context,
                );
              },

              child:
                  const Text('Close'),
            ),
          ],
        ),
      );

    } catch (e) {

      debugPrint(
        'Summary error: $e',
      );
    }
  }

  // ==============================
  // OPEN DIALOG
  // ==============================

  void _openDialog(
    WorkerModel worker,
  ) async {

    final date = DateTime(

      widget.year,

      widget.monthIndex + 1,

      selectedDay,
    );

    final saved =
        await _attendanceDao
            .getAttendanceForDay(

      workerId:
          worker.id!,

      date: date,
    );

    String type =
        saved?.attendanceType ??
            '6-6';

    double advance =
        saved?.advance ?? 0;

    String payment =
        saved?.paymentMode ??
            'Cash';

    SiteModel? site;

    if (saved?.siteId != null &&
        sites.isNotEmpty) {

      site = sites.firstWhere(

        (s) =>
            s.id == saved!.siteId,

        orElse: () => sites.first,
      );
    }

    final advanceCtrl =
        TextEditingController(
      text:
          advance.toString(),
    );

    if (!mounted) return;

    showDialog(

      context: context,

      builder: (_) =>
          AlertDialog(

        title:
            Text(worker.name),

        content:
            SingleChildScrollView(

          child: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              // ATTENDANCE TYPE
              DropdownButtonFormField<
                  String>(

                value: type,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Attendance',
                ),

                items: const [

                  '6-6',
                  '10-6',
                  '6-10',
                  '6-2',
                  '10-2',
                  '2-6',
                  'Absent',

                ]
                    .map(
                      (e) =>
                          DropdownMenuItem(
                        value: e,
                        child:
                            Text(e),
                      ),
                    )
                    .toList(),

                onChanged: (v) {
                  type = v!;
                },
              ),

              // SITE
              DropdownButtonFormField<
                  SiteModel>(

                value: site,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Site Worked',
                ),

                items: sites
                    .map(
                      (s) =>
                          DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.siteName,
                        ),
                      ),
                    )
                    .toList(),

                onChanged: (v) {
                  site = v;
                },
              ),

              // ADVANCE
              TextField(

                controller:
                    advanceCtrl,

                keyboardType:
                    TextInputType
                        .number,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Advance (₹)',
                ),

                onChanged: (v) {

                  advance =
                      double.tryParse(v) ??
                          0;
                },
              ),

              // PAYMENT MODE
              DropdownButtonFormField<
                  String>(

                value: payment,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Payment Mode',
                ),

                items: const [

                  'Cash',
                  'Online',

                ]
                    .map(
                      (e) =>
                          DropdownMenuItem(
                        value: e,
                        child:
                            Text(e),
                      ),
                    )
                    .toList(),

                onChanged: (v) {
                  payment = v!;
                },
              ),
            ],
          ),
        ),

        actions: [

          TextButton(

            onPressed: () {
              Navigator.pop(
                context,
              );
            },

            child:
                const Text(
              'Cancel',
            ),
          ),

          ElevatedButton(

            child:
                const Text('Save'),

            onPressed: () async {

              try {

                final model =
                    AttendanceModel(

                  workerId:
                      worker.id!,

                  siteId:
                      site?.id,

                  date: date,

                  attendanceType:
                      type,

                  wage:
                      _wage(
                    worker,
                    type,
                  ),

                  advance:
                      advance,

                  paymentMode:
                      payment,

                  paymentRef:
                      null,

                  balanceAfter:
                      0,
                );

                await _attendanceDao
                    .autoMarkAbsentIfMissed(

                  workerId:
                      worker.id!,

                  currentDate:
                      date,
                );

                await _attendanceDao
                    .saveOrUpdateAttendance(
                  model,
                );

                if (mounted) {

                  Navigator.pop(
                    context,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(

                    const SnackBar(
                      content: Text(
                        'Attendance saved',
                      ),
                    ),
                  );

                  setState(() {});
                }

              } catch (e) {

                debugPrint(
                  'Attendance save error: $e',
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
              }
            },
          ),
        ],
      ),
    );
  }
}