import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/login.dart';
import 'package:scanner/root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   'This channel is used for important notifications.', // description
//   importance: Importance.max,
// );
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   print(message.notification.title);
// }

class MyApp extends StatelessWidget {
  MyApp() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(behavior: MyBehavior(), child: child);
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('id', ''),
      ],
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.grey[700]),
        colorScheme: ThemeData().colorScheme.copyWith(primary: Colors.grey[700]),
      ),
      debugShowCheckedModeBanner: false,
      home: Root(),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
