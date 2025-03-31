import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sdg/models/group_model.dart';
import 'package:flutter_sdg/models/message.dart';
import 'package:flutter_sdg/models/room_model.dart';
import 'package:uuid/uuid.dart';

class FireData {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;
  String now = DateTime.now().millisecondsSinceEpoch.toString();

  Future<String?> createRoom(String email) async {
    //هونة تم متل تصفية انو بحيث يبحث عن المستخدمين بخلال ايميل متل مقطع رقم تسعة واربعين دقيقة ثمانية
    QuerySnapshot userEmail = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userEmail.docs.isNotEmpty) {
      String userId = userEmail.docs.first.id;
      //ضمن القائمة مشان انو ما يتم انشاء اكقر من غرفة لما تنشا محادثة
      List<String> members = [myUid, userId]..sort((a, b) => a.compareTo(b));
// هون للتحقق انو الغرفة اذا تم انشائها او لا انو يدخل القائمة اللي باسم الرووم ويفحص امو الاعضاء اللي عرفناهم من قبل مشان ما بم انشاء غرفة جديدة
      QuerySnapshot roomExist = await firestore
          .collection('rooms')
          .where('members', isEqualTo: members)
          .get();

      if (roomExist.docs.isEmpty) {
        ChatRoom chatRoom = ChatRoom(
          id: members.toString(),
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          lastMassage: "",
          LastMassageTime: DateTime.now().millisecondsSinceEpoch.toString(),
          memeber: members,
        );

        await firestore
            .collection('rooms')
            .doc(members.toString())
            .set(chatRoom.toJson());
      }
    }
  }

  Future creatGroup(String name, List members) async {
    String gId = Uuid().v1();
    members.add(myUid);
    GroupChat chatGroup = GroupChat(
        id: gId,
        name: name,
        image: " ",
        admin: [myUid],
        createdAt: now,
        lastMessage: '',
        lastMessageTime: now,
        members: members);
    await firestore.collection('groups').doc(gId).set(chatGroup.toJson());
  }

  Future addContact(String email) async {
    QuerySnapshot userEmail = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userEmail.docs.isNotEmpty) {
      String userId = userEmail.docs.first.id;

      await firestore.collection('users').doc(myUid).update({
        'my_users': FieldValue.arrayUnion([userId])
      });
    }
  }

  Future sendMessage(String uid, String msg, String roomId,
      {String? type}) async {
    String msgId = Uuid().v1();
    Message message = Message(
      id: msgId,
      toId: uid,
      fromId: myUid,
      msg: msg,
      type: type ?? "text",
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      read: '',
    );
    await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(msgId)
        .set(message.toJson());

    await firestore.collection('rooms').doc(roomId).update({
      'last_Message': type ?? msg,
      'last_Message_Time': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  Future readMessage(String roomId, String msgId) async {
    await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(msgId)
        .update({
      'read': DateTime.now().millisecondsSinceEpoch.toString(),
      //'read': FieldValue.serverTimestamp(),
    });
  }

  Future deleteMsg(String roomId, List<String> msgs) async {
    if (msgs.length == 1) {
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(msgs.first)
          .delete();
    } else {
      for (var element in msgs) {
        await firestore
            .collection('rooms')
            .doc(roomId)
            .collection('messages')
            .doc(element)
            .delete();
      }
    }
  }

  Future sendGMessage(String msg, String groupId, {String? type}) async {
    String msgId = Uuid().v1();
    Message message = Message(
      id: msgId,
      toId: '',
      fromId: myUid,
      msg: msg,
      type: type ?? "text",
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      read: '',
    );
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(msgId)
        .set(message.toJson());

    await firestore.collection('groups').doc(groupId).update({
      'last_Message': type ?? msg,
      'last_Message_Time': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  Future editGroup(String gId, String name, List members) async {
    await firestore
        .collection('groups')
        .doc(gId)
        .update({'name': name, 'members': FieldValue.arrayUnion(members)});
  }

  Future removeMember(String gId, String memberId) async {
    await firestore.collection('groups').doc(gId).update({
      'members': FieldValue.arrayRemove([memberId])
    });
  }
}
