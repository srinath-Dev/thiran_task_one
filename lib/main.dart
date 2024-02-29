import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t1/providers/RepositoryProvider.dart';
import 'package:t1/screens/HomeScreen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
   sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  runApp(
    ChangeNotifierProvider(create: (context) => RepositoryProvider(),
        child:const MyApp())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  MyHomePage(),
    );
  }
}


