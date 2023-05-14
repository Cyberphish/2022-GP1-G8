
// ignore_for_file: file_names, depend_on_referenced_packages, prefer_typing_uninitialized_variables

import 'package:cyberphish/model/email.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../style/appStyles.dart';
import '../style/sizeConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'bodyBuilder.dart';

// email screen that has the email sender, date, subject, content, etc.
// this page get displayed when the user wants to view a certain email by clickeng on the email card.
class EmailScreen extends StatelessWidget {
  const EmailScreen({Key? key, required this.user, required this.email})
      : super(key: key);

  final Email? email;
  final GoogleSignInAccount user;

  @override
  Scaffold build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SizeConfig().init(context);

    var keys = email!.bodyList.keys.toList()..sort();

    // convert phishy wordsPropotion to % form to make it easier for the user.
    var wordsPropotion;
    try {
      wordsPropotion = email!.wordsPropotion * 100;
      wordsPropotion = wordsPropotion
          .toString()
          .substring(0, wordsPropotion.toString().indexOf(".", 0));
    } catch (e) {
      debugPrint('Error $e');
    }

    // bool to control some email screen components visibility based on that email prediction lable.
    bool isShown = false;
    if (email!.prediction != "Legitmate") {
      isShown = true;
    }

    // ui design
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Column(
                children: [
                  Container(
                    color: kPrimaryColor,
                    padding: const EdgeInsets.only(top: 25),
                    width: size.width,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      color: kWhiteColor,
                      onPressed: () {
                        Navigator.pop(context);
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From: ${email!.senderEmail}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kJakartaHeading1.copyWith(
                              color: kWhiteColor,
                              fontSize:
                                  SizeConfig.blockSizeHorizontal! * kHeading1,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 7)),
                          Text(
                            "Date: ${email!.date['dayNumber']}/${email!.date['month']}/${email!.date['year']} At: ${email!.date['time']}", // leen backend
                            style: kJakartaBodyMedium.copyWith(
                              color: kWhiteColor,
                              fontSize:
                                  SizeConfig.blockSizeHorizontal! * kBody1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    color: kPrimaryColor,
                  ),
                ],
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
              transform: Matrix4.translationValues(0, -36, 0),
              width: size.width,
              padding: const EdgeInsets.only(
                top: 30,
                left: 10,
                right: 20,
                bottom: 30,
              ),
              margin: const EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: kBackgroundColor,
              ),
              child: Text(
                'subject: ${email!.subject}',
                textAlign: TextAlign.center,
                style: kJakartaHeading4.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                ),
                maxLines: 3,
              ),
            ),
            Visibility(
              visible: isShown,
              child: Container(
                transform: Matrix4.translationValues(0, -8, 0),
                padding: const EdgeInsets.only(
                  top: 15,
                  left: 10,
                  right: 20,
                  bottom: 15,
                ),
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kBackgroundColor,
                ),
                child: Column(
                  children: [
                    Text(
                      "Why This email was flagged as phishing?",
                      textAlign: TextAlign.center,
                      style: kJakartaHeading4.copyWith(
                        fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              size: 24,
                            ),
                            TextButton(
                              onPressed: () => _dialogBuilder(
                                  context, email!.wordsList, email!.valuesList),
                              child: SizedBox(
                                child: Text(
                                  "has a $wordsPropotion% of\nphishy words",
                                  textAlign: TextAlign.center,
                                  style: kJakartaBodyMedium.copyWith(
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.grey.shade600,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              size: 24,
                            ),
                            Text(
                              "Links are\n${email!.senderFraudScore}% risky",
                              textAlign: TextAlign.center,
                              style: kJakartaBodyMedium.copyWith(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.alternate_email_rounded,
                              size: 24,
                            ),
                            Text(
                              "Email sender\nis ${email!.linkRisk}% risky",
                              textAlign: TextAlign.center,
                              style: kJakartaBodyMedium.copyWith(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 20,
                bottom: 20,
              ),
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: kBackgroundColor,
              ),
              child: SizedBox(
                height: 1.sh - 450.h,
                // body of the email sectioned and displayed as list according to it's type.
                child: ListView.builder(
                  itemCount: email!.bodyList.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return bodyBuilder(
                        bodyList: email!.bodyList,
                        keyList: keys,
                        user: email!.user,
                        counter: ++index,
                        emailId: email!.emailId);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// dialog that shows the user the vocabulary/words that was phishy and their percentage in contributing to classifying the email as phishing.
Future<void> _dialogBuilder(BuildContext context, List words, List weight) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            24,
          ),
        ),
        scrollable: true,
        title: Text(
          'The following vocabulary contributed to classifying the email as phishing:',
          textAlign: TextAlign.center,
          style: kJakartaHeading1.copyWith(
            fontSize: SizeConfig.blockSizeHorizontal! * kHeading3,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: words.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(words[index]),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: weight.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 19.0,
                            //width: 100,
                            animationDuration: 2000,
                            percent: weight[index],
                            center: Text(
                              "${weight[index] * 100}%",
                              style: kJakartaBodyRegular.copyWith(
                                color: kWhiteColor,
                                fontSize:
                                    SizeConfig.blockSizeHorizontal! * kBody1,
                              ),
                            ),
                            barRadius: const Radius.circular(20),
                            progressColor: kPrimaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: kPrimaryColor,
                fontSize: 20,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
