import 'package:agora_video/route_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp( MyApp(routeApp: RouteApp(),));
}

class MyApp extends StatelessWidget {
   MyApp({super.key,required this.routeApp});
RouteApp routeApp;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Video',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    onGenerateRoute: routeApp.generateRoute,
    );
  }
}

