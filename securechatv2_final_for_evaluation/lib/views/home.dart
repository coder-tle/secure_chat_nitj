import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:securechatv2/helperfunctions/sharedpref_helper.dart';
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
  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);

    setState(() {});
  }

// MF this was creating problem
  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName);

                  // return Text(
                  //     ds.id.replaceAll(myUserName, "").replaceAll("_", ""));
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget searchListUserTile({String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
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
          ],
        ),
      ),
    );
    // yeh CHANGES KIYA NO . 1
    //   child: Row(children: [
    //     ClipRRect(
    //       borderRadius: BorderRadius.circular(40),
    //       child: Image.network(
    //         profileUrl,
    //         height: 40,
    //         width: 40,
    //       ),
    //     ),
    //     SizedBox(width: 12),
    //     Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [Text(name), Text(email)])
    //   ]),
    // );

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

  // Widget chatRoomListTile(
  //     String profilePicUrl, String name, String lastMessage) {
  //   return
  // }

// MC this code was causing the problem

  // Widget chatRoomsList() {
  //   return Container();
  //   // return StreamBuilder(
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
  // }

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

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();

    super.initState();
  }

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
class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);
  // final String lastMessage, username;
  // ChatRoomListTile(this.lastMessage, this.username);
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);

    print(
        "something ${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["name"]}");
    name = "${querySnapshot.docs[0]["name"]}";
    // name = querySnapshot.docs[0]["name"];

    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                profilePicUrl,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 3),
                Text(widget.lastMessage)
              ],
            )
          ], // children
        ),
      ),
    );
  }
}
//             ),
//     )

//   }
//   // String profilePicUrl = "", name = "", username = "";

//   // getThisUserInfo() async {
//   //   username =
//   //       widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
//   //   QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
//   //   print(
//   //       "something bla bla ${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["name"]}  ${querySnapshot.docs[0]["imgUrl"]}");
//   //   name = "${querySnapshot.docs[0]["name"]}";
//   //   profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
//   //   setState(() {});
// }
