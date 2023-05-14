// ignore_for_file: , deprecated_member_use, depend_on_referenced_packages, file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/loginBackend.dart';
import '../style/appStyles.dart';
import '../style/sizeConfiguration.dart';

// Log In Screen, displayed after welcome screen.
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // ui design
    return ChangeNotifierProvider(
      create: (context) => loginBackend(),
      child: Consumer<loginBackend>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: kWhiteColor,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: kPrimaryColor,
                  padding: const EdgeInsets.only(top: 15),
                ),
                Container(
                  color: kPrimaryColor,
                  padding: const EdgeInsets.only(top: 52, left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: 200,
                              child: Image.asset(
                                  "assets/images/white-logo-horizontal-nobg.png"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 48,
                  color: kPrimaryColor,
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
                const Padding(
                  padding: EdgeInsets.only(
                    bottom: 30,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: "Your",
                        style: TextStyle(
                          fontSize: 40,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          //fontFamily: "Times new roman",
                          height: 2,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "\nPhishing Detector\nAssistant",
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: ".",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    bottom: 30,
                  ),
                ),
                Center(
                  child: MyElevatedButton(
                    width: 340,
                    onPressed: () async {
                      await model.handleSignIn();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Image(
                          image: AssetImage("assets/icons/Google_Logo.svg.png"),
                          height: 30.0,
                          width: 30,
                        ),
                        Text(
                          'Log in with Gmail',
                          style: TextStyle(
                            color: kWhiteColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "By continuing, you agree to our",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          _dialogBuilder(context), // privacy policy button
                      child: const Text(
                        'Privacy Policy.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// CyberPhish Privacy Policy
Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            24,
          ),
        ),
        title: Text(
          'CyberPhish\'s Privacy Policy: ',
          style: kJakartaBodyBold.copyWith(
            fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
          ),
          textAlign: TextAlign.center,
        ),
        content: RichText(
          text: TextSpan(
            text:
                "The CyberPhish team built the CyberPhish app as a free app. This service is provided by the CyberPhish Team at no cost and is intended for use as is. This page is used to inform users regarding our policies regarding the collection, use, and disclosure of personal information. \nIf you choose to use CyberPhish, then you agree to the collection and use of information in relation to this policy.",
            style: kJakartaBodyRegular.copyWith(
              fontSize: SizeConfig.blockSizeHorizontal! * kBody1,
              color: kDarkColor,
            ),
            children: const <TextSpan>[
              TextSpan(
                text: "\n\nThe collection of your personal information: ",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text:
                    "\n\nIn order to benefit from our service, CyberPhish requires you to provide us with certain personally identifiable information, including but not limited to your logged-in Gmail address, Gmail inbox for that account, displayed name, and the avatar for that account. The signing in mechanism is handled using: ",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n•  Gmail API.\n•  Firebase services.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n\nThe use of your personal information: ",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text:
                    "\n\nThe personal information that CyberPhish collects is used to deliver and improve the service you have requested. CyberPhish will NOT use or share your information with anyone except as described in this privacy policy.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n\nThe security of your personal data:",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text:
                    "\n\nThe security of your personal data is important to the CyberPhish team, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your personal data, we cannot guarantee its absolute security.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n\nThe processing of your personal data:",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text:
                    "\n\nThe service providers we benefit from may have access to your personal data. These third-party vendors collect, store, use, process, and transfer information about your activity on our service in accordance with their privacy policies.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n\nUsage, Performance, and Miscellaneous:",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text:
                    "\n\nThe CyberPhish team may use third-party service providers to provide better improvement of our Service.\n\n• Gmail API",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text:
                    "\nTheir privacy policy can be viewed at\nhttps://developers.google.com/gmail/api/guides",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n\n• Google Analytics for Firebase",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text:
                    "\nTheir privacy policy can be viewed at \nhttps://firebase.google.com/policies/analytics",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n\n• APIVoid",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text:
                    "\nTheir privacy policy can be viewed at \nhttps://www.apivoid.com/faqs/",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n\nLinks to other sites: ",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text:
                    "\n\nCyberPhish may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by the CyberPhish team. Therefore, I strongly advise you to review the privacy policies of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: "\n\nContact us: ",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text:
                    "\n\nIf you have any questions or suggestions about the CyberPhish privacy policy, do not hesitate to contact us at CyberPhish.gp2022@gmail.com.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
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
              Navigator.of(context).pop(); // returns to the login
            },
          ),
        ],
      );
    },
  );
}

// design the login button
class MyElevatedButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final Widget child;

  const MyElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.borderRadius,
    this.width,
    this.height = 60,
    this.gradient = const LinearGradient(
      colors: [
        kPrimaryColor, // #587A98
        Color.fromARGB(255, 39, 54, 67), // #273643
      ],
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(0);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    );
  }
}
