// ignore_for_file: depend_on_referenced_packages, file_names, prefer_typing_uninitialized_variables, non_constant_identifier_names, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'APIBackend.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'notificationBackend.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Class to extract the email data
class extractEmailBackend {
  extractEmailBackend(this.emailId, this.user, this.emailsList);
  GoogleSignInAccount user;
  final firestore = FirebaseFirestore.instance;
  var emailId, userdata, userStatus;
  List emailsList;

  // Primary function recieving data from Gmail
  extractEmail(bool flag) async {
    int senderRiskScore;
    Map<String, dynamic> dateMap = {};
    Map<String, dynamic> emailHeaderMap = {};
    Map<String, dynamic> bodyDataMap = {};
    var percentageResult,
        prediction,
        headers,
        percentage,
        linkRisk,
        trigger,
        newEmailYear,
        newEmailMonth,
        newEmailWeek,
        newEmailDay;
    // var newValueYear = 0, newValueMonth = 0, newValueWeek = 0, newValueDay = 0;

    try {
      // send  get request to retrive specific email data using the email id
      final http.Response emailData = await http.get(
        Uri.parse(
            'https://gmail.googleapis.com/gmail/v1/users/${user.id}/messages/$emailId'),
        headers: await user.authHeaders,
      );

      //decode the response, the response has all single email data, as 7 nested array, 100 fields of data
      final Map<String, dynamic> emailDataResponse =
          json.decode(emailData.body) as Map<String, dynamic>;

      // extract the headers contains all the header info such as sender, date, day, subject using loop through it
      headers = emailDataResponse['payload']['headers'];

      // Map has the header data: subject, sender name, sender email, date,
      emailHeaderMap = await extractHeader(headers, emailDataResponse);
      // Map has the body data
      bodyDataMap =
          await extractBody(emailDataResponse, emailHeaderMap['subject']);
      // Map has the date data
      dateMap = emailHeaderMap['mapDate'];

// calculate email risk
      senderRiskScore = await APIBackend(user, emailsList)
          .checkSender(emailId, emailHeaderMap['senderEmail']);
      // await Future.delayed(const Duration(seconds: 1));
      percentageResult = await APIBackend(user, emailsList).calculatePercentage(
        emailId,
        bodyDataMap['linkNum'] ?? 0,
        bodyDataMap['modelPrediction'],
        senderRiskScore,
        bodyDataMap['wordsPropotion'],
        bodyDataMap['totalWeightWords'],
        bodyDataMap['numPhishyWord'],
      );

      // calculate percentage function response values has: percentage, linkRisk, predictionCategory, trigger
      percentage = percentageResult['percentage'];
      linkRisk = percentageResult['linkRisk'];
      prediction = percentageResult['predictionCategory'];
      trigger = percentageResult['trigger'];
      // Add the email's data to user's collection inside the email's collection
      await firestore
          .collection("GoogleSignInAccount")
          .doc(user.id)
          .collection("emailsList")
          .doc(emailId)
          .set({
        'emailId': emailId,
        'senderName': emailHeaderMap['senderName'],
        'senderEmail': emailHeaderMap['senderEmail'],
        'date': emailHeaderMap['mapDate'],
        'subject': emailHeaderMap['subject'],
        'prediction': prediction,
        'percentage': percentage,
        'linkRisk': linkRisk,
        'trigger': trigger,
        'body': bodyDataMap['body'],
        'bodyList': bodyDataMap['bodyList'],
        'wordsList': bodyDataMap['wordsList'],
        'valuesList': bodyDataMap['valuesList'],
        'modelPrediction': bodyDataMap['modelPrediction'],
        'senderRiskScore': senderRiskScore,
        'totalWeightWords': bodyDataMap['totalWeightWords'],
        'wordsPropotion': bodyDataMap['wordsPropotion'],
        'numPhishyWord': bodyDataMap['numPhishyWord'],
      });

      try {
        await firestore
            .collection("GoogleSignInAccount")
            .doc(user.id)
            .collection("report")
            .doc('${dateMap['year']}')
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          Map<dynamic, dynamic> yearReport =
              documentSnapshot.data() as Map<dynamic, dynamic>;
          yearReport.forEach((keyYear, valueYear) {
            // Loop on the top level (Year)
            if (keyYear.toString() == ('totalY${dateMap['year']}')) {
              // find Total Year

              if (senderRiskScore > valueYear['senderEmail']) {
                newEmailYear = emailHeaderMap['senderEmail'];
              }
              if (senderRiskScore <= valueYear['senderEmail']) {
                newEmailYear = valueYear['senderEmail'];
              }
            } // Total year if closing
            else if (valueYear.runtimeType != int) {
              valueYear.forEach((keyMonth, valueMonth) {
                // Loop on the second level (Month)
                if (keyMonth.toString() == 'totalM${dateMap['month']}') {
                  // find Total Month, the current value:senderRiskScore, firebase value: valueMonth
                  if (senderRiskScore /* current*/ >
                      valueMonth['senderEmail'] /* Old */) {
                    newEmailMonth = emailHeaderMap['senderEmail'];
                  }
                  if (senderRiskScore /* current */ <=
                      valueMonth['senderEmail'] /* old*/) {
                    newEmailMonth = valueMonth['senderEmail'];
                  }
                } // Total month if closing
                if (valueMonth.runtimeType != int) {
                  valueMonth.forEach((keyWeek, valueWeek) {
                    // Loop on the Third level (week)
                    if (keyWeek.toString() == 'totalW${dateMap['week']}') {
                      // find Total Week
                      if (senderRiskScore /*current*/ >
                          valueWeek['senderEmail'] /*old*/) {
                        newEmailWeek = emailHeaderMap['senderEmail'];
                      }
                      if (senderRiskScore /*current*/ <=
                          valueWeek['senderEmail'] /*old*/) {
                        newEmailWeek = valueWeek['senderEmail'];
                      }
                    } // If Total Week closing

                    if (valueWeek.runtimeType != int &&
                        keyWeek.toString() == '${dateMap['dayNumber']}') {
                      valueWeek.forEach((keyDay, valueDay) {
                        // Loop on the fourth level (days)
                        // find Total day
                        if (senderRiskScore /*current*/ >
                            valueDay['risk'] /*old*/) {
                          newEmailDay = emailHeaderMap['senderEmail'];
                        }
                        if (senderRiskScore /*current*/ <=
                            valueDay['risk'] /*old*/) {
                          newEmailDay = valueDay['email'];
                        } // If daily closing
                      });
                    } // Value weekly is not int (not total year value)
                  }); // week report loop closing
                } // Value monthly is not int (not total year value)
              }); // Monthly report loop closing
            } // Value year is not int (not total year value)
          }); // Year Rport closing
        }); // firestore report request closing
      } catch (e) {
        debugPrint('Error $e');
      }
      // Check all the values not null, if true replace it with the current value
      newEmailYear ??= emailHeaderMap['senderEmail'];
      newEmailMonth ??= emailHeaderMap['senderEmail'];
      newEmailWeek ??= emailHeaderMap['senderEmail'];
      newEmailDay ??= emailHeaderMap['senderEmail'];
      if (prediction == 'Legitmate') {
        // add legitmate record to the report, increment values, includes: legitimate, triggers, the most risky sender
        firestore
            .collection("GoogleSignInAccount")
            .doc(user.id)
            .collection("report")
            .doc('${dateMap['year']}')
            .update({
          '${dateMap['month']}.w${dateMap['week']}.${dateMap['dayNumber']}.legitmate':
              FieldValue.increment(1),
          '${dateMap['month']}.w${dateMap['week']}.totalW${dateMap['week']}.legitmate':
              FieldValue.increment(1),
          '${dateMap['month']}.totalM${dateMap['month']}.legitmate':
              FieldValue.increment(1),
          'totalY${dateMap['year']}.legitmate': FieldValue.increment(1),
          '${dateMap['month']}.w${dateMap['week']}.${dateMap['dayNumber']}.triggersMap.$trigger':
              FieldValue.increment(1),
          '${dateMap['month']}.w${dateMap['week']}.totalW${dateMap['week']}.triggersMap.$trigger':
              FieldValue.increment(1),
          '${dateMap['month']}.totalM${dateMap['month']}.triggersMap.$trigger':
              FieldValue.increment(1),
          'totalY${dateMap['year']}.triggersMap.$trigger':
              FieldValue.increment(1),
          '${dateMap['month']}.w${dateMap['week']}.${dateMap['dayNumber']}.senderEmail':
              newEmailDay,
          '${dateMap['month']}.w${dateMap['week']}.totalW${dateMap['week']}.senderEmail':
              newEmailWeek,
          '${dateMap['month']}.totalM${dateMap['month']}.senderEmail':
              newEmailMonth,
          'totalY${dateMap['year']}.senderEmail': newEmailYear,
          '${dateMap['month']}.w${dateMap['week']}.${dateMap['dayNumber']}.phishing':
              FieldValue.increment(0),
          '${dateMap['month']}.w${dateMap['week']}.totalW${dateMap['week']}.phishing':
              FieldValue.increment(0),
          '${dateMap['month']}.totalM${dateMap['month']}.phishing':
              FieldValue.increment(0),
          'totalY${dateMap['year']}.phishing': FieldValue.increment(0)
        });
      } else {
        // add phishing record to the report, increment values, includes: phishing, triggers, the most risky sender
        firestore
            .collection("GoogleSignInAccount")
            .doc(user.id)
            .collection("report")
            .doc('${dateMap['year']}')
            .update({
          '${dateMap['month']}.w${dateMap['week']}.${dateMap['dayNumber']}.phishing':
              FieldValue.increment(1),
          '${dateMap['month']}.w${dateMap['week']}.totalW${dateMap['week']}.phishing':
              FieldValue.increment(1),
          '${dateMap['month']}.totalM${dateMap['month']}.phishing':
              FieldValue.increment(1),
          'totalY${dateMap['year']}.phishing': FieldValue.increment(1),
          '${dateMap['month']}.w${dateMap['week']}.${dateMap['dayNumber']}.triggersMap.$trigger':
              FieldValue.increment(1),
          '${dateMap['month']}.w${dateMap['week']}.totalW${dateMap['week']}.triggersMap.$trigger':
              FieldValue.increment(1),
          '${dateMap['month']}.totalM${dateMap['month']}.triggersMap.$trigger':
              FieldValue.increment(1),
          'totalY${dateMap['year']}.triggersMap.$trigger':
              FieldValue.increment(1),
          '${dateMap['month']}.w${dateMap['week']}.${dateMap['dayNumber']}.senderEmail':
              newEmailDay,
          '${dateMap['month']}.w${dateMap['week']}.totalW${dateMap['week']}.senderEmail':
              newEmailWeek,
          '${dateMap['month']}.totalM${dateMap['month']}.senderEmail':
              newEmailMonth,
          'totalY${dateMap['year']}.senderEmail': newEmailYear,
          '${dateMap['month']}.w${dateMap['week']}.${dateMap['dayNumber']}.legitmate':
              FieldValue.increment(0),
          '${dateMap['month']}.w${dateMap['week']}.totalW${dateMap['week']}.legitmate':
              FieldValue.increment(0),
          '${dateMap['month']}.totalM${dateMap['month']}.legitmate':
              FieldValue.increment(0),
          'totalY${dateMap['year']}.legitmate': FieldValue.increment(0)
        });
      }
      // Send notification if the email was phishy
      if (flag == true && prediction != 'Legitmate') {
        notificationBackend().addNotification(
          'Be careful, A new phishing email has been recieved!',
          emailHeaderMap['subject'],
          DateTime.now().millisecondsSinceEpoch + 1000,
          channel: 'CyberPhish',
        );
      }
    } catch (e) {
      debugPrint('Error $e');
    }
  }

  // Function to extract the header data
  extractHeader(headers, emailDataResponse) async {
    String senderName = '', senderEmail = '', from, subject = '', date = '';
    int startIndex, endIndex;
    Map<String, dynamic> mapDate;
    Map<String, dynamic> emailData;
    for (var i = 0; i < headers.length; i++) {
      // check if the current header is the From
      if (emailDataResponse['payload']['headers'][i]['name'] == 'From') {
        from = emailDataResponse['payload']['headers'][i]['value'];
        startIndex = from.indexOf("<", 0);
        endIndex = from.indexOf(">", 0);
        // substring the sender name, and sender email
        if (startIndex != -1 && endIndex != -1) {
          senderEmail = from.substring(startIndex + 1, endIndex);
          senderName = from.substring(0, startIndex);
        } else {
          senderEmail = from;
          startIndex = from.indexOf("@", 0);
          senderName = from.substring(0, startIndex);
        }
      }
      // check if the current header is the Date, substring the day from the date
      if (emailDataResponse['payload']['headers'][i]['name'] == 'Date') {
        date = emailDataResponse['payload']['headers'][i]['value'];
      }
      // check if the current header is the subject and extract the subject
      if (emailDataResponse['payload']['headers'][i]['name'] == 'Subject') {
        subject = emailDataResponse['payload']['headers'][i]['value'];
      }
    }

    // Extract the date map using the extractDate function
    mapDate = await extractDate(date);
    // Returning the Email data map
    emailData = {
      'subject': subject,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'mapDate': mapDate,
      'time': mapDate['time'],
      'day': mapDate['day'],
      'dayNumber': mapDate['dayNumber'],
      'week': mapDate['week'],
      'month': mapDate['month'],
      'year': mapDate['year'],
    };
    return emailData;
  }

  // Function to Extract the body, parse it, classify it and return its data
  extractBody(Map<String, dynamic> emailDataResponse, subject) async {
    Map bodyList = {};
    List wordsList = [], valuesList = [];
    int linkNum = 0, emailWords = 0, numPhishyWord = 0, count = 0;
    double wordsProportion = 0, modelPrediction, totalWeightWords = 0;
    RegExp linksExp = RegExp(r'\s|\s+\n\t\v|<|>|\s+|\)|\" ');
    RegExp wordsRegExp = RegExp(r"[\w-._]+");
    var attachmentId,
        body,
        modelResponse,
        textBody,
        byteImage,
        vocabularyString;
    String remainBody;
    Iterable matches;

    // Loop on the email response recieved from Gamil
    emailDataResponse.forEach((keyLayer1, valueLayer1) {
      // layer1
      // in Payload has the body and its parts
      if (keyLayer1.toString() == 'payload') {
        try {
          // multi parts emails
          if (valueLayer1['mimeType'].toString().contains('multipart')) {
            // Loop on the parts
            valueLayer1.forEach((keyLayer2, valueKey2) {
              // layer 2
              try {
                if (keyLayer2 == 'parts') {
                  try {
                    valueKey2.forEach((keyLayer3) {
                      // layer 3
                      // Extract Text body and parse it
                      if (keyLayer3['mimeType'] == 'text/plain') {
                        body = utf8
                            .decode(base64.decode(keyLayer3['body']['data']));
                      }
                      // the part has inner parts could include attachments
                      if (keyLayer3['mimeType']
                          .toString()
                          .contains('multipart')) {
                        try {
                          keyLayer3['parts'].forEach((keyLayer4) async {
                            // layer4
                            // Extract HTML body and parse it
                            if (keyLayer4['mimeType'].toString() ==
                                'text/html') {
                              body = utf8.decode(
                                  base64.decode(keyLayer4['body']['data']));
                              bodyList['${++count}html'] = body;
                            }
                            // Extract Image, send attachment request, parse it,and store it firebase
                            if (keyLayer4['mimeType']
                                .toString()
                                .contains('image')) {
                              try {
                                attachmentId =
                                    keyLayer4['body']['attachmentId'];
                                if (attachmentId != null) {
                                  // Send HTTP request to get the image attachment data
                                  final http.Response attchmentRequest =
                                      await http.get(
                                    Uri.parse(
                                        'https://gmail.googleapis.com/gmail/v1/users/${user.id}/messages/$emailId/attachments/$attachmentId'),
                                    headers: await user.authHeaders,
                                  );
                                  //decode the response, the response has attachment data, convert it, ad store it
                                  final Map<String, dynamic> attchmentResponse =
                                      json.decode(attchmentRequest.body)
                                          as Map<String, dynamic>;
                                  byteImage = String.fromCharCodes(
                                      const Base64Decoder().convert(
                                          attchmentResponse['data']
                                              .toString()));
                                  bodyList['${++count}img'] = byteImage;
                                }
                              } catch (e) {
                                debugPrint('Error $e');
                              }
                            }
                          });
                        } catch (e) {
                          debugPrint('Error $e');
                        }
                      }
                      // Extract HTML body and parse it
                      if (keyLayer3['mimeType'].toString() == 'text/html') {
                        body = utf8
                            .decode(base64.decode(keyLayer3['body']['data']));
                        bodyList['${++count}html'] = body;
                      }
                    });
                  } catch (e) {
                    debugPrint('Error $e');
                  }
                }
              } catch (e) {
                debugPrint('Error $e');
              }
            });
            // Extract Text body and parse it
          } else if (valueLayer1['mimeType'] == 'text/plain') {
            body = utf8.decode(base64.decode(valueLayer1['body']['data']));
            // Extract HTML body and parse it
          } else if (valueLayer1['mimeType'].toString() == 'text/html') {
            body = utf8.decode(base64.decode(valueLayer1['body']['data']));
            bodyList['${++count}html'] = body;
          }
        } catch (e) {
          debugPrint('Error $e');
        }
      } // Payload closing
    }); // email response loop closing

    // Start Parsing, split body from Links, claculate links' risk score, and classify body text
    // will be used as the remaining not parsed yet body
    remainBody = body.toString();
    body = '';
    while (remainBody != '') {
      String partParsedBody = '';

      // if remainBody has link
      if (remainBody.contains(RegExp("(http|https)?://"))) {
        try {
          var startIndex = -1, endIndex = -1;
          String partBody, partLink;

          // first index of link
          startIndex = remainBody.indexOf(RegExp("(http|https)?://"));
          if (remainBody.contains(linksExp, startIndex) && startIndex != -1) {
            // Last index of link
            endIndex = remainBody.indexOf(linksExp, startIndex);
            // substring the body part
            partBody = remainBody.substring(0, startIndex);
            // parsing body from HTML
            var doc = parse(partBody);
            if (doc.documentElement != null) {
              partParsedBody = doc.documentElement!.text;
            }
            // remove CSS and HTML tag
            if (partParsedBody.contains('>')) {
              partParsedBody =
                  partParsedBody.substring(partParsedBody.indexOf('>') + 1);
            }
            // remove CSS and HTML tag
            if (partParsedBody.contains('}')) {
              partParsedBody =
                  partParsedBody.substring(partParsedBody.indexOf('}') + 1);
            }
            partParsedBody = partParsedBody.replaceAll('<', ' ');
            partParsedBody = partParsedBody.replaceAll('>', ' ');
            partParsedBody = partParsedBody.replaceAll('&nbsp;', '  ');
            partParsedBody = partParsedBody.replaceAll('href="', ' ');
            // substring the link
            partLink = remainBody.substring(startIndex, endIndex);
            partLink = partLink.replaceAll('&nbsp;', '  ');
            partLink = partLink.replaceAll('"', '  ');
            // Check the URL risk score
            await APIBackend(user, emailsList)
                .checkUrl(partLink, emailId, linkNum);
            linkNum++;
            // If the requests more than 3 per second wait due to APIVoid limitation
            if (linkNum % 3 == 0) {
              await Future.delayed(const Duration(seconds: 1));
            }
            // the remaining body after the link
            remainBody = remainBody.substring(endIndex + 1);
            // add body to the list and concatinate it to the body
            body = '$body\n$partParsedBody\n$partLink';
            textBody = '$textBody\n$partParsedBody';
            if (partParsedBody != '') {
              bodyList['${++count}body'] = partParsedBody;
            }
            // add link to the list and concatinate it to the body

            if (partLink != '') {
              bodyList['${++count}link'] = partLink;
            }
          } else if (!remainBody.contains(
              RegExp(r'\s|\s+\n\t\v|<|>|\s+|\)|\" '), startIndex)) {
            // link at the end, substring it
            partLink = remainBody.substring(startIndex);
            // Check the URL risk score
            await APIBackend(user, emailsList)
                .checkUrl(partLink, emailId, linkNum);
            linkNum++;
            remainBody = '';
            body = '$body\n$partLink';

            if (partLink != '') {
              bodyList['${++count}link'] = partLink;
            }
          }
        } catch (e) {
          debugPrint('Error $e');
        }
      } else {
        // the body has remaining
        try {
          var HTMLdata = parse(remainBody); //parsing HTML
          if (HTMLdata.documentElement != null) {
            partParsedBody = HTMLdata.documentElement!.text;
          }
          if (partParsedBody.contains('>')) {
            partParsedBody =
                partParsedBody.substring(partParsedBody.indexOf('>') + 1);
          }
          if (partParsedBody.contains('}')) {
            partParsedBody =
                partParsedBody.substring(partParsedBody.indexOf('}') + 1);
          }
          partParsedBody = partParsedBody.replaceAll('<', ' ');
          partParsedBody = partParsedBody.replaceAll('href="', ' ');
          partParsedBody = partParsedBody.replaceAll('&nbsp;', '  ');

          body = '$body\n$partParsedBody';
          textBody = '$textBody\n$partParsedBody';

          if (partParsedBody != '') {
            bodyList['${++count}body'] = partParsedBody;
          }
          remainBody = '';
        } catch (e) {
          debugPrint('Error $e');
        }
      }
    }

    //Find the total number of words
    matches = wordsRegExp.allMatches(body);
    emailWords += matches.length;
    // Classify the text if phishy or legitimate and what are the vocabulary triggers
    modelResponse =
        await APIBackend(user, emailsList).predict(subject, textBody);
    vocabularyString = modelResponse['vocabulary'];
    modelPrediction = double.parse(modelResponse['prediction']);
    // Substring the vocabulary list
    if (vocabularyString != '{}') {
      vocabularyString = vocabularyString
          .toString()
          .substring(1, vocabularyString.toString().indexOf('}'));

      while (vocabularyString != "") {
        try {
          int startIndex, endIndex = -1, midIndex = -1, nextIndex = -1;
          var partKey, partVal;
          startIndex = vocabularyString.indexOf("'");
          midIndex = vocabularyString.indexOf(":", startIndex);
          endIndex = vocabularyString.indexOf('.', startIndex) + 2;
          nextIndex = vocabularyString.indexOf(",");

          if (startIndex != -1 && endIndex != -1 && midIndex != -1) {
            partKey = vocabularyString.substring(startIndex + 1, midIndex - 1);
            partVal = vocabularyString.substring(midIndex + 2, endIndex);
            partVal = double.parse(partVal);
            if (partVal != 0.00) {
              wordsList.add(partKey);
              valuesList.add(partVal);
              totalWeightWords += partVal;
              numPhishyWord++;
            }

            if (nextIndex != -1) {
              vocabularyString = vocabularyString.substring(nextIndex + 1);
            } else {
              vocabularyString = "";
            }
          }
        } catch (e) {
          debugPrint('Error $e');
        }
      }
      // Calculate the words Proportion using the total of the phishy words in an email and the total words in an email
      if (emailWords > 0) wordsProportion = numPhishyWord / emailWords;
    }

    // Returning the body data map
    Map<String, dynamic> bodyData = {
      'totalWeightWords': totalWeightWords,
      'wordsPropotion': wordsProportion,
      'numPhishyWord': numPhishyWord,
      'modelPrediction': modelPrediction,
      'body': body,
      'bodyList': bodyList,
      'linkNum': linkNum,
      'wordsList': wordsList,
      "valuesList": valuesList,
    };
    return bodyData;
  }

  // Function to extract the date map data
  extractDate(date) {
    Map<String, dynamic> mapDate = {};
    String day = '';
    var fullDate, splittedDate, year, month, week, dayNumber, time, startIndex;

    if (date.contains("+")) {
      startIndex = date.indexOf("+", 0);
      date = date.substring(0, startIndex);
    } else if (date.contains("-")) {
      startIndex = date.indexOf("-", 0);
      date = date.substring(0, startIndex);
    } else if (date.contains("G")) {
      startIndex = date.indexOf("G", 0);
      date = date.substring(0, startIndex);
    }
    day = date.substring(0, 3); // substring the day
    fullDate = date.substring(5); // substring the date
    splittedDate = fullDate.split(' ').toList();
    month = splittedDate[1]; // substring the month
    dayNumber = int.parse(splittedDate[0]); // substring the day number
    year = int.parse(splittedDate[2]); // substring the year
    time = splittedDate[3]; // substring the time

    // specify the week
    if (dayNumber <= 7) {
      week = 1;
    } else if (dayNumber > 7 && dayNumber <= 14) {
      week = 2;
    } else if (dayNumber > 14 && dayNumber <= 21) {
      week = 3;
    } else if (dayNumber > 21 && dayNumber <= 31) {
      week = 4;
    }

    // specify the month
    switch (month) {
      case 'Jan':
        month = 1;
        break;
      case 'Feb':
        month = 2;
        break;
      case 'Mar':
        month = 3;
        break;
      case 'Apr':
        month = 4;
        break;
      case 'May':
        month = 5;
        break;
      case 'Jun':
        month = 6;
        break;
      case 'Jul':
        month = 7;
        break;
      case 'Aug':
        month = 8;
        break;
      case 'Sep':
        month = 9;
        break;
      case 'Oct':
        month = 10;
        break;
      case 'Nov':
        month = 11;
        break;
      case 'Dec':
        month = 12;
        break;
    }

    // Returning the date map data
    mapDate = {
      'time': time,
      'day': day,
      'dayNumber': dayNumber,
      'week': week,
      'month': month,
      'year': year,
    };
    return mapDate;
  }
}
