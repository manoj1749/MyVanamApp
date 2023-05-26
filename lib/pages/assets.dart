// ignore_for_file: non_constant_identifier_names

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:my_vanam/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AssetsPage extends StatefulWidget {
  AssetsPage({super.key, required this.User});
  userDetails User;

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  late Future<List<ImageData>> _futureImages;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<ImageData>> fetchImages() async {
    List<ImageData> images = [];
    final ListResult result =
        await storage.ref().child('/${widget.User.uid}/').listAll();
    for (final Reference ref in result.items) {
      final String name = ref.name;
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
      );
      final String url = await ref.getDownloadURL(

          //appCheckToken: await FirebaseAppCheck.instance.getToken(),
          );
      images.add(ImageData(name: name, url: url));
    }
    return images;
  }

  @override
  void initState() {
    super.initState();
    _futureImages = fetchImages();
  }

  Future<void> _refreshPage() async {
    setState(() {
      _futureImages = fetchImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(right: 0.0),
          child: Text(
            'Trees',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(174, 53, 115, 184),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshPage();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ImageData>>(
        future: _futureImages,
        builder:
            (BuildContext context, AsyncSnapshot<List<ImageData>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.length > 0) {
              print(snapshot.data!.length);
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 0,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final ImageData imageData = snapshot.data![index];
                  return GridTile(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageData.url),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 160.0),
                          child: Text(imageData.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              )),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No images found',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ImageData {
  final String name;
  final String url;

  ImageData({required this.name, required this.url});
}
