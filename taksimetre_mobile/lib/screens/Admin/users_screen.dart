import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksimetre_mobile/constants/app_colors.dart';
import 'package:taksimetre_mobile/services/adminApiService.dart';

import '../../models/user_response_model.dart';

class UsersScreen extends StatefulWidget {
  List<UserResponseModel> users;

  UsersScreen({required this.users, super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late List<UserResponseModel> users;

  @override
  void initState() {
    users = widget.users;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Kullanıcılar",
                  style:
                      TextStyle(color: AppColors.headerTextColor, fontSize: 24,fontWeight: FontWeight.bold),
                ),
                Text("Toplam: ${users.length}")
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: users.map((e) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_circle_rounded),
                      title: Text(e.name),
                      subtitle: Text("(${e.id})"),
                      trailing: SizedBox(
                        width: 36,
                        child: Lottie.asset(
                            e.active
                                ? "assets/success.json"
                                : "assets/fail.json",
                            repeat: false),
                      ),
                      onTap: () async {
                        var newUsers = await AdminApiService.userChangeActive(e.id,!e.active);

                        setState(() {
                          users = newUsers;
                        });
                      },
                    ),
                    const Divider()
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
