import 'package:flutter/material.dart';

class ChatPageLayout extends StatefulWidget {
  //final String receiverUserName;
  //final String receiverUserID;

  const ChatPageLayout({
    super.key,
    //required this.receiverUserName,
    //required this.receiverUserID,
  });

  @override
  ChatPageLayoutState createState() => ChatPageLayoutState();
}

class ChatPageLayoutState extends State<ChatPageLayout> {
  // final TextEditingController _messageController = TextEditingController();
  // final ChatService _service = ChatService();
  // final FirebaseAuth _finalAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: const Color(0xff040324),
        // resizeToAvoidBottomInset: true,
        // appBar: AppBar(
        //   iconTheme: const IconThemeData(
        //     color: Color.fromARGB(255, 253, 253, 253),
        //   ),
        //   centerTitle: true,
        //   title: Text(
        //     widget.receiverUserName,
        //     style: const TextStyle(
        //       color: Colors.white,
        //       fontFamily: 'OswaldLight',
        //     ),
        //   ),
        //   backgroundColor: const Color(0xff040324),
        // ),
        // body: Column(
        //   children: [
        //     Expanded(child: _buildListOfMessages()),
        //     _buildInputFieldForMessage(),
        //   ],
        //)
        );
  }

  // void sendMessage() async {
  //   if (_messageController.text.isNotEmpty) {
  //     await _service.sendMessages(
  //         widget.receiverUserID, _messageController.text);
  //     _messageController.clear();
  //   }
  // }

  // Widget _buildListOfMessages() {
  //   return StreamBuilder(
  //     stream: _service.getMessages(
  //         _finalAuth.currentUser!.uid, widget.receiverUserID),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return const Text('error');
  //       }
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Text('loading...');
  //       }
  //       return ListView(
  //         children: snapshot.data!.docs
  //             .map((document) => _buildMessage(document))
  //             .toList(),
  //       );
  //     },
  //   );
  // }

  // Widget _buildMessage(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
  //   return Container(
  //     margin: const EdgeInsets.all(8.0),
  //     child: Align(
  //       alignment: data['senderID'] == _finalAuth.currentUser!.uid
  //           ? Alignment.centerRight
  //           : Alignment.centerLeft,
  //       child: Container(
  //         padding: const EdgeInsets.all(8.0),
  //         decoration: BoxDecoration(
  //           color: data['senderID'] == _finalAuth.currentUser!.uid
  //               ? const Color.fromARGB(255, 38, 181, 79)
  //               : const Color(0xff040324),
  //           border: data['senderID'] == _finalAuth.currentUser!.uid
  //               ? null
  //               : Border.all(color: const Color.fromARGB(255, 126, 254, 114)),
  //           borderRadius: BorderRadius.circular(8.0),
  //         ),
  //         child: Column(
  //           children: [
  //             Text(
  //               data['message'],
  //               style: TextStyle(
  //                 color: data['senderID'] == _finalAuth.currentUser!.uid
  //                     ? const Color.fromARGB(255, 255, 255, 255)
  //                     : const Color.fromARGB(255, 126, 254, 114),
  //                 fontFamily: 'OswaldLight',
  //                 fontSize: 16.0,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInputFieldForMessage() {
  //   return Row(children: [
  //     Expanded(
  //         child: TextField(
  //       controller: _messageController,
  //       style: const TextStyle(
  //         color: Color.fromARGB(255, 126, 254, 114),
  //         fontFamily: 'OswaldLight',
  //       ),
  //       decoration: const InputDecoration(
  //         hintText: 'Type a message',
  //         hintStyle: TextStyle(
  //           color: Color.fromARGB(255, 126, 254, 114),
  //           fontFamily: 'OswaldLight',
  //         ),
  //       ),
  //     )),
  //     IconButton(
  //       icon: const Icon(
  //         Icons.send,
  //         color: Color.fromARGB(255, 126, 254, 114),
  //       ),
  //       onPressed: sendMessage,
  //     ),
  //   ]);
  // }
}
