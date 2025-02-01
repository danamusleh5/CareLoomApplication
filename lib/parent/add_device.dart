import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:qr_flutter/qr_flutter.dart';

import 'add_device_confirm.dart';

class AddNewDeviceScreen extends StatefulWidget {
  const AddNewDeviceScreen({Key? key}) : super(key: key);

  @override
  _AddNewDeviceScreenState createState() => _AddNewDeviceScreenState();
}

class _AddNewDeviceScreenState extends State<AddNewDeviceScreen> {
  late String pairingCode;

  @override
  void initState() {
    super.initState();
    generatePairingCode();
  }

  void generatePairingCode() {
    final random = Random();
    pairingCode = List.generate(8, (index) => random.nextInt(10).toString()).join();
    addDevice();
  }

  Future<void> addDevice() async {
    final devicesCollection = FirebaseFirestore.instance.collection('devices');
    final auth = FirebaseAuth.instance;

    try {
      String parentId = auth.currentUser!.uid;

      await devicesCollection.doc(pairingCode).set({
        'parentId': parentId,
        'status': 'inactive',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Device added successfully!")),
      );

      devicesCollection.doc(pairingCode).snapshots().listen((documentSnapshot) {
        if (documentSnapshot.exists) {
          String status = documentSnapshot['status'];
          if (status == 'active') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PairingSettingsScreen(pairingCode: pairingCode),
              ),
            );

          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding device: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade100,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/care_loom_logo.png'),
          ),
        ),
        title: const Text(
          'Welcome to CareLoom!',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE8F4FF),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFD9F0FF),
                  child: Icon(Icons.devices, color: Colors.black87, size: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Add a New Device",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Scan the QR code on the child’s device to link it with CareLoom.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Column(
                  children: [
                    QrImageView(
                      data: pairingCode,
                      version: QrVersions.auto,
                      size: 200.0,
                      gapless: false,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "OR",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter this code manually:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      pairingCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code copied to clipboard!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade100,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Share Code"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
