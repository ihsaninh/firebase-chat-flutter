import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/auth_controller.dart';
import '../controllers/chat_room_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  final authC = Get.find<AuthController>();
  final String chatId = (Get.arguments as Map<String, dynamic>)["chatId"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          toolbarHeight: 70.0,
          automaticallyImplyLeading: false,
          backgroundColor: Color(0XFF225FD7),
          leadingWidth: 100,
          elevation: 0,
          leading: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey,
                  child: StreamBuilder<DocumentSnapshot<Object?>>(
                    stream: controller.streamFriendData,
                    builder: (context, snapFriendUser) {
                      if (snapFriendUser.connectionState ==
                          ConnectionState.active) {
                        var dataFriend =
                            snapFriendUser.data!.data() as Map<String, dynamic>;

                        if (dataFriend["photoUrl"] == "noimage") {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              "assets/logo/noimage.png",
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              dataFriend["photoUrl"],
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "assets/logo/noimage.png",
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          title: StreamBuilder<DocumentSnapshot<Object?>>(
            stream: controller.streamFriendData,
            builder: (context, snapFriendUser) {
              if (snapFriendUser.connectionState == ConnectionState.active) {
                var dataFriend =
                    snapFriendUser.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dataFriend["name"],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
          centerTitle: false,
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          if (controller.isShowEmoji.isTrue) {
            controller.isShowEmoji.value = false;
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.streamChats,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      var alldata = snapshot.data!.docs;
                      Timer(
                        Duration.zero,
                        () => controller.scrollC.jumpTo(
                            controller.scrollC.position.maxScrollExtent),
                      );
                      return ListView.builder(
                        controller: controller.scrollC,
                        itemCount: alldata.length,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  "${alldata[index]["groupTime"]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.0,
                                  ),
                                ),
                                ItemChat(
                                  message: "${alldata[index]["message"]}",
                                  isSender: alldata[index]["sender"] ==
                                          authC.user.value.email!
                                      ? true
                                      : false,
                                  time: "${alldata[index]["time"]}",
                                ),
                              ],
                            );
                          } else {
                            if (alldata[index]["groupTime"] ==
                                alldata[index - 1]["groupTime"]) {
                              return ItemChat(
                                message: "${alldata[index]["message"]}",
                                isSender: alldata[index]["sender"] ==
                                        authC.user.value.email!
                                    ? true
                                    : false,
                                time: "${alldata[index]["time"]}",
                              );
                            } else {
                              return Column(
                                children: [
                                  Text(
                                    "${alldata[index]["groupTime"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                  ItemChat(
                                    message: "${alldata[index]["message"]}",
                                    isSender: alldata[index]["sender"] ==
                                            authC.user.value.email!
                                        ? true
                                        : false,
                                    time: "${alldata[index]["time"]}",
                                  ),
                                ],
                              );
                            }
                          }
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: controller.isShowEmoji.isTrue
                    ? 5
                    : context.mediaQueryPadding.bottom,
              ),
              padding: EdgeInsets.all(10.0),
              width: Get.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: TextField(
                        autocorrect: false,
                        minLines: 1,
                        maxLines: 5,
                        controller: controller.chatC,
                        focusNode: controller.focusNode,
                        onEditingComplete: () => controller.newChat(
                          authC.user.value.email!,
                          Get.arguments as Map<String, dynamic>,
                          controller.chatC.text,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            onPressed: () {
                              controller.focusNode.unfocus();
                              controller.isShowEmoji.toggle();
                            },
                            icon: Icon(Icons.emoji_emotions_outlined),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Material(
                    borderRadius: BorderRadius.circular(100),
                    color: Color(0XFF225FD7),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () => controller.newChat(
                        authC.user.value.email!,
                        Get.arguments as Map<String, dynamic>,
                        controller.chatC.text,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => (controller.isShowEmoji.isTrue)
                  ? Container(
                      height: 325,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          controller.addEmojiToChat(emoji);
                        },
                        onBackspacePressed: () {
                          controller.deleteEmoji();
                        },
                        config: Config(
                          backspaceColor: Color(0xFFB71C1C),
                          columns: 7,
                          emojiSizeMax: 32.0,
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          initCategory: Category.RECENT,
                          bgColor: Color(0xFFF2F2F2),
                          indicatorColor: Color(0xFFB71C1C),
                          iconColor: Colors.grey,
                          iconColorSelected: Color(0xFFB71C1C),
                          progressIndicatorColor: Color(0xFFB71C1C),
                          showRecentsTab: true,
                          recentsLimit: 28,
                          noRecentsText: "No Recents",
                          noRecentsStyle: const TextStyle(
                              fontSize: 20, color: Colors.black26),
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL,
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemChat extends StatelessWidget {
  const ItemChat({
    Key? key,
    required this.isSender,
    required this.message,
    required this.time,
  }) : super(key: key);

  final bool isSender;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0XFFF1FAFF),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
              color: isSender ? Color(0XFF225FD7) : Colors.white,
              borderRadius: isSender
                  ? BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
            ),
            padding: EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Text(
              "$message",
              style: TextStyle(
                color: isSender ? Colors.white : Color(0XFF333333),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            DateFormat.Hm().format(DateTime.parse(time)),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
