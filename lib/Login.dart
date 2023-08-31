import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Data.dart';
import 'print.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;

  late String _email, _password,_nickname;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
            ),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: 'Nickname',
              ),
            ),

            // ログインボタン
            ElevatedButton(
              onPressed: () async{
                setState(() {
                  _email = _emailController.text;
                  _password = _passwordController.text;
                });
                _signInWithEmailAndPassword();
              },
              child: Text('ログイン'),
            ),

            ElevatedButton(
              onPressed:() async{
                setState(() {
                  _email = _emailController.text;
                  _password = _passwordController.text;
                  _nickname = _nicknameController.text;
                });
                register(_email, _password, _nickname);
              },
              child: Text('新規登録'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      print('ログイン成功: ${userCredential.user!.uid}');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommentsList(name: _email)),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('メールアドレスが登録されていません。');
      } else if (e.code == 'wrong-password') {
        print('パスワードが間違っています。');
      }
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User registration successful: ${userCredential.user!.uid}');
      await userCredential.user!.updateDisplayName(name);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommentsList(name: _email)),
      );
    } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') { print('The password provided is too weak.');}
        else if (e.code == 'email-already-in-use') { print('The account already exists for that email.'); }
    } catch (e) {
        print(e);
    }
  }
}