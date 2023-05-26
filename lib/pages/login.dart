// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:my_vanam/models/user.dart';
import 'package:my_vanam/utils/auth.dart';
import 'package:my_vanam/utils/checknetwork.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Image.asset(
                'assets/login.jpeg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Align(
                    alignment: const AlignmentDirectional(-0.05, -0.75),
                    child: SizedBox(
                      width: 230,
                      height: 386.3,
                      child: Stack(
                        alignment: const AlignmentDirectional(
                            0.25, -0.09999999999999998),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: SizedBox(
                              width: 240,
                              height: 44,
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty
                                      .resolveWith<Color?>((states) =>
                                          const Color.fromARGB(84, 0, 0, 0)),
                                ),
                                onPressed: () async {
                                  // ignore: unrelated_type_equality_checks
                                  if (await CheckUserConnection()
                                          .checkUserConnection() ==
                                      true) {
                                    User? user =
                                        await Authentication.signInWithGoogle(
                                            context: context);
                                    print(user);
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                        'username', user!.displayName!);
                                    await prefs.setString('uid', user.uid);
                                    await prefs.setString(
                                        'dplink', user.photoURL!);
                                    userDetails _User = userDetails(
                                        username: user.displayName!,
                                        uid: user.uid,
                                        dplink: user.photoURL!);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage(
                                                  User: _User,
                                                )));
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: const Text(
                                              'Please check your internet connection'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                icon: Image.asset(
                                  'assets/google.png',
                                  width: 24.0,
                                  height: 24.0,
                                ),
                                label: const Text(
                                  'Sign In with Google',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // ElevatedButton.icon(
                          //   onPressed: () {},
                          // )
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 120),
                          //   child: SizedBox(
                          //     width: 230,
                          //     height: 44,
                          //     child: ElevatedButton.icon(
                          //         style: ButtonStyle(
                          //           backgroundColor: MaterialStateProperty
                          //               .resolveWith<Color?>((states) =>
                          //                   const Color.fromARGB(84, 0, 0, 0)),
                          //         ),
                          //         onPressed: () {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (context) =>
                          //                       const AddImage()));
                          //         },
                          //         icon: const FaIcon(
                          //           // ignore: deprecated_member_use
                          //           FontAwesomeIcons.mailBulk,
                          //           color: Colors.black,
                          //           size: 29,
                          //         ),
                          //         label: const Text(
                          //           'Sign In with E-mail',
                          //           style: TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 17,
                          //           ),
                          //         )),
                          //   ),
                          // ),
                        ],
                      ),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
