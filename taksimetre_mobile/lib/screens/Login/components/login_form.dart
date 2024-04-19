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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String password = _passwordController.text.trim();

      await AuthApiService.login(name, password).then((value) async {
        if (value != null) {
          await SharedPreferences.getInstance().then((prefs) {
            print(value);
            prefs.setString('id', value.toString());
            prefs.setString('name', name);
            prefs.setString('password', password);

            ShowMySnackbar.snackbarShow(
                context, true, "Giriş işlemi başarılıyla gerçekleştirildi");

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const Home();
                },
              ),
              (route) => false,
            );
          });
        } else {
          ShowMySnackbar.snackbarShow(
              context, false, "Lütfen giriş bilgilerinizi kontrol ediniz.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kullanıcı adı boş olamaz';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: "Kullanıcı adı",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre boş olamaz';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: "Şifreniz",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: _login,
            child: const Text(
              "GİRİŞ",
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
