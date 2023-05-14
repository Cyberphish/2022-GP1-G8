// ignore_for_file: prefer_const_literals_to_create_immutables,, file_names, unused_local_variable

import '../style/appStyles.dart';
import '../style/sizeConfiguration.dart';
import 'package:d_chart/d_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Week dashBoard screen, displays when the user requests "This week" report.
// it retrieves this week's user data from firebase and present it to the user in the report screen.
class WeekDashboard extends StatefulWidget {
  const WeekDashboard(
      {super.key,
      required this.totalphishy,
      required this.totalLegitmate,
      required this.weeklyLegitmateMap,
      required this.weeklyphishingMap,
      required this.weeklyTriggerMap,
      required this.weeklySenderEmail});
  final double totalphishy;
  final double totalLegitmate;
  final Map<double, double> weeklyLegitmateMap;
  final Map<double, double> weeklyphishingMap;
  final Map<String, dynamic> weeklyTriggerMap;
  final String weeklySenderEmail;
  @override
  State<WeekDashboard> createState() => _WeekDashboard();
}

class _WeekDashboard extends State<WeekDashboard> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // linear graph data
    double maxValue = 0;
    double numDays = 0;
    try {
      maxValue = widget.weeklyLegitmateMap.values.last.toDouble();
      numDays = widget.weeklyLegitmateMap.length.toDouble();
    } catch (e) {
      debugPrint('Error week $e');
    }
    List<FlSpot> phishingspotList = [
      FlSpot(widget.weeklyphishingMap.keys.elementAt(1) - 1, 0)
    ];
    if (widget.weeklyphishingMap.length.toInt() >= 2) {
      for (var i = 1; i < widget.weeklyphishingMap.length; i++) {
        try {
          phishingspotList.add(FlSpot(
              widget.weeklyphishingMap.keys.elementAt(i),
              widget.weeklyphishingMap.values.elementAt(i)));
          if (widget.weeklyphishingMap.values.elementAt(i) > maxValue) {
            maxValue = widget.weeklyphishingMap.values.elementAt(i);
          }
        } catch (e) {
          debugPrint('Error week $e');
        }
      }
    }
    List<FlSpot> legitmatespotList = [
      FlSpot(widget.weeklyLegitmateMap.keys.elementAt(1) - 1, 0)
    ];
    if (widget.weeklyLegitmateMap.length.toInt() >= 2) {
      for (var i = 1; i < widget.weeklyLegitmateMap.length; i++) {
        try {
          legitmatespotList.add(FlSpot(
              widget.weeklyLegitmateMap.keys.elementAt(i),
              widget.weeklyLegitmateMap.values.elementAt(i)));
          if (widget.weeklyLegitmateMap.values.elementAt(i) > maxValue) {
            maxValue = widget.weeklyLegitmateMap.values.elementAt(i);
          }
        } catch (e) {
          debugPrint('Errorweek $e');
        }
      }
    }

    // insights data
    List insights = [
      {
        "icon": Icons.warning,
        "color": kPrimaryColor,
        "lable": "Most phishy sender",
        "content": widget.weeklySenderEmail,
      },
      {
        "icon": Icons.inbox_rounded,
        "color": kPrimaryColor,
        "lable": "# of phishy emails",
        "content": "You recieved ${widget.totalphishy.toInt()} phishy email",
      }
    ];

    // Pie chart data
    List data = [
      {
        "trigger": 'Links',
        "percent": widget.weeklyTriggerMap['link'] ?? 0,
      },
      {
        "trigger": 'words',
        "percent": widget.weeklyTriggerMap['language'] ?? 0,
      },
      {
        "trigger": 'sender address',
        "percent": widget.weeklyTriggerMap['sender'] ?? 0,
      }
    ];

    // ui design
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          width: double.infinity,
          // height: 250,
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: kBackgroundColor,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "# of Phishing vs. Legitimate emails",
                      style: kJakartaBodyBold,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: size.height * 0.2,
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: size.width * 1.2,
                        child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(show: false),
                            minX:
                                widget.weeklyphishingMap.keys.elementAt(1) - 1,
                            maxX: widget.weeklyphishingMap.keys.last,
                            minY: 0,
                            maxY: maxValue + 10,
                            backgroundColor: kBackgroundColor,
                            lineBarsData: [
                              LineChartBarData(
                                spots: phishingspotList,
                                isCurved: true,
                                color: const Color.fromARGB(255, 255, 133, 127),
                                barWidth: 2,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color:
                                      const Color.fromARGB(110, 255, 133, 127),
                                ),
                                dotData: FlDotData(
                                  show: true,
                                ),
                              ),
                              LineChartBarData(
                                spots: legitmatespotList,
                                isCurved: true,
                                color: const Color.fromARGB(255, 145, 209, 144),
                                barWidth: 2,
                                belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color.fromARGB(
                                        121, 145, 209, 144)),
                                dotData: FlDotData(
                                  show: true,
                                ),
                              ),
                            ],
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: false,
                              getDrawingVerticalLine: (numMonths) {
                                return FlLine(
                                  color: Colors.grey.shade800,
                                  strokeWidth: 0.8,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                interval: 1,
                                showTitles: true,
                                reservedSize: 23,
                                getTitlesWidget: (value, meta) {
                                  String text = "";
                                  try {
                                    if (value ==
                                        widget.weeklyLegitmateMap.keys
                                            .elementAt(0)) {
                                      text = "Sun";
                                    }
                                    if (value ==
                                        widget.weeklyLegitmateMap.keys
                                            .elementAt(1)) {
                                      text = "Mon";
                                    }
                                    if (value ==
                                        widget.weeklyLegitmateMap.keys
                                            .elementAt(2)) {
                                      text = "Tue";
                                    }
                                    if (value ==
                                        widget.weeklyLegitmateMap.keys
                                            .elementAt(3)) {
                                      text = "Wed";
                                    }
                                    if (value ==
                                        widget.weeklyLegitmateMap.keys
                                            .elementAt(4)) {
                                      text = "Thur";
                                    }
                                    if (value ==
                                        widget.weeklyLegitmateMap.keys
                                            .elementAt(5)) {
                                      text = "Fri";
                                    }
                                    if (value ==
                                        widget.weeklyLegitmateMap.keys
                                            .elementAt(6)) {
                                      text = "Sat";
                                    }
                                  } catch (e) {
                                    debugPrint('week Error $e');
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4.0,
                                    ),
                                    child: Text(
                                      text,
                                      style: kJakartaBodyRegular.copyWith(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                kBody1,
                                      ),
                                    ),
                                  );
                                },
                              )),
                            ),
                          ),
                        ),
                      ),
                      //  ),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 20,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 133, 127),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        Text(
                          "  Phishing emails",
                          style: kJakartaBodyBold,
                        ),
                        const Spacer(),
                        Container(
                          width: 20,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 145, 209, 144),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        Text(
                          "  Legitimate emails",
                          style: kJakartaBodyBold,
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 30)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Wrap(
          spacing: 20,
          children: List.generate(
            insights.length,
            (index) {
              return Container(
                width: (size.width - 60) / 2,
                height: 180, // issue
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kBackgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 25),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              insights[index]['icon'],
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insights[index]['lable'],
                              style: kJakartaBodyBold.copyWith(fontSize: 12.2),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              insights[index]['content'],
                              style: kJakartaBodyRegular.copyWith(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
          width: double.infinity,
          // height: 250,
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: kBackgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(
                "Most used tactics",
                style: kJakartaBodyBold,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              SizedBox(
                height: 200,
                child: DChartPie(
                  data: data.map((e) {
                    return {'domain': e["trigger"], "measure": e["percent"]};
                  }).toList(),
                  fillColor: (pieData, index) {
                    // print('${pieData['domain']}  ${pieData['measure']}');

                    switch (pieData['domain']) {
                      case 'Links':
                        return const Color.fromARGB(255, 204, 232, 219);
                      case 'words':
                        return const Color.fromARGB(255, 193, 212, 227);
                      case 'sender address':
                        return const Color.fromARGB(255, 190, 180, 214);
                      default:
                        return const Color.fromARGB(255, 193, 212, 227);
                    }
                  },
                  labelPosition: PieLabelPosition.outside,
                  labelLineColor: Colors.grey,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 204, 232, 219),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    "Phishy\nLinks",
                    textAlign: TextAlign.center,
                    style: kJakartaBodyBold,
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 193, 212, 227),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    "Language\nused",
                    textAlign: TextAlign.center,
                    style: kJakartaBodyBold,
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 190, 180, 214),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    "Sender\naddress",
                    textAlign: TextAlign.center,
                    style: kJakartaBodyBold,
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
            ],
          ),
        ),
      ],
    );
  }
}
