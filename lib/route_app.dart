import 'package:agora_video/presntation/screens/call_screen.dart';
import 'package:agora_video/presntation/screens/home_screen.dart';

import 'package:agora_video/presntation/screens/sing_in_screen.dart';
import 'package:agora_video/presntation/screens/sing_up_screen.dart';
import 'package:agora_video/presntation/screens/video_call_screen.dart';
import 'package:flutter/material.dart';

import 'constants/arguments.dart';
import 'constants/name_page.dart';

class RouteApp {
  Route? generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case NamePage.homeScreen:
        HomeScreenArgument homeScreenArgument =
            routeSettings.arguments as HomeScreenArgument;
        return MaterialPageRoute(
          builder: (context) => HomeScreen(
            uid: homeScreenArgument.id,
          ),
        );

      case NamePage.videoCallScreen:
        VideoCallScreenArgument videoCallScreenArgument =
            routeSettings.arguments as VideoCallScreenArgument;
        return MaterialPageRoute(
          builder: (context) =>
              VideoCallScreen(videoCSA: videoCallScreenArgument),
        );
      case NamePage.singInScreen:
        return MaterialPageRoute(
          builder: (context) => SingInScreen(),
        );

      case NamePage.callScreen:
        return MaterialPageRoute(
          builder: (context) => CallScreen(),
        );
      case NamePage.singUpScreen:
        return MaterialPageRoute(
          builder: (context) => SingUpScreen(),
        );
    }

    return null;
  }
}
