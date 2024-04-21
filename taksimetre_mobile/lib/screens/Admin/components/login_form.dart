import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksimetre_mobile/screens/home.dart';
import 'package:taksimetre_mobile/services/autApiService.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../components/showSnackbar.dart';
import '../../../constants/constants.dart';
import '../../Signup/signup_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
