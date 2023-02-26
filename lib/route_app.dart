

import 'package:agora_video/presntation/screens/home_screen.dart';
import 'package:agora_video/presntation/screens/second_screen.dart';
import 'package:agora_video/presntation/screens/video_call_screen.dart';
import 'package:flutter/material.dart';

import 'constants/arguments.dart';
import 'constants/name_page.dart';


class RouteApp {
  Route? generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case NamePage.homeScreen:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );

      case NamePage.videoCallScreen:
        return MaterialPageRoute(
          builder: (context) => const VideoCallScreen(),
        );
      case NamePage.secondScreen:
        SecondScreenArgument screenArgument =
            routeSettings.arguments as SecondScreenArgument;
        return MaterialPageRoute(
          builder: (context) => SecondScreen(name: screenArgument.name),
        );
    }

    return null;
  }
}
