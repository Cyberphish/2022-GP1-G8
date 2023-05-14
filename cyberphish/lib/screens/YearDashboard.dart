// ignore_for_file: prefer_const_literals_to_create_immutables,, file_names

import '../style/appStyles.dart';
import '../style/sizeConfiguration.dart';
import 'package:d_chart/d_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Year dashBoard screen, displays when the user requests "This year" report.
// it retrieves this year's user data from firebase and present it to the user in the report screen.
class YearDashboard extends StatefulWidget {
  const YearDashboard(
      {super.key,
      required this.totalphishy,
      required this.totalLegitmate,
      required this.yearlyLegitmateMap,
      required this.yearlyphishingMap,
      required this.yearlyTriggerMap,
      required this.yearlySenderEmail});
  final double totalphishy;
  final double totalLegitmate;
  final Map<double, double> yearlyLegitmateMap;
  final Map<double, double> yearlyphishingMap;
  final Map<String, dynamic> yearlyTriggerMap;
  final String yearlySenderEmail;

  @override
  State<YearDashboard> createState() => _YearDashboard();
}

class _YearDashboard extends State<YearDashboard> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // linear graph data
    double maxValue = widget.yearlyLegitmateMap.values.last.toDouble();
    List<FlSpot> phishingspotList = [
      FlSpot(widget.yearlyphishingMap[0]!, widget.yearlyphishingMap[0]!)
    ];
    for (var i = 1; i < widget.yearlyphishingMap.length; i++) {
      try {
        phishingspotList.add(FlSpot(widget.yearlyphishingMap.keys.elementAt(i),
            widget.yearlyphishingMap.values.elementAt(i)));
        if (widget.yearlyphishingMap.values.elementAt(i) > maxValue) {
          maxValue = widget.yearlyphishingMap.values.elementAt(i);
        }
      } catch (e) {
        debugPrint('Error year $e');
      }
    }
    List<FlSpot> legitmatespotList = [
      FlSpot(widget.yearlyLegitmateMap[0]!, widget.yearlyLegitmateMap[0]!)
    ];
    for (var i = 1; i < widget.yearlyLegitmateMap.length; i++) {
      try {
        legitmatespotList.add(FlSpot(
            widget.yearlyLegitmateMap.keys.elementAt(i),
            widget.yearlyLegitmateMap.values.elementAt(i)));
        if (widget.yearlyLegitmateMap.values.elementAt(i) > maxValue) {
          maxValue = widget.yearlyLegitmateMap.values.elementAt(i);
        }
      } catch (e) {
        debugPrint('Error year $e');
      }
    }

    // insights data
    List insights = [
      {
        "icon": Icons.warning,
        "color": kPrimaryColor,
        "lable": "Most phishy sender",
        "content": widget.yearlySenderEmail,
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
        "percent": widget.yearlyTriggerMap['link'] ?? 0,
      },
      {
        "trigger": 'words',
        "percent": widget.yearlyTriggerMap['language'] ?? 0,
      },
      {
        "trigger": 'sender address',
        "percent": widget.yearlyTriggerMap['sender'] ?? 0,
      }
    ];

    // ui design
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          width: double.infinity,
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
                            minX: 0,
                            maxX: widget.yearlyLegitmateMap.keys.last,
                            minY: 0,
                            maxY: maxValue + 10,
                            backgroundColor: kBackgroundColor,
                            lineBarsData: [
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
                                  if (value == 1) {
                                    text = "Jan";
                                  }

                                  if (value == 4) {
                                    text = "Apr";
                                  }

                                  if (value == 7) {
                                    text = "July";
                                  }

                                  if (value == 10) {
                                    text = "Oct";
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
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kBackgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
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
