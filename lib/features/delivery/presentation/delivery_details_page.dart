
import 'package:flutter/material.dart';

class DeliveryDetailsPage extends StatelessWidget {
  const DeliveryDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Details'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: ListTile(
                title: Text('Current Status', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('In Transit to Los Angeles'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildTimelineTile('Picked Up', 'March 18, 2026 10:00 AM', true),
            _buildTimelineTile('Departed Hub', 'March 18, 2026 02:00 PM', true),
            _buildTimelineTile('Arrived at Facility', 'March 19, 2026 08:00 AM', true),
            _buildTimelineTile('Out for Delivery', '-', false),
            _buildTimelineTile('Delivered', '-', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(String event, String time, bool completed) {
    return ListTile(
      leading: Icon(
        completed ? Icons.radio_button_checked : Icons.radio_button_off,
        color: completed ? Colors.green : Colors.grey,
      ),
      title: Text(event),
      subtitle: Text(time),
    );
  }
}
