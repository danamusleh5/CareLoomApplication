import 'package:care_loom_app/child/pairing_devices.dart';
import 'package:care_loom_app/parent/parent_dashborad.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPAuthScreen extends StatefulWidget {
  final String uid;

  const OTPAuthScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _OTPAuthScreenState createState() => _OTPAuthScreenState();
}

class _OTPAuthScreenState extends State<OTPAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String verificationId = "";
  bool isOTPSent = false;
  bool isLoading = false;

  String formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) {
      return '+972${phoneNumber.replaceAll(RegExp(r'^0+'), '')}';
    }
    return phoneNumber;
  }

  Future<void> _sendOTP() async {
    final phoneNumber = formatPhoneNumber(phoneController.text);

    if (phoneNumber.isEmpty || phoneNumber.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid phone number.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await _updatePhoneVerificationStatus();
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
            isOTPSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OTP sent to $phoneNumber")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (otpController.text.isEmpty || otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid OTP.")),
      );
      return;
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpController.text,
    );

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.signInWithCredential(credential);
      await _updatePhoneVerificationStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP verification failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updatePhoneVerificationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.uid);

      DocumentSnapshot snapshot = await userDoc.get();
      if (snapshot.exists) {
        await userDoc.update({
          'isPhoneVerified': true,
          'phoneNumber': phoneController.text,
          'phoneUID': user.uid,
        });

        String role = snapshot['role'];
        if (role == 'parent') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ParentDashboard()),
          );
        } else if (role == 'child') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ChildPairingScreen()),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            if (!isOTPSent)
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Enter your phone number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            if (isOTPSent)
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isOTPSent ? _verifyOTP : _sendOTP,
              child: Text(isOTPSent ? 'Verify OTP' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
