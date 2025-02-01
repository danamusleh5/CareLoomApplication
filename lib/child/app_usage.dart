import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'child_dashboard.dart';

class AppUsageScreen extends StatefulWidget {
  final String deviceId;

  AppUsageScreen({required this.deviceId});

  @override
  _AppUsageScreenState createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends State<AppUsageScreen> {
  List<UsageInfo>? usageStats;
  bool isLoading = true;
  String? errorMessage;

  Future<void> getUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

    try {
      bool? permissionGranted = await UsageStats.checkUsagePermission();

      if (permissionGranted == null || !permissionGranted) {
        await UsageStats.grantUsagePermission();
        permissionGranted = await UsageStats.checkUsagePermission();

        if (permissionGranted == null || !permissionGranted) {
          setState(() {
            errorMessage = "Permission not granted. Please enable usage stats permission in settings.";
            isLoading = false;
          });
          return;
        }
      }

      List<UsageInfo> usageStatsData = await UsageStats.queryUsageStats(startDate, endDate);
      List<UsageInfo> filteredStats = usageStatsData.where((stat) {
        return stat.totalTimeInForeground != null &&
            int.tryParse(stat.totalTimeInForeground.toString()) != null &&
            int.tryParse(stat.totalTimeInForeground.toString())! > 0;
      }).toList();

      filteredStats.sort((a, b) {
        int timeA = int.tryParse(a.totalTimeInForeground.toString()) ?? 0;
        int timeB = int.tryParse(b.totalTimeInForeground.toString()) ?? 0;
        return timeB.compareTo(timeA);
      });

      await saveUsageToFirestore(filteredStats);

      setState(() {
        usageStats = filteredStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch usage data. Please try again later.";
        isLoading = false;
      });
    }
  }

  Future<void> saveUsageToFirestore(List<UsageInfo> usageStats) async {
    try {
      String deviceId = widget.deviceId;

      Map<String, int> appUsageData = {};

      for (var stat in usageStats) {
        String appName = stat.packageName ?? 'Unknown App';
        int timeSpent = stat.totalTimeInForeground != null
            ? int.tryParse(stat.totalTimeInForeground.toString()) ?? 0
            : 0;

        if (timeSpent > 0) {
          appUsageData[appName] = timeSpent;
        }
      }

      if (appUsageData.isEmpty) {
        return;
      }

      await FirebaseFirestore.instance.collection('devices').doc(deviceId).set({
        'app_usage': appUsageData,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Failed to save app usage data to Firestore: $e");
    }
  }

  String formatTime(int? milliseconds) {
    final duration = Duration(milliseconds: milliseconds ?? 0);
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    getUsage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child App Usage'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : errorMessage != null
            ? Text(errorMessage!, style: TextStyle(color: Colors.red))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: usageStats!.length,
                itemBuilder: (context, index) {
                  var stat = usageStats![index];
                  return ListTile(
                    title: Text(stat.packageName ?? 'Unknown App'),
                    subtitle: Text(
                      'Time Spent: ${formatTime(int.tryParse(stat.totalTimeInForeground.toString()) ?? 0)}',
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Child Dashboard screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildDashboard(),
                  ),
                );
              },
              child: Text('Go to Child Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
