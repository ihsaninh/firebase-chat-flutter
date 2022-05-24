import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatRoomController extends GetxController {
  var isShowEmoji = false.obs;
  int totalUnread = 0;
  var streamChats;
  var streamFriendData;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late FocusNode focusNode;
  late TextEditingController chatC;
  late ScrollController scrollC;

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamChats(String chatId) {
    firestore.settings = const Settings(persistenceEnabled: true);
    CollectionReference chats = firestore.collection("chats");

    return chats.doc(chatId).collection("chat").orderBy("time").snapshots();
  }

  Stream<DocumentSnapshot<Object?>> getStreamFriendData(String friendEmail) {
    firestore.settings = const Settings(persistenceEnabled: true);
    CollectionReference users = firestore.collection("users");

    return users.doc(friendEmail).snapshots();
  }

  void addEmojiToChat(Emoji emoji) {
    chatC.text = chatC.text + emoji.emoji;
  }

  void deleteEmoji() {
    chatC.text = chatC.text.substring(0, chatC.text.length - 2);
  }

  void updateChatStatus() async {
    CollectionReference chats = firestore.collection('chats');
    CollectionReference users = firestore.collection('users');
    Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;

    final updateStatusChat = await chats
        .doc(arguments["chatId"])
        .collection("chat")
        .where("isRead", isEqualTo: false)
        .where("receiver", isEqualTo: arguments["email"])
        .get();

    updateStatusChat.docs.forEach((element) async {
      await chats
          .doc(arguments["chatId"])
          .collection("chat")
          .doc(element.id)
          .update({"isRead": true});
    });

    await users
        .doc(arguments["email"])
        .collection("chats")
        .doc(arguments["chatId"])
        .update({"totalUnread": 0});
  }

  void newChat(String email, Map<String, dynamic> argument, String chat) async {
    if (chat != "") {
      CollectionReference chats = firestore.collection("chats");
      CollectionReference users = firestore.collection("users");

      String date = DateTime.now().toIso8601String();

      await chats.doc(argument["chatId"]).collection("chat").add({
        "sender": email,
        "receiver": argument["friendEmail"],
        "message": chat,
        "time": date,
        "isRead": false,
        "groupTime": DateFormat.yMMMMd('en_US').format(DateTime.parse(date)),
      });

      Timer(
        Duration.zero,
        () => scrollC.jumpTo(scrollC.position.maxScrollExtent),
      );

      chatC.clear();

      await users
          .doc(email)
          .collection("chats")
          .doc(argument["chatId"])
          .update({
        "lastTime": date,
        "lastChat": chat,
      });

      final checkChatsFriend = await users
          .doc(argument["friendEmail"])
          .collection("chats")
          .doc(argument["chatId"])
          .get();

      if (checkChatsFriend.exists) {
        final checkTotalUnread = await chats
            .doc(argument["chatId"])
            .collection("chat")
            .where("isRead", isEqualTo: false)
            .where("sender", isEqualTo: email)
            .get();

        totalUnread = checkTotalUnread.docs.length;

        await users
            .doc(argument["friendEmail"])
            .collection("chats")
            .doc(argument["chatId"])
            .update({
          "lastTime": date,
          "totalUnread": totalUnread,
          "lastChat": chat,
        });
      } else {
        await users
            .doc(argument["friendEmail"])
            .collection("chats")
            .doc(argument["chatId"])
            .set({
          "connection": email,
          "lastTime": date,
          "lastChat": chat,
          "totalUnread": 1,
        });
      }
    }
  }

  @override
  void onInit() {
    chatC = TextEditingController();
    scrollC = ScrollController();
    focusNode = FocusNode();
    updateChatStatus();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isShowEmoji.value = false;
      }
    });
    streamChats = getStreamChats(
      (Get.arguments as Map<String, dynamic>)["chatId"],
    );
    streamFriendData = getStreamFriendData(
      (Get.arguments as Map<String, dynamic>)["friendEmail"],
    );
    super.onInit();
  }

  @override
  void onClose() {
    chatC.dispose();
    scrollC.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
