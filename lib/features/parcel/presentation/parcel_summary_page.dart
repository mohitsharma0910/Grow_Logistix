import 'package:flutter/material.dart';

class ParcelSummaryPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ParcelSummaryPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcel Summary'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${data['name']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Mobile: ${data['mobile']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Address: ${data['address']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Country: ${data['country']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('State: ${data['state']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('City: ${data['city']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date: ${data['date']}', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
