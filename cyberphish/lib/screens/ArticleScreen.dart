// ignore_for_file: prefer_const_constructors, sort_child_properties_last, deprecated_member_use, depend_on_referenced_packages, file_names

import 'package:cyberphish/style/appStyles.dart';
import 'package:cyberphish/model/article.dart';
import 'package:cyberphish/style/sizeConfiguration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

// artical screen that has the article title, author, link, content, etc.
// this page get displayed when the user wants to view a certain article by clickeng on the email card.
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article, required this.user});
  final Article? article;
  final GoogleSignInAccount user;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // ui design
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Column(
                children: [
                  Container(
                    color: kPrimaryColor,
                    padding: EdgeInsets.only(top: 25),
                    width: size.width,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded),
                      color: kWhiteColor,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                      alignment: Alignment.bottomLeft,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                  ),
                  Container(
                    color: kPrimaryColor,
                    padding: EdgeInsets.only(left: 24, right: 24),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Title: ${article!.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kJakartaHeading1.copyWith(
                              color: kWhiteColor,
                              fontSize:
                                  SizeConfig.blockSizeHorizontal! * kHeading1,
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 7)),
                          Text(
                            "By: ${article?.author}",
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
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -36, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "Click here to  open the full article in the browser",
                          style: kJakartaHeading1.copyWith(
                            color: kDarkColor,
                            fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch('${article?.link}');
                            },
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                ],
              ),
            ),
            Container(
              height: 1.sh - 300.h,
              transform: Matrix4.translationValues(0, -36, 0),
              padding: EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
                bottom: 10,
              ),
              margin: EdgeInsets.only(top: 20),
              // width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: kBackgroundColor,
              ),
              child: WebView(
                initialUrl: "${article?.link}",
                javascriptMode: JavascriptMode.unrestricted,
                onProgress: (progress) => Text('in progress ... $progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
