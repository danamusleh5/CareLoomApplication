import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChildDashboard extends StatelessWidget {
  const ChildDashboard({Key? key}) : super(key: key);

  Future<String?> _getDeviceId(String childId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(childId)
          .get();

      if (userDoc.exists) {
        var pairId = userDoc['pairId'] as List?;
        if (pairId != null && pairId.isNotEmpty) {
          return pairId[0];
        }
      }
    } catch (e) {
      print("Error fetching deviceId: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> _getAppUsage(String deviceId) async {
    try {
      DocumentSnapshot deviceDoc = await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .get();

      if (deviceDoc.exists) {
        var appUsageData = deviceDoc['app_usage'] as Map<String, dynamic>?;
        return appUsageData ?? {};
      }
    } catch (e) {
      print("Error fetching app usage data: $e");
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> _getMessages(String deviceId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('messages')
          .get();

      List<Map<String, dynamic>> messages = [];
      for (var doc in snapshot.docs) {
        messages.add(doc.data() as Map<String, dynamic>);
      }
      return messages;
    } catch (e) {
      print("Error fetching messages: $e");
      return [];
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  String formatTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    String childId = FirebaseAuth.instance.currentUser!.uid;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _getDeviceId(childId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No device found"));
          }

          String deviceId = snapshot.data!;

          return FutureBuilder<Map<String, dynamic>>(
            future: _getAppUsage(deviceId),
            builder: (context, appUsageSnapshot) {
              if (appUsageSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (appUsageSnapshot.hasError) {
                return const Center(child: Text("Error loading app usage data"));
              }

              Map<String, dynamic> appUsageData = appUsageSnapshot.data ?? {};

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _getMessages(deviceId),
                builder: (context, messageSnapshot) {
                  if (messageSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (messageSnapshot.hasError) {
                    return const Center(child: Text("Error loading messages"));
                  }

                  List<Map<String, dynamic>> messages = messageSnapshot.data ?? [];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hi Ammer, here's your day so far!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your Parent: ",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "App Usage Data:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...appUsageData.entries.map((entry) {
                          String appName = entry.key;
                          int timeSpent = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '$appName: ${formatTime(timeSpent)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        const Text(
                          "Messages from my Parent:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...messages.map((message) {
                          return ParentMessage(message: message['message']);
                        }).toList(),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ParentMessage extends StatelessWidget {
  final String message;

  const ParentMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
