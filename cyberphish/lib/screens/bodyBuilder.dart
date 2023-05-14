// ignore_for_file: camel_case_types, file_names, must_be_immutable, prefer_typing_uninitialized_variables, deprecated_member_use, duplicate_ignore

import 'dart:typed_data';
import '../style/appStyles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// email's body Builder, based on the body type.
class bodyBuilder extends StatelessWidget {
  bodyBuilder(
      {Key? key,
      required this.bodyList,
      required this.keyList,
      required this.user,
      required this.counter,
      required this.emailId})
      : super(key: key);
  final bodyList;
  final keyList;
  final user;
  final emailId;
  final counter;
  var count = 1;

  @override
  Widget build(BuildContext context) {
    var part;
    var indexKey;
    try {
      keyList.forEach((key) {
        var i = key!
            .toString()
            .substring(0, key!.toString().indexOf(RegExp(r'[a-z]')));
        if (int.parse(i) == counter) {
          part = bodyList[key];
          indexKey = key;
        }
      });
    } catch (e) {
      debugPrint('Error in Key list email screen $e');
    }
    count++;

    try {
      if (keyList.toString().contains('html')) {
        // has html
        if (indexKey.toString().contains('html')) {
          try {
            return HtmlWidget(
              '''$part ''',
              buildAsync: true,
              enableCaching: false,
              onTapUrl: (url) => launch(url),
              onTapImage: null,
              onErrorBuilder: (context, element, error) =>
                  Text('$element error: $error'),
            );
          } catch (e) {
            debugPrint('Error $e');
          }
        }
      } else {
        // no html
        if (indexKey.toString().contains('link')) {
          var newString = part!.substring(part!.length - 5);
          if (newString.contains('png') ||
              newString.contains('jpg') ||
              newString.contains('jpeg') ||
              newString.contains('gif')) {
            return Image.network(part!);
          } else {
            return RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: "$part",
                style: kJakartaBodyMedium.copyWith(
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  color: kPrimaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch('$part');
                  },
              ),
            );
          }
        } else {
          return RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              text: "$part",
              style: kJakartaBodyMedium.copyWith(
                fontSize: 13,
                color: kDarkColor,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error $e');
    }
    if (indexKey.toString().contains('img')) {
      // has img
      try {
        final List<int> codeUnits = part!.codeUnits;
        Uint8List unit8List = Uint8List.fromList(codeUnits);
        return (Image.memory(unit8List));
      } catch (e) {
        debugPrint('Error $e');
      }
    }
    return RichText(
      // default return
      textAlign: TextAlign.left,
      text: TextSpan(
        text: "",
        style: kJakartaBodyMedium.copyWith(
          fontSize: 0,
          color: kDarkColor,
        ),
      ),
    );
  }
}
