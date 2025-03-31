import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/Chat/screen/chat/chat_screen.dart';
import 'package:flutter_sdg/models/user_data.dart';
import 'package:iconsax/iconsax.dart';

class contact2Card extends StatelessWidget {
  final UserData user;
  const contact2Card({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name ?? 'no name'),
        trailing: IconButton(
            onPressed: () async {
              //   List<String> member = [
              //     user.id!,
              //     FirebaseAuth.instance.currentUser!.uid
              //   ]..sort((a, b) => a.compareTo(b));
              //   await FireData()
              //       .createRoom(user.eamil!)
              //       .then((value) => Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => Chat2Screen(
              //                 roomId: member.toString(), chatUser: user),
              //           )));
              // },
              if (user.email != null) {
                List<String> member = [
                  user.id!,
                  FirebaseAuth.instance.currentUser!.uid
                ]..sort((a, b) => a.compareTo(b));
                await FireData()
                    .createRoom(user.email!)
                    .then((value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Chat2Screen(
                                roomId: member.toString(), chatUser: user),
                          ),
                        ));
              } else {
                // Optional: Handle missing fields gracefully (e.g., show a SnackBar or log an error)
                debugPrint('Error: Missing required fields.');
              }
            },
            icon: Icon(Iconsax.message)),
      ),
    );
  }
}
