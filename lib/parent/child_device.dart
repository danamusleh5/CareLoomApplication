import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final String deviceId;


  const DeviceDetailsScreen({Key? key, required this.deviceId}) : super(key: key);

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
          'Welcome, Dana Musleh , to CareLoom!',
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('devices').doc(deviceId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No details found for this device.'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final deviceName = data['deviceName'] ?? 'Unknown Device';
          final appUsage = data['app_usage'] as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            child: Container(
              color: Colors.lightBlue.shade50,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      '$deviceName\'s Device',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    children: [
                      const Text(
                        'App Usage Details:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...appUsage.entries.map<Widget>((entry) {
                        final appName = entry.key.split('.').last;
                        final totalSeconds = entry.value as int;
                        final hours = totalSeconds ~/ 3600;
                        final minutes = (totalSeconds % 3600) ~/ 60;
                        final formattedTime = '$hours hours $minutes minutes';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  appName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formattedTime,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildMessageCard(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    final messageController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send a Kind Message:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'Enter your message',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final message = messageController.text.trim();
              if (message.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('devices')
                      .doc(deviceId)
                      .collection('messages')
                      .add({
                    'message': message,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message sent successfully!')),
                  );
                  messageController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message cannot be empty.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
