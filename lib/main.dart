import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
// import 'package:id3/id3.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/mp3list.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  List fileMetaData = [];
  List filesStoreMp3All = [];
  List filesStoreMp3 = [];

  Future<Map> getTagsAsMap(String path) async {
    final String filePath = path;
    final Map map = await tagger.readTagsAsMap(path: filePath);
    return map;
  }

  @override
  void initState() {
    super.initState();
    permissionstatus();
    getMp3Files().then((value) {
      Future.delayed(const Duration(seconds: 1), () async {
        print(filesStoreMp3.length);
        for (var path in filesStoreMp3) {
          getTagsAsMap(path.toString()).catchError(
            (
              onError,
            ) {
              print(onError);
            },
          );
        }
      }).then((value) {
        print(fileMetaData.length);
      });
    });
  }

  Future getMp3Files() async {
    getExternalStorageDirectories().then((value) {
      for (var i = 0; i < value.length; i++) {
        if (i == 0) {
          List path = value[i].path.split("Android");
          List<FileSystemEntity> files = Directory(path[0]).listSync(
            recursive: true,
            followLinks: true,
          );
          for (FileSystemEntity filePath in files) {
            if (filePath.runtimeType.toString() == "_File") {
              if (filePath.path.toString().split(
                      ".")[filePath.path.toString().split(".").length - 1] ==
                  "mp3") {
                setState(
                  () {
                    filesStoreMp3.add(filePath);
                  },
                );
              }
            }
          }
        } else {
          List sdpath = value[i].path.split("Android");
          List<FileSystemEntity> sdfolders = Directory(sdpath[0]).listSync();
          for (FileSystemEntity sdfolder in sdfolders) {
            if (sdfolder.runtimeType.toString() == "_Directory") {
              if (sdfolder.path.toString() ==
                  "/storage/9016-4EF8/.android_secure") {
              } else {
                List sdSubFolder = Directory(sdfolder.path)
                    .listSync(followLinks: true, recursive: true);
                // print(sdSubFolder.length);
                for (var sdFiles in sdSubFolder) {
                  if (sdFiles.runtimeType.toString() == "_File") {
                    if (sdFiles.path.toString().split(".")[
                            sdFiles.path.toString().split(".").length - 1] ==
                        "mp3") {
                      setState(
                        () {
                          filesStoreMp3.add(sdFiles);
                        },
                      );
                    }
                  }
                }
              }
            } else {
              if (sdfolder.path.toString().split(
                      ".")[sdfolder.path.toString().split(".").length - 1] ==
                  "mp3") {
                setState(
                  () {
                    filesStoreMp3.add(sdfolder);
                  },
                );
              }
            }
          }
        }
      }
    });
  }

  permissionstatus() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  final tagger = new Audiotagger();
  bool inAsyncCall = true;
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        inAsyncCall = false;
      });
    });
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: inAsyncCall,
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                filesStoreMp3.length != 0
                    ? Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Mp3List(
                                      mp3List:
                                          filesStoreMp3[index].path.toString());
                                }));
                              },
                              title: Container(
                                height: 100,
                                child: Text(
                                  filesStoreMp3[index].path.toString(),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text("Nothing"),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
