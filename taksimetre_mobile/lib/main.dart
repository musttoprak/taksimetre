import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksimetre_mobile/bloc/map_screen_cubit.dart';
import 'package:taksimetre_mobile/screens/home_screen.dart';

import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const dummyAvatarUrl =
      'https://st2.depositphotos.com/2703645/5669/v/950/depositphotos_56695433-stock-illustration-female-avatar.jpg';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppColors.primaryWhiteColor,
          canvasColor: const Color(0xFFCADCF8),
          backgroundColor: AppColors.primaryWhiteColor,
          textTheme: const TextTheme(
              headline1: TextStyle(
                  color: AppColors.headerTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
              headline2:
                  TextStyle(color: AppColors.headerTextColor, fontSize: 24),
              headline3: TextStyle(
                  color: AppColors.primaryWhiteColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFCADCF8), elevation: 0)),
      home:Scaffold(
        appBar: AppBar(
          actions: const [
            CircleAvatar(
              backgroundImage: NetworkImage(dummyAvatarUrl),
              radius: 24,
            ),
            SizedBox(width: 24)
          ],
        ),
        body: Stack(
          children: [
            HomeScreen(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.list_alt,
                        size: 28,
                      ),
                      label: "one"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.local_offer_outlined, size: 28),
                      label: "two"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person, size: 28), label: "three"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
