// ignore_for_file: depend_on_referenced_packages, prefer_typing_uninitialized_variables, sort_child_properties_last, file_names

import '../style/appStyles.dart';
import '../style/sizeConfiguration.dart';
import 'package:cyberphish/screens/MonthDashboard.dart';
import 'package:cyberphish/screens/WeekDashboard.dart';
import 'package:cyberphish/screens/YearDashboard.dart';
import 'package:cyberphish/screens/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Report screen, where user's data retrived.
// it has a botton for the user to choose whether to display (this year, month, week) dashboard.
// it shows by default this year's dashboard. dashboard is replaced based on the user's choice.
class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.user,
  });

  final GoogleSignInAccount user;
  @override
  State<ReportScreen> createState() => _ReportScreen();
}

class _ReportScreen extends State<ReportScreen> {
  final firestore = FirebaseFirestore.instance;

  List<bool> isSelected = [true, false, false];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SizeConfig().init(context);

    // initialize required variables for the report.
    double yearlyTotalPhishy = 0;
    double yearlyTotalLegitmate = 0;
    double monthlyTotalPhishy = 0;
    double monthlyTotalLegitmate = 0;
    double weeklyTotalPhishy = 0;
    double weeklyTotalLegitmate = 0;
    Map<dynamic, dynamic>? map;

    Map<double, double> yearlyLegitmateMap = {0: 0};
    Map<double, double> yearlyphishingMap = {0: 0};
    Map<double, double> monthlyLegitmateMap = {0: 0};
    Map<double, double> monthlyphishingMap = {0: 0};
    Map<double, double> weeklyLegitmateMap = {0: 0};
    Map<double, double> weeklyphishingMap = {0: 0};

    Map<String, dynamic> yearlyTriggerMap = {};
    Map<String, dynamic> monthlyTriggerMap = {};
    Map<String, dynamic> weeklyTriggerMap = {' ': 0};

    String yearlySenderEmail = '';
    String monthlySenderEmail = '';
    String weeklySenderEmail = '';

    // ui design
    // retrieving and updating user's data to be shown in the report as stream (real time syncying).
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: kPrimaryColor,
                      padding: const EdgeInsets.only(top: 25),
                      width: size.width,
                      child: IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        color: kWhiteColor,
                        onPressed: () {
                          showAlertDialog(context, widget.user);
                        },
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                        alignment: Alignment.bottomLeft,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      color: kPrimaryColor,
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: Text(
                        'Analytical report',
                        style: kJakartaHeading1.copyWith(
                          color: kWhiteColor,
                          fontSize: SizeConfig.blockSizeHorizontal! * kHeading1,
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 30,
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -10, 0),
              // user loged in, user's info extracted, stored in the firebase, and analyzed.
              // retriving the loged in user's data to display it in the report page.
              // we are using StreamBuilder so that any new stored data will be automatically displayed. (real time syncing).
              child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                    .collection("GoogleSignInAccount")
                    .doc(widget.user.id)
                    .collection("report")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No Reports yet!'));
                  }
                  final reports = snapshot.data!.docs.toList();
                  // retriving this year's data, and updating the initialized year related variables.
                  int yearlyPhishing = 0;
                  int yearlyLegitmate = 0;
                  for (var year in reports) {
                    yearlyPhishing = year.get('totalY${year.id}')['phishing'];
                    yearlyLegitmate = year.get('totalY${year.id}')['legitmate'];
                    yearlyTotalPhishy = yearlyPhishing.toDouble();
                    yearlyTotalLegitmate = yearlyLegitmate.toDouble();
                    yearlyTriggerMap =
                        year.get('totalY${year.id}')['triggersMap'];
                    yearlySenderEmail =
                        year.get('totalY${year.id}')['senderEmail'];
                    map = year.data() as Map?;

                    // retriving this month's data, and updating the initialized month related variables.
                    int monthlyPhishing = 0;
                    int monthlyLegitmate = 0;
                    double monthId;
                    for (var month in map!.keys) {
                      if (month != 'totalY${year.id}' &&
                          year.id == '${DateTime.now().year}') {
                        monthId = double.parse(month);
                        if (year.get(month)['totalM$month']['phishing'] !=
                            null) {
                          monthlyPhishing =
                              year.get(month)['totalM$month']['phishing'];
                          yearlyphishingMap[monthId] =
                              monthlyPhishing.toDouble();
                        }
                        if (year.get(month)['totalM$month']['legitmate'] !=
                            null) {
                          monthlyLegitmate =
                              year.get(month)['totalM$month']['legitmate'];

                          yearlyLegitmateMap[monthId] =
                              monthlyLegitmate.toDouble();
                        }
                        if (month == '${DateTime.now().month}') {
                          // find the total of this month
                          monthlyTriggerMap =
                              year.get(month)['totalM$month']['triggersMap'];
                          monthlySenderEmail =
                              year.get(month)['totalM$month']['senderEmail'];

                          monthlyTotalLegitmate =
                              yearlyLegitmateMap[monthId] ?? 0;
                          monthlyTotalPhishy = yearlyphishingMap[monthId] ?? 0;
                        }

                        // get the number of the current (real time) day. then gets the week number accordingly.
                        var weeknum = 0;
                        var today = DateTime.now().day;
                        var dayStart = 0;
                        if (today <= 7) {
                          weeknum = 1;
                          dayStart = 1;
                        } else if (today > 7 && today <= 14) {
                          weeknum = 2;
                          dayStart = 8;
                        } else if (today > 14 && today <= 21) {
                          weeknum = 3;
                          dayStart = 15;
                        } else if (today > 21 && today <= 31) {
                          weeknum = 4;
                          dayStart = 22;
                        }

                        // retriving this week's data, and updating the initialized week related variables.
                        for (int week = 1; week <= weeknum; week++) {
                          // starting from first week to the current week
                          int weeklyPhishing = 0;
                          int weeklyLegitmate = 0;
                          double weekId = week.toDouble();
                          try {
                            if (year.get(month)['w$week'] != null &&
                                month == '${DateTime.now().month}') {
                              // make sure not null and in the current month, in current week
                              if (year.get(month)['w$week']['totalW$week']
                                      ['legitmate'] !=
                                  null) {
                                weeklyLegitmate = year.get(month)['w$week']
                                    ['totalW$week']['legitmate'];
                                monthlyLegitmateMap[weekId] =
                                    weeklyLegitmate.toDouble();
                              }
                              if (year.get(month)['w$week']['totalW$week']
                                      ['phishing'] !=
                                  null) {
                                weeklyPhishing = year.get(month)['w$week']
                                    ['totalW$week']['phishing'];
                                monthlyphishingMap[weekId] =
                                    weeklyPhishing.toDouble();
                              }
                            }
                            if (week == weeknum) {
                              // find the total of this month
                              weeklyTriggerMap = year.get(month)['w$weeknum']
                                  ['totalW$weeknum']['triggersMap'];
                              weeklySenderEmail = year.get(month)['w$weeknum']
                                  ['totalW$weeknum']['senderEmail'];
                              weeklyTotalLegitmate =
                                  monthlyLegitmateMap[weeknum]!;
                              weeklyTotalPhishy = monthlyphishingMap[weeknum]!;
                            }
                          } catch (e) {
                            debugPrint('Error $e');
                          }
                          for (dayStart; dayStart <= today; dayStart++) {
                            //start from first day of the week to the current day
                            int dailyPhishing = 0;
                            int dailyLegitmate = 0;
                            double dayId = dayStart.toDouble();
                            try {
                              if (year.get(month)['w$weeknum'] != null &&
                                  month == '${DateTime.now().month}') {
                                if (year.get(month)['w$weeknum']['$dayStart'] !=
                                    null) {
                                  dailyLegitmate = year.get(month)['w$weeknum']
                                      ['$dayStart']['legitmate'];
                                  weeklyLegitmateMap[dayId] =
                                      dailyLegitmate.toDouble();
                                } else {
                                  weeklyLegitmateMap[dayId] = 0;
                                }
                                if (year.get(month)['w$weeknum']['$dayStart'] !=
                                    null) {
                                  dailyPhishing = year.get(month)['w$weeknum']
                                      ['$dayStart']['phishing'];
                                  weeklyphishingMap[dayId] =
                                      dailyPhishing.toDouble();
                                } else {
                                  weeklyphishingMap[dayId] = 0;
                                }
                              }
                            } catch (e) {
                              debugPrint('Error $e');
                            }
                          }
                        }
                      }
                    }
                  }

                  // botton widget for the user to choose which dashboard to display (This Year, month, or week).
                  Widget botton = Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kBackgroundColor,
                    ),
                    child: ToggleButtons(
                      splashColor: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                      renderBorder: false,
                      isSelected: isSelected,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "This year",
                            style: kJakartaBodyRegular.copyWith(
                              fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                              color: kDarkColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "This month",
                            style: kJakartaBodyRegular.copyWith(
                              fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                              color: kDarkColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "This week",
                            style: kJakartaBodyRegular.copyWith(
                              fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                              color: kDarkColor,
                            ),
                          ),
                        ),
                      ],
                      onPressed: (int newIndex) {
                        setState(
                          () {
                            for (int index = 0;
                                index < isSelected.length;
                                index++) {
                              if (index == newIndex) {
                                isSelected[index] = true;
                              } else {
                                isSelected[index] = false;
                              }
                            }
                          },
                        );
                      },
                    ),
                  );

                  // dashboard to be displayed is initialy this year's. then it changes acoording to users' choice.
                  Widget dashboard = YearDashboard(
                      totalLegitmate: yearlyTotalLegitmate,
                      totalphishy: yearlyTotalPhishy,
                      yearlyLegitmateMap: yearlyLegitmateMap,
                      yearlyphishingMap: yearlyphishingMap,
                      yearlyTriggerMap: yearlyTriggerMap,
                      yearlySenderEmail: yearlySenderEmail);

                  // changing the dashboard to be displayed according to user's choice.
                  // sending the required data to that dashboard screen.
                  if (isSelected[0] == true) {
                    dashboard = YearDashboard(
                        totalLegitmate: yearlyTotalLegitmate,
                        totalphishy: yearlyTotalPhishy,
                        yearlyLegitmateMap: yearlyLegitmateMap,
                        yearlyphishingMap: yearlyphishingMap,
                        yearlyTriggerMap: yearlyTriggerMap,
                        yearlySenderEmail: yearlySenderEmail);
                  } else if (isSelected[1] == true) {
                    dashboard = MonthDashboard(
                      totalphishy: monthlyTotalPhishy,
                      totalLegitmate: monthlyTotalLegitmate,
                      monthlyLegitmateMap: monthlyLegitmateMap,
                      monthlyphishingMap: monthlyphishingMap,
                      monthlyTriggerMap: monthlyTriggerMap,
                      monthlySenderEmail: monthlySenderEmail,
                    );
                  } else {
                    dashboard = WeekDashboard(
                      totalphishy: weeklyTotalPhishy,
                      totalLegitmate: weeklyTotalLegitmate,
                      weeklyLegitmateMap: weeklyLegitmateMap,
                      weeklyphishingMap: weeklyphishingMap,
                      weeklyTriggerMap: weeklyTriggerMap,
                      weeklySenderEmail: weeklySenderEmail,
                    );
                  }

                  // ui design
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      botton,
                      const SizedBox(
                        height: 25,
                      ),
                      dashboard,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
