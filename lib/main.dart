import 'package:care_loom_app/child/pairing_devices.dart';
import 'package:care_loom_app/parent/parent_dashborad.dart';
import 'package:care_loom_app/welcome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'child/child_dashboard.dart';
import 'firebase_options.dart';
import 'log_in_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }
//
// // or maybe the splash screen will be here
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Care Loom',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
//         useMaterial3: true,
//       ),
//       home: const RoleSelectionScreen(),
//     );
//   }
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Care Loom',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomingScreen(),
        '/parent': (context) => const ParentDashboard(),
       // '/child-home': (context) => const ChildHomeScreen(),
        '/child-home': (context) => const ChildDashboard(),

        '/login': (context) => const LoginScreen(),
        '/child-pairing': (context) => const ChildPairingScreen(),
      },

    );
  }
}



