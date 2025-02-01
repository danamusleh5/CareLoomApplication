import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_usage.dart';

class ChildPairingScreen extends StatefulWidget {
  const ChildPairingScreen({Key? key}) : super(key: key);

  @override
  _ChildPairingScreenState createState() => _ChildPairingScreenState();
}

class _ChildPairingScreenState extends State<ChildPairingScreen> {
  String? scannedCode;
  final TextEditingController manualCodeController = TextEditingController();

  Future<void> pairDevice(String pairingCode) async {
    final devicesCollection = FirebaseFirestore.instance.collection('devices');
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final auth = FirebaseAuth.instance;

    try {
      String childId = auth.currentUser!.uid;

      var deviceDoc = await devicesCollection.doc(pairingCode).get();

      if (!deviceDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Device with this pairing code not found.")),
        );
        return;
      }

      String parentId = deviceDoc['parentId'];

      var parentDoc = await usersCollection.doc(parentId).get();
      var parentData = parentDoc.data()!;
      var parentPairId = parentData['pairId'] ?? [];

      if (parentPairId is! List) {
        parentPairId = [parentPairId];
      }

      if (!parentPairId.contains(pairingCode)) {
        parentPairId.add(pairingCode);
        await usersCollection.doc(parentId).update({'pairId': parentPairId});
      }

      await usersCollection.doc(childId).update({'pairId': [pairingCode]});

      await devicesCollection.doc(pairingCode).update({
        'childId': childId,
        'status': 'active',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Device paired successfully!")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppUsageScreen(deviceId: pairingCode),

        ),
      );


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error pairing device: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pair with Parent"),
        backgroundColor: Colors.lightBlue.shade100,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Scan QR Code or Enter Pairing Code",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: scannedCode == null
                  ? MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    setState(() {
                      scannedCode = barcodes.first.rawValue;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Scanned: $scannedCode")),
                    );
                  }
                },
              )
                  : Center(
                child: Text(
                  "Scanned Code: $scannedCode",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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

            // Manual Code Entry
            TextField(
              controller: manualCodeController,
              decoration: InputDecoration(
                labelText: "Enter Pairing Code",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final pairingCode = scannedCode ?? manualCodeController.text.trim();
                if (pairingCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please scan or enter a code.")),
                  );
                  return;
                }

                pairDevice(pairingCode);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade100,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Connect"),
            ),
          ],
        ),
      ),
    );
  }
}
