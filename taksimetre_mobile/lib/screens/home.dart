import 'package:flutter/material.dart';

import 'home_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const dummyAvatarUrl =
      'https://st2.depositphotos.com/2703645/5669/v/950/depositphotos_56695433-stock-illustration-female-avatar.jpg';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          CircleAvatar(
            backgroundImage: NetworkImage(dummyAvatarUrl),
            radius: 24,
          ),
          SizedBox(width: 24)
        ],
      ),
      body: const Stack(
        children: [
          HomeScreen(),
          //buildPositioned()
        ],
      ),
    );
  }

  Positioned buildPositioned() {
    return Positioned(
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
        );
  }
}
