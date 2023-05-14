// ignore_for_file: depend_on_referenced_packages, file_names

import 'package:cyberphish/screens/ArticleScreen.dart';
import 'package:cyberphish/style/sizeConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/article.dart';
import '../style/appStyles.dart';
import 'package:google_sign_in/google_sign_in.dart';

// article card class resbonsible for the design of the article card in awareness content screen.
// awareness content screen build a stream of this class.
// article card screen directs the user (when clicked) to the clicked article screen.
class ArticleCards extends StatelessWidget {
  const ArticleCards({
    Key? key,
    this.article,
    required this.user,
  }) : super(key: key);

  final Article? article;
  final GoogleSignInAccount user;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SizeConfig().init(context);

    // ui design
    return InkWell(
      onTap: () {
        // redirects the user to the article screen of the clicked card.
        Get.to(
            () => ArticleScreen(
                  article: article,
                  user: user,
                ),
            duration: const Duration(milliseconds: 500),
            transition: Transition.rightToLeftWithFade);
      },
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                Positioned(
                  top: 35,
                  left: 20,
                  child: Material(
                    child: Container(
                      height: 180,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kBackgroundColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 35,
                  left: 15,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kBackgroundColor,
                      image: DecorationImage(
                        image: NetworkImage('${article?.imgLink}'),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 200,
                  child: SizedBox(
                    height: 180,
                    width: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article?.title ?? '',
                          style: kJakartaHeading4.copyWith(
                            fontSize:
                                SizeConfig.blockSizeHorizontal! * kHeading4,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(1),
                        ),
                        const SizedBox(
                          width: 200,
                          child: Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(1),
                        ),
                        Text(
                          "By: ${article?.author} \n ",
                          style: kJakartaBodyBold.copyWith(
                            fontSize: SizeConfig.blockSizeHorizontal! * kBody1,
                            color: kDark40Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
