// import 'package:care_loom_app/child/child_home_screen.dart';
// import 'package:care_loom_app/log_in_screen.dart';
// import 'package:care_loom_app/log_in_screen2.dart';
// import 'package:care_loom_app/parent/parent_home_screen.dart';
// import 'package:flutter/material.dart';
//
// import 'OTP_screen.dart';
//
//
// //// Here will be a splash screen and
//
// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Select Role')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 // Save the selected role (Parent) in Firebase and navigate
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const ParentHomeScreen()),
//                 );
//               },
//               child: const Text('Parent'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Save the selected role (Child) in Firebase and navigate
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const ChildHomeScreen()),
//                 );
//               },
//               child: const Text('Child'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Save the selected role (Child) in Firebase and navigate
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>  LoginScreen()),
//                      // builder: (context) =>  OTPAuthScreen()),
//                 );
//               },
//               child: const Text('LogIn'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomingScreen extends StatefulWidget {
  const WelcomingScreen({Key? key}) : super(key: key);

  @override
  _WelcomingScreenState createState() => _WelcomingScreenState();
}

class _WelcomingScreenState extends State<WelcomingScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  void _checkUserLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc['role'];

          if (role == 'parent') {
            Navigator.pushReplacementNamed(context, '/parent');
          } else if (role == 'child') {
            Navigator.pushReplacementNamed(context, '/child-home');
          } else {
            _showErrorDialog('Invalid role detected. Please contact support.');
          }
        } else {
          _showErrorDialog('User not found in the database. Please log in again.');
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        _showErrorDialog('Error while retrieving user details: $e');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/care_loom_logo.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 20),
            Text(
              'CareLoom',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '"Empowering Parents, Protecting Children"',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}


// //
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// //
// // // Define constants for route names
// // const String parentHomeRoute = 'parent/ParentHomeScreen';
// // const String childHomeRoute = 'child/childHomeScreen';
// // const String loginScreenRoute = '/LoginScreen';
// //
// // class WelcomingScreen extends StatefulWidget {
// //   const WelcomingScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   _WelcomingScreenState createState() => _WelcomingScreenState();
// // }
// //
// // class _WelcomingScreenState extends State<WelcomingScreen> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkUserLoginStatus();
// //   }
// //
// //   void _checkUserLoginStatus() async {
// //     // Adding a delay to mimic a splash screen effect
// //     await Future.delayed(const Duration(seconds: 2));
// //
// //     // Get the current user from FirebaseAuth
// //     User? user = FirebaseAuth.instance.currentUser;
// //
// //     if (user != null) {
// //       // If the user is logged in, navigate to the appropriate home screen based on role
// //       Navigator.pushReplacementNamed(context, parentHomeRoute);
// //     } else {
// //       // If the user is not logged in, navigate to the login screen
// //       Navigator.pushReplacementNamed(context, loginScreenRoute);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             // App Logo
// //             Image.asset(
// //               'assets/care_loom_logo.png',
// //               height: 120,
// //               width: 120,
// //             ),
// //             const SizedBox(height: 20),
// //             // App Title
// //             Text(
// //               'CareLoom',
// //               style: TextStyle(
// //                 fontSize: 32,
// //                 fontWeight: FontWeight.bold,
// //                 color: Theme.of(context).primaryColor,
// //               ),
// //             ),
// //             const SizedBox(height: 10),
// //             // Tagline
// //             const Text(
// //               '"Empowering Parents, Protecting Children"',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 50),
// //             // Loading Indicator
// //             const CircularProgressIndicator(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
