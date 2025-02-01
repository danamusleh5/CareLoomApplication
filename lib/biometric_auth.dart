import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthScreen extends StatefulWidget {
  @override
  _BiometricAuthScreenState createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isBiometricSupported = false;
  String _authorized = 'Not Authorized';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheck = await _localAuth.canCheckBiometrics;
    bool isBiometricSupported = await _localAuth.isDeviceSupported();
    setState(() {
      _canCheckBiometrics = canCheck;
      _isBiometricSupported = isBiometricSupported;
    });
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      setState(() {
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      });
      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _authorized = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Biometric Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Can check biometrics: $_canCheckBiometrics'),
            Text('Is biometric supported: $_isBiometricSupported'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text('Authenticate'),
            ),
            SizedBox(height: 20),
            Text('Status: $_authorized'),
          ],
        ),
      ),
    );
  }
}
