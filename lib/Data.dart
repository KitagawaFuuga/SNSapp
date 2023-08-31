import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'print.dart';
import 'dart:core';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class Comment {
  String username;
  String comment;
  int likeCount;
  DateTime time;
  String image;


  Comment(this.username, this.comment,this.likeCount,this.time, this.image);

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'comment': comment,
      'likeCount': likeCount,
      'timeStamp': time,
      'image': image,
    };
  }
}

class CommentScreen extends StatefulWidget {
  final String name;
  CommentScreen({Key? key,required this.name}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  late String _username;
  late String _content;
  late File? _imageFile;


  void initState() {
    super.initState();
      _username = FirebaseAuth.instance.currentUser?.displayName?? "guest";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Comment')),
      body: Padding(
  padding: EdgeInsets.all(16),
  child: Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Enter your comment',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your comment';
            }
            return null;
          },
          onSaved: (value) { _content = value!; },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          child: Text('Select Image'),
          onPressed: () async{
            try{
              final _pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
              onPressed: () async {
                final _pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
                if (_pickedFile != null) setState(() => _imageFile = File(_pickedFile.path));
              };
              await _firestore.collection('comments').add({
                'username': _username,
                'likeCount': 0,
                'timeStamp': DateTime.now(),
                'image': _imageFile,
              });
            }catch(e){ print(e); }
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Success'),
                    content: Text('Your comment has been posted'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CommentsList(name: widget.name)),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
          },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          child: Text('Post'),
          onPressed: () async{
            try {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await _firestore.collection('comments').add({
                  'username': _username,
                  'content': _content,
                  'likeCount': 0,
                  'timeStamp': DateTime.now(),
                });
              }
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Success'),
                    content: Text('Your comment has been posted'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CommentsList(name: widget.name)),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            }catch(e){
              print(e);
            }
          },
        ),
      ],
    ),
  ),
),

    );
  }

  Future<String> UploadImages(File file) async{
    final storage = FirebaseStorage.instance;
    final refer = storage.ref().child('images/${DateTime.now()}.jpg');
    final uploadTask = refer.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
