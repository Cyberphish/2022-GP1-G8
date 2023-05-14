// ignore_for_file: depend_on_referenced_packages, file_names

import '../backend/loginBackend.dart';
import '../style/appStyles.dart';
import 'package:cyberphish/model/article.dart';
import 'package:cyberphish/model/email.dart';
import 'package:cyberphish/screens/HomeScreen.dart';
import 'package:cyberphish/screens/ReportScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cyberphish/screens/AwarenessContent.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import '../style/sizeConfiguration.dart';

// this class has the components (navigation bar, chatbot, log out option).
// that should be shown in the main pages (home, awareness, and report).
class NavBar extends StatefulWidget {
  const NavBar(
      {required this.emailsList,
      required this.user,
      required this.articleList,
      Key? key})
      : super(key: key);
  final List<Email> emailsList;
  final List<Article> articleList;
  final GoogleSignInAccount user;

  @override
  State<NavBar> createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  int _selectedIndex = 0;
  var flag = false;

  @override
  Widget build(BuildContext context) {
    // List of cyberphish pages in Navigation bar
    List<Widget> pages = [
      HomeScreen(emailsList: widget.emailsList, user: widget.user),
      AwarenessContent(
        articleList: widget.articleList,
        user: widget.user,
      ),
      ReportScreen(user: widget.user),
    ];

    // ui design
    return Scaffold(
      body: Center(
        child: pages.elementAt(
            _selectedIndex), //calling the selected index which the page
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: kBackgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6),
          child: GNav(
            color: kPrimaryColor,
            activeColor: kWhiteColor,
            tabBackgroundColor: kPrimaryColor,
            gap: 8,
            padding: const EdgeInsets.all(10),
            tabs: const [
              GButton(icon: Icons.home, text: "Home"),
              GButton(
                icon: Icons.book_rounded,
                text: "Awareness",
              ),
              GButton(
                icon: Icons.area_chart,
                text: "Report",
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(
                () {
                  _selectedIndex = index;
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            dynamic conversationObject = {
              'appId': '3b1a0def678f8cccb9c44ea7dd5065d9f',
            };
            await KommunicateFlutterPlugin.buildConversation(conversationObject)
                .then((clientConversationId) {});
          } on Exception catch (e) {
            debugPrint('Error $e');
          }
        },
        backgroundColor: kWhiteColor,
        child: Image.asset(
          "assets/icons/chatbot-nobg.png",
        ),
      ),
    );
  }
}

// log out confirmation message
showAlertDialog(BuildContext context, GoogleSignInAccount user) {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        24,
      ),
    ),
    title: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "\nlog out",
          style: kJakartaHeading1.copyWith(
            fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
          ),
        ),
        Container(
          width: 105,
          alignment: Alignment.topLeft,
          child: const Divider(
            color: Colors.black,
            thickness: 0.2,
          ),
        ),
      ],
    ),
    content: Text(
      "Are you sure you want to log out?",
      textAlign: TextAlign.center,
      style: kJakartaBodyMedium.copyWith(
        fontSize: SizeConfig.blockSizeHorizontal! * kHeading3,
      ),
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "  Cancel  ",
              style: kJakartaBodyBold.copyWith(
                fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint("out");
              loginBackend().handleSignOut(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Continue",
              style: kJakartaBodyBold.copyWith(
                fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
              ),
            ),
          ),
        ],
      )
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        children: [
          alert,
          const Positioned(
            top: 211,
            left: 150,
            child: CircleAvatar(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhiteColor,
              radius: 40,
              child: Icon(
                Icons.warning_rounded,
                size: 40,
              ),
            ),
          )
        ],
      );
    },
  );
}
