import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksimetre_mobile/screens/Welcome/welcome_screen.dart';
import 'package:taksimetre_mobile/screens/home.dart';
import 'constants/constants.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isLogin;

  @override
  void initState() {
    _checkLogin();
    super.initState();
  }

  Future<void> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('name') != null) {
      setState(() {
        isLogin = true;
      });
    } else {
      setState(() {
        isLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppColors.primaryWhiteColor,
          scaffoldBackgroundColor: Colors.white,
          canvasColor: const Color(0xFFCADCF8),
          backgroundColor: AppColors.primaryWhiteColor,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          ),
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
      //home: Home(),
      home: isLogin == null
          ? const LoadingWidget()
          : isLogin!
              ? const Home()
              : const WelcomeScreen(),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
