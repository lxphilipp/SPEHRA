// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_sdg/models/message.dart';

// class ChatService {
//   // get instance of firestore and auth
//   final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // get User Stream

//   Stream<List<Map<String, dynamic>>> getUserStream() {
//     return _fireStore.collection("Users").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final user = doc.data();
//         return user;
//       }).toList();
//     });
//   }

//   //send messages
//   Future<void> sendMessages(String receiverID, message) async {
//     //get current user info

//     final String currentUserID = _auth.currentUser!.uid;
//     final String currentUserEmail = _auth.currentUser!.email.toString();
//     final Timestamp timestamp = Timestamp.now();

//     //send messages

//     Message newMessage = Message(
//         senderID: currentUserID,
//         senderEmail: currentUserEmail,
//         receiverID: receiverID,
//         message: message,
//         timestamp: timestamp);

//     List<String> ids = [currentUserID, receiverID];
//     ids.sort();

//     String chatRoomID = ids.join('_');
//     // add new Messages
//     await _fireStore
//         .collection('ChatRooms')
//         .doc(chatRoomID)
//         .collection('Messages')
//         .add(newMessage.toMap());
//   }

//   Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');
//     return _fireStore
//         .collection('ChatRooms')
//         .doc(chatRoomID)
//         .collection('Messages')
//         .orderBy('timestamp', descending: false)
//         .snapshots();
//   }
// }
