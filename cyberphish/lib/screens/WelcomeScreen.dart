// ignore_for_file: file_names

import '../style/appStyles.dart';
import '../style/sizeConfiguration.dart';
import 'package:cyberphish/screens/LoginScreen.dart';
import 'package:flutter/material.dart';

// Welcome Screen, first thing that shows to the user. Helps the user to know more about the services CyberPhish provide.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WelcomeScreen();
  }
}

class _WelcomeScreen extends State<WelcomeScreen> {
  int currentIndex = 0;
  late PageController _controller;

  // welcome page content list
  List<WelcomeContent> contents = [
    WelcomeContent(
      image: 'assets/images/1.png',
      title: 'Welcome to CyberPhish',
      discription: 'Your phishing detector assistant.',
    ),
    WelcomeContent(
      image: 'assets/images/2.png',
      title: 'Who are we?',
      discription:
          'CyberPhish is a mobile application,\nthat detects phishing in emails.',
    ),
    WelcomeContent(
      image: 'assets/images/3.png',
      title: 'Our Goal',
      discription:
          'Reduce the risk of the tsunami of\nphishing attacks that threaten your emails.',
    ),
    WelcomeContent(
      image: 'assets/images/4.png',
      title: 'Ready to Prevent Phishing?',
      discription: 'let\'s go!',
    ),
  ];

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 610,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, i) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 150,
                        ),
                        Image.asset(
                          contents[i].image,
                          height: 300,
                        ),
                        Text(
                          contents[i].title,
                          style: kJakartaHeading1.copyWith(
                            fontSize:
                                SizeConfig.blockSizeHorizontal! * kHeading2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          contents[i].discription,
                          textAlign: TextAlign.center,
                          style: kJakartaBodyRegular.copyWith(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Skip",
                    style: kJakartaBodyBold.copyWith(
                      color: kPrimaryColor,
                      fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                    ),
                  ),
                ),
                const Spacer(),
                ...List.generate(
                  contents.length,
                  (index) =>
                      buildDot(index, context, isActive: index == currentIndex),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    if (currentIndex == contents.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    }
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// dots design $ builder
  AnimatedContainer buildDot(int index, BuildContext context,
      {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 300,
      ),
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isActive ? kPrimaryColor : kPrimaryColor.withOpacity(0.3),
      ),
    );
  }
}

// class for Welcome page Content
class WelcomeContent {
  String image;
  String title;
  String discription;

  WelcomeContent({
    required this.image,
    required this.title,
    required this.discription,
  });
}
