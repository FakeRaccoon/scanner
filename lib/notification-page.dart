import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getShared();
    // notificationFuture = NotificationAPI.httpNotification();
  }

  Future notificationFuture;

  // Future getNotification() async {
  //   OneSignal.shared.setNotificationReceivedHandler((notification) {
  //     var title = notification.payload.title;
  //     var body = notification.payload.title;
  //     if (title.contains('btc') || body.contains('btc')) {
  //       print('no upload');
  //     } else {
  //       firestore.collection('Users').doc(name).collection('notifications').add({
  //         'title': notification.payload.title,
  //         'content': notification.payload.body,
  //         'time': DateTime.now(),
  //         'read': false,
  //       });
  //     }
  //   });
  // }

  Future getShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final getName = sharedPreferences.getString('name');
    if (getName != null) {
      name = getName;
      // getNotification();
    }
  }

  String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Notification Page",
          style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
        future: notificationFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Text('Data Kosong');
            } else {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return Text('ada');
                  // NotificationResult notification = snapshot.data[index];
                  // return NotificationScreenComponent(
                  //   title: notification.title,
                  //   content: notification.content,
                  //   date: notification.createdAt,
                  //   colors: notification.read == false ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                  // );
                },
              );
            }
          }
          return Center(child: Text('No data'));
        },
      ),
    );
  }
}
