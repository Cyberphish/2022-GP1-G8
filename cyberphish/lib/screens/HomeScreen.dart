// ignore_for_file: sort_child_properties_last, , depend_on_referenced_packages, prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables,, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyberphish/model/email.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../backend/APIBackend.dart';
import 'MailCard.dart';
import '../style/appStyles.dart';
import '../style/sizeConfiguration.dart';
import 'package:expandable/expandable.dart';
import 'package:cyberphish/screens/NavBar.dart';

// Home screen (user's inbox), it has a list of mail cards.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.emailsList,
    required this.user,
    Key? key,
  }) : super(key: key);
  final List<Email> emailsList;
  final GoogleSignInAccount user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firestore = FirebaseFirestore.instance;
  var emailId;
  late int emailCheck;
  var userdata;
  var userStatus;
  var flag = true;
  String? selectedValue = 'All inbox';
  var emailsCounter = 0;
  @override
  void initState() {
    super.initState();
    emailCheck = widget.emailsList.length;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SizeConfig().init(context);

    // if no emails extracted for the user, start extraction.
    emailCheck = widget.emailsList.length;
    if (emailCheck == 0) {
      APIBackend(widget.user, widget.emailsList).handleGetEmail(emailCheck);
    }

    // List of items in our dropdown menu
    var items = [
      'All inbox',
      'Legitmate',
      'Low Phishing',
      'Moderate Phishing',
      'High Phishing',
    ];

    // ui design
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        color: kPrimaryColor,
                        padding: const EdgeInsets.only(top: 25),
                        width: size.width,
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          color: kWhiteColor,
                          onPressed: () {
                            showAlertDialog(context, widget.user);
                          },
                          tooltip: MaterialLocalizations.of(context)
                              .openAppDrawerTooltip,
                          alignment: Alignment.bottomLeft,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: kPrimaryColor,
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  //Filter
                                  DropdownButton<String>(
                                    borderRadius: BorderRadius.circular(12),
                                    dropdownColor:
                                        const Color.fromARGB(182, 88, 122, 152),
                                    value: selectedValue,
                                    onChanged: (newValue) => setState(
                                      () {
                                        selectedValue = newValue;
                                      },
                                    ),
                                    items: items
                                        .map<DropdownMenuItem<String>>(
                                          (String value) =>
                                              DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: kJakartaHeading1.copyWith(
                                                color: kWhiteColor,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    kHeading1,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    icon: Icon(
                                      CupertinoIcons.chevron_down,
                                      color: kWhiteColor,
                                      size: SizeConfig.blockSizeHorizontal! *
                                          kHeading3,
                                    ),
                                    underline: Container(
                                      height: 2,
                                    ),
                                  ),
                                ],
                              ),
                              // retrive # of emails extracted and displayed in cyberphish home screen.
                              // stream display.
                              StreamBuilder(
                                stream: firestore
                                    .collection("GoogleSignInAccount")
                                    .doc(widget.user.id)
                                    .collection("emailsList")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Text(
                                      "Total 0 emails",
                                      style: kJakartaBodyMedium.copyWith(
                                        color: kWhiteColor,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                kBody1,
                                      ),
                                    );
                                  }
                                  emailsCounter = snapshot.data!.size;
                                  return Text(
                                    "Total $emailsCounter emails",
                                    style: kJakartaBodyMedium.copyWith(
                                      color: kWhiteColor,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! *
                                              kBody1,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          // user avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            child: GoogleUserCircleAvatar(
                              identity: widget.user,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    color: kPrimaryColor,
                  ),
                ],
              ),
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
            Container(
              transform: Matrix4.translationValues(0, -36, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded),
                    onPressed: () => _dialogBuilder(context),
                    color: kDark40Color,
                  ),
                  Text(
                    "Info",
                    style: kJakartaHeading1.copyWith(
                      color: kDarkColor,
                      fontSize: SizeConfig.blockSizeHorizontal! * kHeading3,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 30),
              transform: Matrix4.translationValues(0, -36, 0),
              child: SizedBox(
                height: size.height * 0.68,
                // retrieves email's info. to be displayed
                // add this email to the email's card list.
                // show the email card list (inbox).
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("GoogleSignInAccount")
                      .doc(widget.user.id)
                      .collection("emailsList")
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<MailCard> mailcardList = [];
                    if (!snapshot.hasData) {
                      return const Center(
                          child: Text('No Emails Recieved Yet!'));
                    }
                    final mails = snapshot.data!.docs.reversed;
                    for (var mail in mails) {
                      final emailId = mail.get('emailId');
                      final subject = mail.get('subject');
                      final senderName = mail.get('senderName');
                      final senderEmail = mail.get('senderEmail');
                      final body = mail.get('body');
                      final date = mail.get('date');
                      final prediction = mail.get('prediction');
                      final percentage = mail.get('percentage').toString();
                      final Map bodyList = mail.get('bodyList');
                      final List wordsList = mail.get('wordsList');
                      final List valuesList = mail.get('valuesList');
                      final double wordsPropotion = mail.get("wordsPropotion");
                      var linkRisk = mail.get('linkRisk');
                      var senderFraudScore = mail.get('senderRiskScore');

                      try {
                        firestore
                            .collection('GoogleSignInAccount')
                            .doc(widget.user.id)
                            .collection("senders")
                            .where('email', isEqualTo: senderEmail)
                            .limit(1)
                            .get();
                      } catch (e) {
                        debugPrint('Error $e');
                      }
                      widget.emailsList.add(
                        // add an email to the list, using the email class
                        Email(
                          emailId: emailId,
                          user: widget.user,
                          subject: subject,
                          senderName: senderName,
                          body: body,
                          date: date,
                          senderEmail: senderEmail,
                          prediction: prediction,
                          bodyList: bodyList,
                          percentage: percentage,
                          senderFraudScore: senderFraudScore,
                          linkRisk: linkRisk ?? 0,
                          wordsPropotion: wordsPropotion,
                          valuesList: valuesList,
                          wordsList: wordsList,
                        ),
                      );
                      final mailwidget = MailCard(
                        email: Email(
                          emailId: emailId,
                          user: widget.user,
                          subject: subject,
                          senderName: senderName,
                          body: body,
                          date: date,
                          senderEmail: senderEmail,
                          prediction: prediction,
                          bodyList: bodyList,
                          percentage: percentage,
                          senderFraudScore: senderFraudScore,
                          linkRisk: linkRisk ?? 0,
                          wordsPropotion: wordsPropotion,
                          valuesList: valuesList,
                          wordsList: wordsList,
                        ),
                        user: widget.user,
                      );

                      // add the mail to the mail card List.
                      if (selectedValue == 'All inbox') {
                        mailcardList.add(mailwidget);
                      } else if (selectedValue!
                          .contains(mail.get('prediction'))) {
                        mailcardList.add(mailwidget);
                      }
                    }

                    return Column(children: [
                      Expanded(
                        child: Scrollbar(
                          child: Container(
                            transform: Matrix4.translationValues(0, -36, 0),
                            // each mail card will be listed to present the whole inbox to the user.
                            child: ListView(
                              children: mailcardList,
                              reverse: false,
                              padding: const EdgeInsets.only(top: 16),
                            ),
                          ),
                        ),
                      )
                    ]);
                  }, // end stream
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// % calculation guide
Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                24,
              ),
            ),
            scrollable: true,
            content: Column(
              children: [
                Text(
                  'What do we search for in an email?',
                  textAlign: TextAlign.center,
                  style: kJakartaHeading1.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
                  ),
                ),
                Text(
                  "\nWe take into consideration 3 of the most important possible indications of a phishing email.\n",
                  textAlign: TextAlign.center,
                  style: kJakartaBodyRegular.copyWith(
                    color: kDarkColor,
                    fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                  ),
                ),
                ExpandablePanel(
                  header: Row(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "1. Links",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 6,
                        ),
                      ),
                      const Icon(
                        Icons.link_rounded,
                      ),
                    ],
                  ),
                  expanded: Text(
                    "\nUtilizing APIVoid, an efficient API service provider, we can evaluate the reputation of links in emails and receive a risk score as response.\n",
                    style: kJakartaBodyRegular.copyWith(
                      color: kDarkColor,
                      fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                    ),
                  ),
                  collapsed: const Text(""),
                ),
                ExpandablePanel(
                  header: Row(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "2. Language used",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 6,
                        ),
                      ),
                      const Icon(
                        Icons.language_rounded,
                      ),
                    ],
                  ),
                  expanded: Text(
                    "\nPhishing emails often use urgent, scaring or threatening language in both subject line & body.\n",
                    style: kJakartaBodyRegular.copyWith(
                      color: kDarkColor,
                      fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                    ),
                  ),
                  collapsed: const Text(""),
                ),
                ExpandablePanel(
                  header: Row(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "3. Sender address",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 6,
                        ),
                      ),
                      const Icon(
                        Icons.alternate_email_rounded,
                      ),
                    ],
                  ),
                  expanded: Text(
                    "\nUtilizing APIVoid, an efficient API service provider, we can determine whether the sender domain name is malicious.\n",
                    style: kJakartaBodyRegular.copyWith(
                      color: kDarkColor,
                      fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                    ),
                  ),
                  collapsed: const Text(""),
                ),
                Text(
                  'How do we calculate percentages?',
                  textAlign: TextAlign.center,
                  style: kJakartaHeading1.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
                  ),
                ),
                Text(
                  "\nCyberPhish look at your inbox and classify your emails to one of these types.\n",
                  textAlign: TextAlign.center,
                  style: kJakartaBodyRegular.copyWith(
                    color: kDarkColor,
                    fontSize: 13.5,
                  ),
                ),
                ExpandablePanel(
                  header: Row(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "1. Call to action email",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 6,
                        ),
                      ),
                      const Icon(
                        Icons.ads_click_rounded,
                      ),
                    ],
                  ),
                  expanded: Column(
                    children: [
                      Text(
                        "A call-to-action (CTA) email is an email message designed to encourage you to take a specific action. click on a link, button, or hyperlinked line of text that directs to a website\n",
                        style: kJakartaBodyRegular.copyWith(
                          color: kDarkColor,
                          fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "CTA email percent calculation:\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Text(
                        "In the case of a phishing CTA email, CyberPhish gives a higher percent to the links. Due to the possibility that it contains malware that might instantly infect your device or direct you to fake or compromised websites intended to steal sensitive information.\n",
                        style: kJakartaBodyRegular.copyWith(
                          color: kDarkColor,
                          fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                        ),
                      ),
                      ExpandableNotifier(
                        child: ExpandablePanel(
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Links",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                "45 %",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          expanded: Text(
                            "In the case of a phishing CTA email, CyberPhish gives a higher percent to the links. Due to the possibility that it contains malware that might instantly infect your device or direct you to fake or compromised websites intended to steal sensitive information.\n",
                            style: kJakartaBodyRegular.copyWith(
                              color: kDarkColor,
                              fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                            ),
                          ),
                          collapsed: const Text(""),
                        ),
                      ),
                      ExpandableNotifier(
                        child: ExpandablePanel(
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Email language",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                "40 %",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          expanded: Text(
                            "In second place is the language used in the subject or body of a phishing email.\nThe language used could be either:\n\n1. persuasive language to create a sense of urgency and trustworthiness\n\n2. appeal to basic human emotions and needs, like fear, empathy, curiosity, etc.\n\nEither way, phishing emails' language is specifically crafted to convince you to take immediate action.\n",
                            style: kJakartaBodyRegular.copyWith(
                              color: kDarkColor,
                              fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                            ),
                          ),
                          collapsed: const Text(""),
                        ),
                      ),
                      ExpandableNotifier(
                        child: ExpandablePanel(
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Sender address",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                "15 %",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          expanded: Text(
                            "Lastly, because most attackers utilize temporary or disposable email accounts in their phishing attempts, the reputation of the phishing email's sender receives the smallest percentage. Since the address may be new yet possess a good reputation, relying on the sender address may result in inaccurate results. However, it's worth noting that not every phishing attempts make use of a temporary email address, so we took that into account.\n",
                            style: kJakartaBodyRegular.copyWith(
                              color: kDarkColor,
                              fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                            ),
                          ),
                          collapsed: const Text(""),
                        ),
                      ),
                    ],
                  ),
                  collapsed: const Text(""),
                ),
                ExpandablePanel(
                  header: Row(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "2. Content-based email",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 6,
                        ),
                      ),
                      const Icon(
                        Icons.description_outlined,
                      ),
                    ],
                  ),
                  expanded: Column(
                    children: [
                      Text(
                        "Emails that are content-based often contain only written text and don't have any buttons, links, or hyperlinked lines of text.\n",
                        style: kJakartaBodyRegular.copyWith(
                          color: kDarkColor,
                          fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "Content-based email percent calculation:\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Text(
                        "In the case of a phishing content-based email, CyberPhish eliminates the link portion and divides the percentage into the remaining indicators, which are:\n\n1. Language used.\n\n2. Sender's email address.\n",
                        style: kJakartaBodyRegular.copyWith(
                          color: kDarkColor,
                          fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                        ),
                      ),
                      ExpandableNotifier(
                        child: ExpandablePanel(
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Email language",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                "60 %",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          expanded: Text(
                            "CyberPhish gives a higher percent to the used language in the subject or body of a phishing email. Due to the fact that these types of emails rely 100% on persuasive language to manipulate you and start a conversation.\nThe language used could be either:\n\n1. persuasive language to create a sense of urgency and trustworthiness\n\n2. appeal to basic human emotions and needs, like fear, empathy, curiosity, etc.\n\nEither way, phishing emails' language is specifically crafted to start a conversation.\n",
                            style: kJakartaBodyRegular.copyWith(
                              color: kDarkColor,
                              fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                            ),
                          ),
                          collapsed: const Text(""),
                        ),
                      ),
                      ExpandableNotifier(
                        child: ExpandablePanel(
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Sender address",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                "40 %",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          expanded: Text(
                            "Since most attackers utilize temporary or disposable email accounts in their phishing attempts, relying on the sender address may result in inaccurate results. However, it's worth noting that not every phishing attempts make use of a temporary email address, so we took that into account.\n",
                            style: kJakartaBodyRegular.copyWith(
                              color: kDarkColor,
                              fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                            ),
                          ),
                          collapsed: const Text(""),
                        ),
                      ),
                    ],
                  ),
                  collapsed: const Text(""),
                ),
                Text(
                  'What does (High, Moderate, Low) mean?',
                  textAlign: TextAlign.center,
                  style: kJakartaHeading1.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
                  ),
                ),
                Text(
                  "\nAfter CyberPhish classifies an email as phishing, it also classifies it according to its danger level to one of the following: \n",
                  textAlign: TextAlign.center,
                  style: kJakartaBodyRegular.copyWith(
                    color: kDarkColor,
                    fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                  ),
                ),
                ExpandablePanel(
                  header: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "High",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        "> 75%",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  expanded: Text(
                    "A high-risk phishing email shouldn't be interacted with at any cost, there are several steps you should take to protect yourself:\n\n1. Do not click on any links or download any attachments in the email.\n\n2.Do not reply to the email or provide any personal information.\n\n3. Delete the email from your inbox and your trash folder\n\n4.Block the sender to prevent future similar emails.\n",
                    style: kJakartaBodyRegular.copyWith(
                      color: kDarkColor,
                      fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                    ),
                  ),
                  collapsed: const Text(""),
                ),
                ExpandablePanel(
                  header: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Moderate",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        "> 50% & <= 75%",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  expanded: Text(
                    "A moderate-risk phishing email, we advise you not to interact with it unless you make sure it's from a legitimate source. Otherwise, it should be dealt with carefully. As it may contains:\n\n1. Phishing links, even if the sender is legitimate with no bad reputation.\n\n2. Bad reputation sender, even if the content not extremly indicating a phishing attempt.\n",
                    style: kJakartaBodyRegular.copyWith(
                      color: kDarkColor,
                      fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                    ),
                  ),
                  collapsed: const Text(""),
                ),
                ExpandablePanel(
                  header: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Low",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        "> 0% & <= 50%",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  expanded: Text(
                    "A low-risk phishing email is one that contains legitimate links but has suspicious language or source. Error is a remote possibility in this situation. However, unless you check that the justification provided by CyberPhish and making sure the email is coming from a reliable source, we advise you not to interact with it.\n",
                    style: kJakartaBodyRegular.copyWith(
                      color: kDarkColor,
                      fontSize: SizeConfig.blockSizeHorizontal! * kBody,
                    ),
                  ),
                  collapsed: const Text(""),
                ),
              ],
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
          ),
        ],
      );
    },
  );
}
