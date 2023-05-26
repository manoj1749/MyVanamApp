// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:my_vanam/models/user.dart';
import 'package:my_vanam/utils/auth.dart';
import 'package:my_vanam/utils/checknetwork.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'addimage.dart';
import 'assets.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.User});
  userDetails User;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? treeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTreeCount();
  }

  void _fetchTreeCount() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      DocumentSnapshot<Map<String, dynamic>> document =
          await db.collection(widget.User.uid).doc('assetCount').get();
      Map<String, dynamic>? data = document.data();
      setState(() {
        print(treeCount);
        if (data != null) {
          treeCount = data['count'];
        }
        print(treeCount);
      });
    } catch (error) {
      // handle the error if the document retrieval fails
      print('Error retrieving document: $error');
    }
  }

  @override
  build(BuildContext context) {
    Firebase.initializeApp();
    FirebaseFirestore db = FirebaseFirestore.instance;
    // final Future<DocumentSnapshot<Map<String, dynamic>>> data =
    //     db.collection(User.uid).doc("assetCount").get();
    // final count = data.data()!['count'];
    // print('1');
    // print(count);
    int? starCount = (treeCount! / 5).toInt();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.logout,
                  size: 30,
                ),
                onPressed: () async {
                  if (await CheckUserConnection().checkUserConnection() ==
                      true) {
                    await Authentication.signOut(context: context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('No Internet Connection'),
                            content: const Text(
                                'Please check your internet connection and try again'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          );
                        });
                  }
                },
              ),
            )
          ],
          leading: Image.asset(
            './assets/appbarlogo.png',
            fit: BoxFit.contain,
            height: 32,
          ),
          title: const Text('MY-VANAM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              )),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: const Color.fromARGB(174, 53, 115, 184)),
      body: SafeArea(
        child: Column(children: [
          SizedBox(
              height: 10,
              child: Container(
                color: const Color.fromARGB(0, 0, 0, 0),
              )),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              color: Colors.white,
              border: Border.all(
                color: const Color.fromARGB(69, 0, 0, 0),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 100,
            width: MediaQuery.of(context).size.width - 10,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: CircleAvatar(
                      radius: 30,
                      child: ClipOval(
                        child: Image.network(widget.User.dplink),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(widget.User.username,
                      style: const TextStyle(fontSize: 25.0)),
                ),
              ],
            ),
          ),
          SizedBox(
              height: 10,
              child: Container(
                color: const Color.fromARGB(0, 0, 0, 0),
              )),
          GridView.count(
            childAspectRatio: 0.9,
            shrinkWrap: true,
            crossAxisCount: 2,
            padding: const EdgeInsets.all(4),
            crossAxisSpacing: 4,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(69, 0, 0, 0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ]),
                child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Wallet',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                        )),
                  ),
                  CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: Image.asset('./assets/star.png'),
                      )),
                  Padding(
                    padding: EdgeInsetsGeometry.lerp(const EdgeInsets.all(8.0),
                        const EdgeInsets.all(8.0), 0.5)!,
                    child: Text('${(starCount)} Stars'),
                  ),
                ]),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(69, 0, 0, 0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ]),
                child: GestureDetector(
                  onTap: () async {
                    if (await CheckUserConnection().checkUserConnection() ==
                        true) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AssetsPage(
                                    User: widget.User,
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
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Column(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Trees',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          )),
                    ),
                    CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.asset('./assets/sapling.png'),
                        )),
                    Padding(
                      padding: EdgeInsetsGeometry.lerp(
                          const EdgeInsets.all(8.0),
                          const EdgeInsets.all(8.0),
                          0.5)!,
                      child: Text('$treeCount Trees Planted'),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          // SizedBox(
          //     height: 290,
          //     width: 380,
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           border: Border.all(
          //             color: const Color.fromARGB(69, 0, 0, 0),
          //             width: 2,
          //           ),
          //           borderRadius: BorderRadius.circular(20.0),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.grey.withOpacity(0.5),
          //               spreadRadius: 5,
          //               blurRadius: 7,
          //               offset:
          //                   const Offset(0, 3), // changes position of shadow
          //             ),
          //           ],
          //         ),
          //         child: treeCount == 0
          //             ? Text('No Trees Planted Yet')
          //             : Container(),
          //       ),
          //     ))
        ]),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 15.0, bottom: 23.0),
        child: SizedBox(
          height: 60,
          width: 160,
          child: FloatingActionButton.extended(
            backgroundColor: const Color.fromARGB(174, 53, 115, 184),
            onPressed: () async {
              // db.collection(User.uid).doc('assets').set({
              //   'assets': FieldValue.arrayUnion(['./assets/sapling.png'])
              // });

              // ignore: unrelated_type_equality_checks
              if (await CheckUserConnection().checkUserConnection() == true) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddImage(
                        User: widget.User,
                      ),
                    )).then((value) => {
                      if (true) {_fetchTreeCount()}
                    });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Alert'),
                      content:
                          const Text('Please check your internet connection'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            label: const Text('Add Tree'),
            icon: const Icon(
              Icons.add_a_photo,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
      ),
    );
  }
}
