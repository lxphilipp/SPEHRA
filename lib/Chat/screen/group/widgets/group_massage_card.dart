import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/models/message.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class GroupMassageCard extends StatelessWidget {
  final Message message;
  final int index;
  const GroupMassageCard({
    super.key,
    required this.index,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    bool isMe = message.fromId == FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(message.fromId)
            .snapshots(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    // isMe
                    //     ? IconButton(
                    //         onPressed: () {},
                    //         icon: const Icon(Iconsax.message_edit))
                    //     : const SizedBox(),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16)),
                      ),
                      color: index % 2 == 0
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width / 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              !isMe
                                  ? Text(
                                      snapshot.data?.data()?['name'] ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    )
                                  : Container(),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(message.msg!),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  isMe
                                      ? const Icon(
                                          Iconsax.tick_circle,
                                          color: Colors.blueAccent,
                                          size: 18,
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    //message.createdAt!,
                                    DateFormat('dd.MM.yyyy HH:mm').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(message.createdAt!)),
                                    ),
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container();
        });
  }
}
