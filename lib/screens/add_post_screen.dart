import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alumniapp/providers/user_provider.dart';
import 'package:alumniapp/resources/firestore_methods.dart';
import 'package:alumniapp/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(
            context,
            'Posted!',
          );
        }
        clearImage();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _file == null
        ? Column(
      children: <Widget>[
        SizedBox(
          height: 350,
        ),
        Center(
          child:
          IconButton(
            icon: const Icon(
              Icons.upload,
              color: Colors.black,
              size: 50,
            ),
            onPressed: () => _selectImage(context),
          ),
        ),
        Text(
          "Click to upload a Post",
          style: TextStyle(
              color: Colors.black54,
              fontSize: 25
          ),
        )
      ],
    )
        : Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: clearImage,
        ),
        title: const Text(
          'Post to',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                postImage(
                  userProvider.getUser.uid,
                  userProvider.getUser.username,
                  userProvider.getUser.photoUrl,
                ),
            child: const Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
        ),
         // POST FORM
         body: ListView(
           children : [Column(
           children: <Widget>[
            isLoading
                ? const LinearProgressIndicator()
                : const Padding(padding: EdgeInsets.only(top: 0.0)),
            const Divider(),
             SizedBox(
               width: MediaQuery
                   .of(context)
                   .size
                   .width * 0.8,
               height: MediaQuery
                   .of(context)
                   .size
                   .width * 0.7,
              // height: 300.0,
              // width: 300.0,
               child: AspectRatio(
                 aspectRatio: 487 / 451,
                 child: Container(
                   decoration: BoxDecoration(
                       image: DecorationImage(
                         fit: BoxFit.fill,
                         alignment: FractionalOffset.topCenter,
                         image: MemoryImage(_file!),
                       )),
                 ),
               ),
             ),

             const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    userProvider.getUser.photoUrl,
                  ),
                ),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.6,
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        hintText: "Write a caption...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none),
                    maxLines: 8,
                  ),
                ),

              ],
            ),
            const Divider(),
                   ],
                 ),
    ]
         ),
    );
  }
}