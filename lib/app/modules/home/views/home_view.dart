import 'package:aichat/app/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:aichat/app/controllers/auth_controller.dart';
import 'package:aichat/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF225FD7),
        title: Text(
          'AI CHAT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0XFF225FD7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.PROFILE);
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.black26,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: authC.user.value.photoUrl! == "noimage"
                            ? Image.asset(
                                "assets/logo/noimage.png",
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                authC.user.value.photoUrl!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "${authC.user.value.name!}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${authC.user.value.status!}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.chat, size: 24),
              title: Text(
                'new_chat'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.SEARCH);
              },
            ),
            ListTile(
              leading: Icon(Icons.face, size: 24),
              title: Text(
                'change_profile'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.CHANGE_PROFILE);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, size: 24),
              title: Text(
                'settings'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // onTap: () => Get.toNamed(Routes.SEARCH),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: controller.chatsStream(authC.user.value.email!),
              builder: (context, snapshot1) {
                if (snapshot1.connectionState == ConnectionState.active) {
                  var listDocsChats = snapshot1.data!.docs;
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      indent: 78.0,
                    ),
                    padding: EdgeInsets.zero,
                    itemCount: listDocsChats.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: controller
                            .friendStream(listDocsChats[index]["connection"]),
                        builder: (context, snapshot2) {
                          if (snapshot2.connectionState ==
                              ConnectionState.active) {
                            var data = snapshot2.data!.data();
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 16,
                              ),
                              onTap: () => controller.goToChatRoom(
                                "${listDocsChats[index].id}",
                                authC.user.value.email!,
                                listDocsChats[index]["connection"],
                              ),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.black26,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: data!["photoUrl"] == "noimage"
                                      ? Image.asset(
                                          "assets/logo/noimage.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          "${data["photoUrl"]}",
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: Get.width * 0.6,
                                    ),
                                    child: Text(
                                      "${data["name"]}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    Utilities.formatTime(
                                      "${listDocsChats[index]["lastTime"]}",
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: Get.width * 0.6,
                                    ),
                                    child: Text(
                                      "${listDocsChats[index]["lastChat"]}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  listDocsChats[index]["totalUnread"] == 0
                                      ? SizedBox()
                                      : Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0XFF225FD7),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Text(
                                            "${listDocsChats[index]["totalUnread"]}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.SEARCH),
        child: SvgPicture.asset('assets/svg/pencil.svg'),
        backgroundColor: Color(0XFF225FD7),
      ),
    );
  }
}
