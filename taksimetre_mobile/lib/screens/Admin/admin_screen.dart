import 'package:flutter/material.dart';
import 'package:taksimetre_mobile/models/fee_table_response_model.dart';
import 'package:taksimetre_mobile/screens/Admin/fee_table_screen.dart';
import 'package:taksimetre_mobile/screens/Admin/routes_screen.dart';
import 'package:taksimetre_mobile/screens/Admin/users_screen.dart';
import 'package:taksimetre_mobile/screens/maps_screen.dart';
import 'package:taksimetre_mobile/services/adminApiService.dart';

import '../../constants/app_colors.dart';
import '../../constants/constants.dart';
import '../Login/login_screen.dart';
import '../Signup/signup_screen.dart';
import '../home.dart';
import 'components/admin_screen_top_image.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AdminScreenTopImage(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                await AdminApiService.getUsers().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return UsersScreen(users: value);
                      },
                    ),
                  );
                });
              },
              child: const Text(
                "KULLANICILAR",
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                await AdminApiService.getFeeTableValues().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return FeeTableScreen(fees: value);
                      },
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryLightColor,
                elevation: 0,
              ),
              child: const Text(
                "ÜCRETLENDİRME",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                await AdminApiService.getAllRoutes().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RoutesScreen(routes: value);
                      },
                    ),
                  );
                });
              },
              child: const Text(
                "YAPILAN ROTALAR",
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const MapsScreen(null, true);
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryLightColor,
                elevation: 0,
              ),
              child: const Text(
                "TAKSİ DURAKLARI",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Home();
                    },
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B0000),
                elevation: 0,
              ),
              child: const Text(
                "UYGULAMAYA GİT",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
