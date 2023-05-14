// ignore_for_file:, depend_on_referenced_packages, prefer_typing_uninitialized_variables, file_names

import 'package:cyberphish/model/article.dart';
import 'package:cyberphish/model/email.dart';
import 'package:cyberphish/screens/NavBar.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'APIBackend.dart';

// LoginViewModel class responsible of handling user's sign in, and sign out.
// ignore: camel_case_types
class loginBackend extends ChangeNotifier {
  final firestore = FirebaseFirestore.instance;
  List<Email> emailsList = [];
  List<Article> articleList = [];
  GoogleSignInAccount? currentUser;

  // instance of GoogleSignIn that allows us to use google sign in and sign out
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://mail.google.com/', // scope that has full access
    ],
  );

  // handle get content method,retrieved from DB
  handleGetContent() async {
    final articles = await firestore.collection('Awareness').get();
    for (var articleData in articles.docs) {
      articleList.add(
        // add an article to the list, using the article class
        Article(
            title: articleData.data()['title'],
            author: articleData.data()['author'],
            link: articleData.data()['link'],
            imgLink: articleData.data()['imgLink']),
      );
    }
    return articleList;
  }

  // handle sign out, empty the email list, return the user to log in screen
  handleSignOut(GoogleSignInAccount currentUser) async {
    await http.post(
      Uri.parse(
          'https://gmail.googleapis.com/gmail/v1/users/${currentUser.id}/stop'),
    );
    firestore
        .collection("GoogleSignInAccount")
        .doc(currentUser.id)
        .set({'userStatus': false});

    await firestore
        .collection("GoogleSignInAccount")
        .doc(currentUser.id)
        .collection("emailsList")
        .get()
        .then((querySnapshot) async {
      for (var emailResult in querySnapshot.docs) {
        try {
          await firestore
              .collection('GoogleSignInAccount')
              .doc(currentUser.id)
              .collection("emailsList")
              .doc(emailResult.data()['emailId'])
              .get()
              .then((value) => value.data()?.forEach((key, value) async {
                    var snapshot = await firestore
                        .collection('GoogleSignInAccount')
                        .doc(currentUser.id)
                        .collection("emailsList")
                        .doc(emailResult.data()['emailId'])
                        .collection('links')
                        .get(); // get the counter of links
                    var count = snapshot.size - 1;

                    for (var i = 0; i <= count; i++) {
                      firestore
                          .collection('GoogleSignInAccount')
                          .doc(currentUser.id)
                          .collection("emailsList")
                          .doc(emailResult.data()['emailId'])
                          .collection('links')
                          .doc('$i')
                          .delete(); // Delete link's doc
                    }
                  }));
        } catch (e) {
          debugPrint('error in logout $e');
        }
        firestore
            .collection("GoogleSignInAccount")
            .doc(currentUser.id)
            .collection("emailsList")
            .doc(emailResult.id)
            .delete();
      }
    });

    firestore
        .collection("GoogleSignInAccount")
        .doc(currentUser.id)
        .collection("report")
        .doc('${DateTime.now().year}')
        .delete();
        
    firestore.collection("GoogleSignInAccount").doc(currentUser.id).delete();

    emailsList = [];
    await googleSignIn.signOut();
    Get.offAll(() => const LoginScreen());
  }

  // sign in method, that handle sign in through Gmail, send the user to handle get email method
  handleSignIn() async {
    try {
      // retrieve user's google account, store user's account in DB in user collection
      currentUser = await googleSignIn.signIn();
      firestore.collection("GoogleSignInAccount").doc(currentUser!.id).set({
        "displayName": currentUser!.displayName,
        'email': currentUser!.email,
        'userId': currentUser!.id,
        'photoUrl': currentUser!.photoUrl,
        'userStatus': true,
      });

      var day = DateTime.now().day;
      var weeknum;

      if (day <= 7) weeknum = '1';
      if (day > 7 && day <= 14) weeknum = '2';
      if (day > 14 && day <= 21) weeknum = '3';
      if (day > 21 && day <= 31) weeknum = '4';
      firestore
          .collection("GoogleSignInAccount")
          .doc(currentUser!.id)
          .collection("report")
          .doc('${DateTime.now().year}')
          .set({
        'totalY${DateTime.now().year}': {
          'legitmate': 0,
          'phishing': 0,
          'senderEmail': '',
          'triggersMap': {
            'language': 0,
            'sender': 0,
            'link': 0,
          },
        },
        '${DateTime.now().month}': {
          'totalM${DateTime.now().month}': {
            'legitmate': 0,
            'phishing': 0,
            'senderEmail': '',
            'triggersMap': {
              'language': 0,
              'sender': 0,
              'link': 0,
            },
          },
          'w$weeknum': {
            '${DateTime.now().day}': {
              'legitmate': 0,
              'phishing': 0,
              'senderEmail': '',
              'triggersMap': {
                'language': 0,
                'sender': 0,
                'link': 0,
              },
            },
            'totalW$weeknum': {
              'legitmate': 0,
              'phishing': 0,
              'senderEmail': '',
              'triggersMap': {
                'language': 0,
                'sender': 0,
                'link': 0,
              },
            },
          }
        },
      });

      await handleGetContent();
      APIBackend(currentUser!, emailsList).handleGetEmail(0);

      Get.to(
        () => NavBar(
          user: currentUser!,
          emailsList: emailsList,
          articleList: articleList,
        ),
      );
    } catch (error) {
      debugPrint('Error $error');
    }
  }
}
