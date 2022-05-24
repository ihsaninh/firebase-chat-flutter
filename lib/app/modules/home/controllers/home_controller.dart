import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> chatsStream(String email) {
    firestore.settings = const Settings(persistenceEnabled: true);
    return firestore
        .collection('users')
        .doc(email)
        .collection("chats")
        .orderBy("lastTime", descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> friendStream(String email) {
    firestore.settings = const Settings(persistenceEnabled: true);
    return firestore.collection('users').doc(email).snapshots();
  }

  void goToChatRoom(String chatId, String email, String friendEmail) async {
    Get.toNamed(
      Routes.CHAT_ROOM,
      arguments: {
        "email": email,
        "chatId": chatId,
        "friendEmail": friendEmail,
      },
    );
  }
}
