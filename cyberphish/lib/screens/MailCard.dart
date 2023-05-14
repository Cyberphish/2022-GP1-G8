// ignore_for_file: depend_on_referenced_packages, file_names

import '../style/appStyles.dart';
import '../style/sizeConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:cyberphish/model/email.dart';
import 'package:get/get.dart';
import 'EmailScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:percent_indicator/percent_indicator.dart';

// mail card class resbonsible for the design of the mail card in home screen.
// home screen build a stream of this class.
// mail card screen directs the user (when clicked) to the clicked email screen.
class MailCard extends StatelessWidget {
  const MailCard({Key? key, required this.user, required this.email})
      : super(key: key);

  final Email? email;
  final GoogleSignInAccount user;

  @override
  Widget build(BuildContext context) {
    var numPercentage = double.parse(email!.percentage);
    Color color = Colors.greenAccent;

    // display message indicating that a certain email has empty bode content.
    if (email!.bodyList.isEmpty) {
      email!.bodyList['1body'] = ('Email has no body');
    }

    // set the color based on the prediction lable
    if (email!.prediction == "Low") {
      color = const Color.fromARGB(255, 244, 244, 133);
    } else if (email!.prediction == "Moderate") {
      color = const Color.fromARGB(255, 243, 191, 122);
    } else if (email!.prediction == "High") {
      color = const Color.fromARGB(255, 252, 89, 89);
    }

    // bool to control some mail card components visibilty according to its prediction lable.
    bool phish = false;
    bool legt = false;
    if (email!.prediction != "Legitmate") {
      legt = false;
      phish = true;
    }
    if (email!.prediction == "Legitmate") {
      phish = false;
      legt = true;
    }

    // ui design
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        right: 15,
      ),
      child: Container(
        margin: const EdgeInsets.only(
          left: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              // redirects the user to the email screen of the clicked card.
              onTap: () {
                Get.to(
                  () => EmailScreen(
                    email: email,
                    user: user,
                  ),
                  duration: const Duration(milliseconds: 500),
                  transition: Transition.rightToLeftWithFade,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                padding: const EdgeInsets.only(
                  top: 25,
                  left: 10,
                  right: 20,
                  bottom: 25,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kBackgroundColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          email!.senderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kJakartaBodyMedium.copyWith(
                            fontSize: SizeConfig.blockSizeHorizontal! * kBody1,
                          ),
                        ),
                        Text(
                          email!.date['day']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kJakartaBodyBold.copyWith(
                            fontSize: SizeConfig.blockSizeHorizontal! * kBody2,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                        bottom: 10,
                        left: 7,
                      ),
                    ),
                    Text(
                      email!.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kJakartaHeading4.copyWith(
                        fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                        bottom: 10,
                        left: 7,
                      ),
                    ),
                    Visibility(
                      visible: phish,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          LinearPercentIndicator(
                            width: 255,
                            animation: true,
                            lineHeight: 16.0,
                            animationDuration: 2000,
                            percent: numPercentage / 100,
                            center: Text(
                              "${email!.percentage}%",
                              style: kJakartaBodyMedium.copyWith(
                                fontSize: 13,
                              ),
                            ),
                            barRadius: const Radius.circular(20),
                            progressColor: color,
                          ),
                          Text(
                            email!.prediction,
                            style: kJakartaBodyMedium.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: legt,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            email!.prediction,
                            style: kJakartaBodyMedium.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
