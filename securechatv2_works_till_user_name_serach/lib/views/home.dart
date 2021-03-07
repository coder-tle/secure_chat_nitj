import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:securechatv2/services/auth.dart';
import 'package:securechatv2/services/database.dart';
import 'package:securechatv2/views/chatscreen.dart';
import 'package:securechatv2/views/signin.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;

  String myName, myProfilePic, myUserName, myEmail;
  Stream usersStream, chatRoomsStream;

  TextEditingController searchUsernameEditingController =
      TextEditingController();
  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);

    setState(() {});
  }

  Widget searchListUserTile({String profileUrl, name, username, email}) {
    return //GestureDetector(
        // onTap: () {
        //   // var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        //   // Map<String, dynamic> chatRoomInfoMap = {
        //   //   "users": [myUserName, username]
        //   // };
        //   // DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => ChatScreen(username, name)));
        // },
        // child: Container(
        //   margin: EdgeInsets.symmetric(vertical: 8),
        Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.network(
          profileUrl,
          height: 40,
          width: 40,
        ),
      ),
      SizedBox(width: 12),
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(name), Text(email)])
    ]);

    //   ),
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"]);

                  // return Image.network(
                  //   ds["imgUrl"],
                  //   height: 30,
                  //   width: 30,
                  // );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

// MC this code was causing the problem
  Widget chatRoomsList() {
    return Container();
    // return StreamBuilder(
    //   stream: chatRoomsStream,
    //   builder: (context, snapshot) {
    //     return snapshot.hasData
    //         ? ListView.builder(
    //             itemCount: snapshot.data.docs.length,
    //             shrinkWrap: true,
    //             itemBuilder: (context, index) {
    //               DocumentSnapshot ds = snapshot.data.docs[index];
    //               return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName);
    //             })
    //         : Center(child: CircularProgressIndicator());
    //   },
    // );
  }
// class ChatRoomListTile extends StatefulWidget {
//   final String lastMessage, chatRoomId, myUsername;
//   ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

//   @override
//   _ChatRoomListTileState createState() => _ChatRoomListTileState();
// }
  // return snapshot.hasData
  //     ? ListView.builder(
  //         itemCount: snapshot.data.docs.length,
  //         shrinkWrap: true,
  //         itemBuilder: (context, index) {
  //           DocumentSnapshot ds = snapshot.data.docs[index];
  //           return searchListUserTile(
  //               profileUrl: ds["imgUrl"],
  //               name: ds["name"],
  //               email: ds["email"],
  //               username: ds["username"]);
  //         },
  //       )
  //     : Center(
  //         child: CircularProgressIndicator(),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Secure Chat v2"),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUsernameEditingController.text = "";
                          setState(() {});
                        },
                        child: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_back)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUsernameEditingController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "username"),
                        )),
                        GestureDetector(
                            onTap: () {
                              // isSearching = true;
                              // setState(() {});
                              if (searchUsernameEditingController.text != "") {
                                // isSearching = true;
                                // setState(() {});

                                onSearchBtnClick();
                              }
                            },
                            child: Icon(Icons.search))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : chatRoomsList()
          ],
        ),
      ),
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
