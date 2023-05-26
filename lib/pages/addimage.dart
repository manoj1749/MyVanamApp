// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:my_vanam/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddImage extends StatefulWidget {
  AddImage({super.key, required this.User});
  userDetails User;
  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File? image;
  var lat;
  var long;
  bool? locationSet;
  Future pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    try {
      final image = await imagePicker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageFile = File(image.path);
      setState(
        () => this.image = imageFile,
      );
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<Position> getCurrentLocation() async {
    LocationPermission permission;

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Location permissions are not granted
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Location permissions are still not granted
        final status = await Permission.location.request();
        //return Future.error('Location permissions are denied.');
      }
    }

    // Get the current location
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    FirebaseFirestore db = FirebaseFirestore.instance;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(right: 0.0),
            child: Text('Add Tree',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                )),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(174, 53, 115, 184),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          )),
      body: SafeArea(
          child: Column(
        children: [
          image != null
              ? Image.file(
                  image!,
                  width: double.infinity,
                  height: 480,
                )
              : Container(
                  height: 480,
                  width: double.infinity,
                  color: const Color.fromARGB(53, 0, 0, 0),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt,
                        size: 50.0, color: Colors.black),
                    onPressed: () {
                      pickImage();
                    },
                  ),
                ),
          Row(
            //mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 30),
                child: SizedBox(
                  height: 52,
                  width: 240,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: lat == null
                            ? MaterialStateProperty.all(const Color(0xFFE6E6E6))
                            : MaterialStateProperty.all(
                                Color.fromARGB(255, 43, 95, 151)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )),
                    onPressed: () async {
                      //print(widget.User.username);
                      final position = await getCurrentLocation();
                      final latitude = position.latitude;
                      final longitude = position.longitude;
                      print(latitude);
                      print(longitude);
                      SnackBar snackBar = SnackBar(
                        content: Text('Tree Tagged at $latitude $longitude'),
                        duration: const Duration(seconds: 3),
                      );
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                        lat = latitude;
                        long = longitude;
                        locationSet = true;
                      });
                    },
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          lat == null
                              ? const Icon(Icons.location_on,
                                  color: Colors.black)
                              : const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.black,
                                  ),
                                ),
                          lat == null
                              ? const Text('Tag Tree',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ))
                              : const Text('Tree Tagged',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
            child: SizedBox(
              width: 290,
              height: 52,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(174, 53, 115, 184)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  if (image != null && locationSet == true) {
                    final appCheckTokenResult =
                        FirebaseAppCheck.instance.getToken(true);
                    final storage = FirebaseStorage.instance.ref();
                    final imageName =
                        '${lat}_${long}_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}_${DateTime.now().hour}_${DateTime.now().minute}_${DateTime.now().second}';
                    final task = storage
                        .child('/${widget.User.uid}/${imageName}.jpg')
                        .putFile(
                            image!,
                            SettableMetadata(
                              customMetadata: <String, String>{
                                'appCheckToken': appCheckTokenResult.toString(),
                              },
                            ));
                    print('1');
                    db.collection(widget.User.uid).doc(imageName).set({
                      'username': widget.User.username,
                      'latitude': lat,
                      'longitude': long,
                      'date': DateTime.now(),
                    });
                    final usersRef =
                        db.collection(widget.User.uid).doc('assetCount');
                    usersRef.get().then((DocumentSnapshot doc) => {
                          if (doc.exists)
                            {
                              print('Document exists on the database'),
                              db
                                  .collection(widget.User.uid)
                                  .doc('assetCount')
                                  .update({
                                'count': FieldValue.increment(1),
                              })
                            }
                          else
                            {
                              db
                                  .collection(widget.User.uid)
                                  .doc('assetCount')
                                  .set({
                                'count': 1,
                              }),
                            }
                        });
                    SnackBar snackBar = const SnackBar(
                      content: Text(
                          'Tree Tagged Successfully, Thank You!. Click the back button to return to the home screen'),
                      duration: Duration(seconds: 4),
                    );
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    setState(() {
                      image = null;
                      lat = null;
                      long = null;
                      locationSet = false;
                    });
                    // Navigator.pop(context, true);
                  } else if (image == null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Please upload an image'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK',
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else if (locationSet == false || locationSet == null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Please tag tree',
                              style: TextStyle(color: Colors.black)),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(
                                'OK',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                icon: const Icon(
                  Icons.sports_basketball_outlined,
                ),
                label: const Text('Upload Image',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
