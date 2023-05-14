// ignore_for_file: depend_on_referenced_packages, file_names, prefer_typing_uninitialized_variables, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'extractEmailBackend.dart';

// APIviewmodel class has all the functions related to any needed API requests
class APIBackend {
  APIBackend(this.user, this.emailsList);
  final firestore = FirebaseFirestore.instance;
  List emailsList;
  GoogleSignInAccount user;

  // Function to Get the access user profile and Extract ID of emails
  handleGetEmail(emailCheck) async {
    var emailIDlist;
    int count = 0;
    String responseAPI = '';

    // send get request to get the last 100 emails from user inbox
    final http.Response getProfile = await http.get(
      Uri.parse(
          'https://gmail.googleapis.com/gmail/v1/users/${user.id}/messages/'),
      headers: await user.authHeaders,
    );
    if (getProfile.statusCode != 200) {
      responseAPI = 'Gmail API  a ${getProfile.statusCode} '
          'response. Check logs for details.';
      debugPrint(responseAPI);
      return;
    } else {
      // In successful getProfile request state:
      // Decode the json response, contain the last 100 email id
      final Map<String, dynamic> allEmailsResponse =
          json.decode(getProfile.body) as Map<String, dynamic>;
      emailIDlist = allEmailsResponse['messages'];

      // Loop on the emails, count how many recieved emails, to catch if there is less than 100 email
      for (var email in emailIDlist) {
        count++;
      }
      // Loop on to get the emails data, increment the check to prevent redundent request to users' inbox
      for (var i = 0; i < 10; i++) {
        var emailId = allEmailsResponse['messages'][i]['id'].toString();
        emailCheck++;
        extractEmailBackend(emailId, user, emailsList).extractEmail(false);
      }
      // send to email stream to monitor for the following recieved emails
      emailStream(emailCheck);
    }
  }

  // Function to monitor the following changes on user Gmail account
  emailStream(emailCheck) async {
    var historyMap, historyId, userdata, userStatus;

    // send post watch request, to monitor any changes on user Gmail account
    final http.Response watchRequest = await http.post(
        Uri.parse(
            'https://gmail.googleapis.com/gmail/v1/users/${user.id}/watch'),
        headers: await user.authHeaders,
        body: jsonEncode(<String, String>{
          "topicName": 'projects/cyberphish-gp/topics/cyberphish'
        }));

    // Decode the json response, contain the history id
    final Map<String, dynamic> watchResponse =
        json.decode(watchRequest.body) as Map<String, dynamic>;

    // Extract the history id, to use as parameter in the history request query parameter
    historyId = watchResponse['historyId'];
    userdata =
        await firestore.collection("GoogleSignInAccount").doc(user.id).get();
    userStatus = userdata.data()['userStatus'];

    while (userStatus != false) {
      // User status flag to check if user logged out
      try {
        userdata =
            firestore.collection("GoogleSignInAccount").doc(user.id).get();
        userStatus = userdata.data()['userStatus'];
      } catch (e) {
        userStatus = false;
      }

      // send get request to get any new changes and updates on the Gmail account
      final http.Response historyRequest = await http.get(
        Uri.parse(
            'https://gmail.googleapis.com/gmail/v1/users/${user.id}/history?startHistoryId=$historyId'),
        headers: await user.authHeaders,
      );

      // decode the json response, contain the new changes
      final Map<String, dynamic> historyResponse =
          json.decode(historyRequest.body) as Map<String, dynamic>;
      // Extract the new change type and update based on it
      try {
        //  history response map contain the new changes
        historyMap = historyResponse['history'];
        if (historyMap != null) {
          // Loop through each new change type update
          historyMap.forEach((key) {
            try {
              key.forEach((updateKey, updateValue) {
                // A new message recieved
                if (updateKey == 'messagesAdded') {
                  updateValue.forEach((messageUpdate) {
                    messageUpdate
                        .forEach((messageUpdateKey, messageUpdateValue) async {
                      emailCheck++;
                      extractEmailBackend(
                              messageUpdateValue['id'], user, emailsList)
                          .extractEmail(true);
                    });
                  });
                }
                // message deleted
                if (updateKey == 'messagesDeleted') {
                  updateValue.forEach((messageUpdate) {
                    messageUpdate
                        .forEach((messageUpdateKey, messageUpdateValue) async {
                      var snapshot = await firestore
                          .collection('GoogleSignInAccount')
                          .doc(user.id)
                          .collection("emailsList")
                          .doc(messageUpdateValue['id'])
                          .collection('links')
                          .get();
                      var count = snapshot.size;
                      for (var i = 0; i < count; i++) {
                        firestore
                            .collection('GoogleSignInAccount')
                            .doc(user.id)
                            .collection("emailsList")
                            .doc(messageUpdateValue['id'])
                            .collection('links')
                            .doc('$i')
                            .delete();
                      }
                      firestore
                          .collection('GoogleSignInAccount')
                          .doc(user.id)
                          .collection("emailsList")
                          .doc(messageUpdateValue['id'])
                          .delete();
                    });
                  });
                }
              });
            } catch (e) {
              debugPrint('error in second $e');
            }
            try {
              historyId = key['id'];
            } catch (e) {
              debugPrint('Error in history $e');
            }
          });
        } else {
          // No new change, only update the history Id
          historyId = historyResponse['historyId'];
        }
      } catch (e) {
        debugPrint('Error in history function $e');
      }
    }
  }

  // Calculate the risk percentage of an email
  calculatePercentage(emailId, linkNum, double prediction, int senderScore,
      double wordsPropotion, double totalWeightWords, phisyWord) async {
    double percentage = 0;
    var riskScore, predictionCategory, maxtrigger, trigger, result, extra;
    wordsPropotion = wordsPropotion.toPrecision(2);
    totalWeightWords = totalWeightWords.toPrecision(2);

    // Email has links
    if (linkNum >= 1) {
      // Get the max risk score of email's links
      firestore
          .collection('GoogleSignInAccount')
          .doc(user.id)
          .collection("emailsList")
          .doc(emailId)
          .collection('links')
          .orderBy('RiskScore', descending: true)
          .limit(1)
          .get()
          .then(
        (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            riskScore = docSnapshot.data()['RiskScore'];
          }
        },
        onError: (e) => debugPrint("Error completing Risk Calculation: $e"),
      );
      riskScore ??= 0;
      // Percentage equation with links: Model Prediction 15%, Words 25%, sender risk score 15%, link risk score 45%
      percentage = (prediction * 15) +
          ((totalWeightWords * phisyWord * wordsPropotion) * 0.25) +
          (senderScore * 0.15) +
          (riskScore * 0.45);

      // classifying email category
      if (percentage <= 25) {
        predictionCategory = 'Legitmate';
      } else if (percentage > 25 && percentage <= 50) {
        predictionCategory = 'Low';
      } else if (percentage > 50 && percentage < 75) {
        predictionCategory = 'Moderate';
      } else if (percentage >= 75) {
        predictionCategory = 'High';
      }
    } else {
      riskScore ??= 0;

      // Percentage equation without links: Model Prediction 30%, Words 30%, sender risk score 40%
      percentage = (prediction * 30) +
          ((totalWeightWords * phisyWord * wordsPropotion) * 0.3) +
          (senderScore * 0.4);

      // classifying email category
      if (percentage <= 30) {
        predictionCategory = 'Legitmate';
      } else if (percentage > 30 && percentage <= 50) {
        predictionCategory = 'Low';
      } else if (percentage > 50 && percentage <= 75) {
        predictionCategory = 'Moderate';
      } else if (percentage > 75) {
        predictionCategory = 'High';
      }
    }

    if (percentage > 100) {
      extra = percentage - 100;
      percentage = percentage - extra;
    }
    try {
      result = percentage.toString().substring(0, 3);
      percentage = double.parse(result).toPrecision(2);
    } catch (e) {
      debugPrint('error in calculate percentage $e');
    }

    // Finding the max trigger for an email
    trigger = 'language';
    maxtrigger =
        (prediction * 15) + ((totalWeightWords * phisyWord * wordsPropotion));
    if (senderScore > maxtrigger) {
      maxtrigger = senderScore;
      trigger = 'sender';
    } else if (riskScore > maxtrigger) {
      maxtrigger = riskScore;
      trigger = 'link';
    }

    // Returning risk map includes: risk percentage, link risk, category, the max trigger
    Map<String, dynamic> riskMap = {
      "percentage": percentage,
      "linkRisk": riskScore,
      "predictionCategory": predictionCategory,
      "trigger": trigger,
    };
    return riskMap;
  }

  // Function to classify the email based on subject and body using CyberPhish model in the server
  predict(String subject, String body) async {
    var url = 'https://clownfish-app-9rdvw.ondigitalocean.app';
    //sending a post request to the url
    final http.Response modelRequest = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'subject': subject, 'body': body}));

    final Map<String, dynamic> modelResponse =
        json.decode(modelRequest.body) as Map<String, dynamic>;
    return modelResponse;
  }

  // Function to check the URL risk score using APIVoid
  checkUrl(url, emailId, linkNum) async {
    int riskScore = 0;
    // var key = 'c08fe879383d986b7ab72a808a95b8f7ba8a9db3';
    // var key = '8e32187c415a1e423618e1041602010cde0d2ffd';
    var key = '7f741b5f4419490e654cd9faed9ca2622da8e723';
    url = Uri.encodeComponent(url);

    //sending a get request to the url
    try {
      final http.Response linkAPI = await http.get(
        Uri.parse(
            'https://endpoint.apivoid.com/urlrep/v1/pay-as-you-go/?key=$key&url=$url'),
      );
      final Map<String, dynamic> linkAPIResponse =
          json.decode(linkAPI.body) as Map<String, dynamic>;
      debugPrint('API $linkAPIResponse');

      linkAPIResponse.forEach((key, value) {
        if (key == 'error') {
          riskScore = 0;
        } else if (key == 'data') {
          riskScore = linkAPIResponse['data']['report']['risk_score']['result'];
        }
      });
    } catch (e) {
      debugPrint('error in checkURL $e');
      riskScore = 0;
    }

    // url = Uri.encodeComponent(url);
    firestore
        .collection("GoogleSignInAccount")
        .doc(user.id)
        .collection("emailsList")
        .doc(emailId)
        .collection("links")
        .doc('$linkNum')
        .set({
      'LinkString': url,
      'RiskScore': riskScore,
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  // Function to check the sender reputation and risk score using APIVoid
  checkSender(emailId, senderEmail) async {
    var key = '7f741b5f4419490e654cd9faed9ca2622da8e723';
    // '8e32187c415a1e423618e1041602010cde0d2ffd';
    // 'c08fe879383d986b7ab72a808a95b8f7ba8a9db3';
    var senderFraudScore = -1;
    final http.Response senderAPI = await http.get(Uri.parse(
        "https://endpoint.apivoid.com/emailverify/v1/pay-as-you-go/?key=$key&email=$senderEmail"));
    final Map senderAPIResponse =
        json.decode(senderAPI.body) as Map<dynamic, dynamic>;
    senderFraudScore = senderAPIResponse['data']['score'];
    senderFraudScore = (senderFraudScore - 100) * -1;
    return senderFraudScore;
  }
}
