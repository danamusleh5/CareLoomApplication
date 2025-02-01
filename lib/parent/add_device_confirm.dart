import 'package:care_loom_app/parent/parent_dashborad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PairingSettingsScreen extends StatefulWidget {
  final String pairingCode;

  const PairingSettingsScreen({Key? key, required this.pairingCode}) : super(key: key);

  @override
  _PairingSettingsScreenState createState() => _PairingSettingsScreenState();
}

class _PairingSettingsScreenState extends State<PairingSettingsScreen> {
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  String deviceName = '';

  void savePreferences() async {
    final selectedPreferences = [
      isChecked1,
      isChecked2,
      isChecked3,
      isChecked4,
      isChecked5,
    ];

    try {
      await FirebaseFirestore.instance.collection('devices').doc(widget.pairingCode).update({
        'deviceName': deviceName,
        'preferences': selectedPreferences,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preferences saved successfully!")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ParentDashboard()),
      );
      print('Saved Preferences: $selectedPreferences');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving preferences: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F4FF),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9F0FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "Welcome, Abdallah Karkar, to CareLoom!",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Device3 has been added successfully",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter Device Name:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      deviceName = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Ameer",
                    filled: true,
                    fillColor: Color(0xFFE8E8E8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Receive Notifications from this device when:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    CheckboxListTile(
                      title: Text("My child opens a restricted application."),
                      value: isChecked1,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked1 = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text("My child suddenly closes the application."),
                      value: isChecked2,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked2 = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text("The application is used after midnight."),
                      value: isChecked3,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked3 = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text("The daily usage time limit is exceeded."),
                      value: isChecked4,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked4 = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text("My child attempts to change the settings."),
                      value: isChecked5,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked5 = value!;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: savePreferences ,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    "Disconnect",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
