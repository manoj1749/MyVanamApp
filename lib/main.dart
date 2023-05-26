// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_vanam/models/user.dart';
import 'package:my_vanam/utils/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'pages/homepage.dart';
import 'pages/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // move this line here
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  Authentication.initializeFirebase();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String _userName = prefs.getString('username').toString();
  String _uid = prefs.getString('uid').toString();
  String _url = prefs.getString('dplink').toString();

  runApp(MyApp(
      isLoggedIn: _isLoggedIn, userName: _userName, uid: _uid, url: _url));
}

checkLocation() async {
  LocationPermission permission;
  // Check location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // Location permissions are not granted
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      // Location permissions are still not granted
      checkLocation();
      //return Future.error('Location permissions are denied.');
    }
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final String uid;
  final String url;
  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.uid,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    userDetails user = userDetails(
      username: userName,
      uid: uid,
      dplink: url,
    );
    checkLocation();
    // SnackBar snackBar = const SnackBar(
    //   content: Text('Turn on location services to use this app'),
    //   duration: Duration(seconds: 1),
    // );
    Firebase.initializeApp();

    return MaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        image: Image.asset('assets/icon.png'),
        photoSize: 201,
        backgroundColor: Colors.transparent,
        loaderColor: Colors.black,
        seconds: 4,
        navigateAfterSeconds: isLoggedIn
            ? HomePage(
                User: user,
              )
            : const LoginPage(),
      ),
    );
  }
}
