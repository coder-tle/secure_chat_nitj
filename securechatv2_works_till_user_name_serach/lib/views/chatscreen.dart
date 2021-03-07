import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen(this.chatWithUsername, this.name);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ), // AppBar
    );
  }
}
// body: Center(
//   child: GestureDetector(
//     onTap: () {
//       AuthMethods().signInWithGoogle(context);
//     },
//     child: Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         color: Color(0xffDB4437),
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Text(
//         "Sign In with Google",
//         style: TextStyle(fontSize: 16, color: Colors.white),
//       ),
//     ),
//   ),
//
