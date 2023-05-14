// ignore_for_file: depend_on_referenced_packages

import 'package:cyberphish/screens/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'backend/notificationBackend.dart';
import 'style/appStyles.dart';

// CyberPhish app starts here, initialize app and firebase.
// CyberPhish starts by welcoming the user with the welcome screen.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await notificationBackend().setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (context, widget) {
          return GetMaterialApp(
              title: 'CyberPhish',
              theme: ThemeData(
                fontFamily: "plus Jakarta Sans",
                primaryColor: kPrimaryColor,
              ),
              debugShowCheckedModeBanner: false,
              home: const WelcomeScreen() // calling welcome Screen
              );
        });
  }
}
