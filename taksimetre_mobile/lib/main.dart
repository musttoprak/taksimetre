import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taksimetre',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  String responseData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                // Dio'nun örneklenmesi
                Dio dio = Dio();
                setState(() {
                  responseData = "";
                });
                // API'ye GET isteği gönderme
                Response response = await dio.get('http://192.168.1.16:600/api?destinations=41.092925,28.991724&origins=41.06944946711272,28.992945237875354');

                // Yanıtın işlenmesi
                if (response.statusCode == 200) {
                  setState(() {
                    responseData = response.data.toString();
                    log(responseData);
                  });
                } else {
                  setState(() {
                    responseData = 'API\'den veri alınamadı';
                    log(responseData);
                  });
                }
              } catch (e) {
                // Hata durumunda hata mesajını gösterme
                setState(() {
                  responseData = 'Hata: $e';
                  log(responseData);
                });
              }
            },
            child: const Text("Veriyi çek"),
          ),
          // Gelen veriyi gösterme
          Text(responseData),
        ],
      ),
    );
  }
}
