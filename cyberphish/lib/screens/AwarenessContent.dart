// ignore_for_file: prefer_const_constructors, must_be_immutable, deprecated_member_use, depend_on_referenced_packages, prefer_typing_uninitialized_variables, file_names

import 'package:cyberphish/screens/ArticleCards.dart';
import 'package:cyberphish/style/sizeConfiguration.dart';
import 'package:flutter/material.dart';
import '../model/article.dart';
import '../style/appStyles.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cyberphish/screens/NavBar.dart';

// awarness content page. it has a list of article cards.
class AwarenessContent extends StatefulWidget {
  const AwarenessContent(
      {required this.articleList, Key? key, required this.user})
      : super(key: key);
  final List<Article> articleList;
  final GoogleSignInAccount user;

  @override
  State<AwarenessContent> createState() => _AwarenessContent();
}

class _AwarenessContent extends State<AwarenessContent> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SizeConfig().init(context);

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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: kPrimaryColor,
                      padding: EdgeInsets.only(top: 25),
                      width: size.width,
                      child: IconButton(
                        icon: Icon(Icons.logout_rounded),
                        color: kWhiteColor,
                        onPressed: () {
                          showAlertDialog(context, widget.user);
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
                      child: Text(
                        'Awareness content',
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
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -66, 0),
              child: SizedBox(
                height: size.height,
                // each article card will be listed to the user.
                child: ListView.builder(
                  itemCount: widget.articleList.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return ArticleCards(
                      article: widget.articleList[index],
                      user: widget.user,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
