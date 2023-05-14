// ignore_for_file: depend_on_referenced_packages
import 'package:google_sign_in/google_sign_in.dart';

// an Email class object has all the extracted and stored data
class Email {
  final GoogleSignInAccount user;
  final dynamic emailId;
  final String subject;
  final String senderName;
  final String senderEmail;
  final Map date;
  final String body;
  final Map bodyList;
  final String percentage;
  final int senderFraudScore;
  final int linkRisk;
  final String prediction;
  final double wordsPropotion;
  final List wordsList, valuesList;

  Email({
    required this.user,
    required this.emailId,
    required this.subject,
    required this.senderName,
    required this.body,
    required this.senderEmail,
    required this.date,
    required this.bodyList,
    required this.percentage,
    required this.senderFraudScore,
    required this.linkRisk,
    required this.prediction,
    required this.wordsPropotion,
    required this.wordsList,
    required this.valuesList,
  });
}
