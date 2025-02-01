import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:care_loom_app/parent/add_device.dart';
import '../log_in_screen.dart';
import 'child_device.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }

  Future<List<DocumentSnapshot>> _fetchDevicesForParent() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      var devicesSnapshot = await FirebaseFirestore.instance
          .collection('devices')
          .where('parentId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      return devicesSnapshot.docs;
    } catch (e) {
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    // final String userName = ModalRoute.of(context)!.settings.arguments as String;
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
          'Welcome, Abdallah Kayrakra, to CareLoom!',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchDevicesForParent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<DocumentSnapshot> devices = snapshot.data ?? [];

          return Container(
            color: Colors.lightBlue.shade50,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Linked Devices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                devices.isEmpty
                    ? const Center(child: Text('No devices linked.'))
                    : Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        var device = devices[index];
                        var deviceName =
                            device['deviceName'] ?? 'Unknown Device';
                        var status = device['status'] ?? 'Unknown';
                        var statusColor =
                        status == 'Online' ? Colors.green : Colors.red;

                        return DeviceTile(
                          deviceName: deviceName,
                          status: status,
                          statusColor: statusColor,
                          deviceId: device.id,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddNewDeviceScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Add New Device'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Notification Settings'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DeviceTile extends StatelessWidget {
  final String deviceName;
  final String status;
  final Color statusColor;
  final String deviceId;

  const DeviceTile({
    Key? key,
    required this.deviceName,
    required this.status,
    required this.statusColor,
    required this.deviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceDetailsScreen(deviceId: deviceId),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  status,
                  style: TextStyle(fontSize: 14, color: statusColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

