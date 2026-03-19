import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Locations'), backgroundColor: Colors.red),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Colors.grey),
                  Text('Map View Placeholder', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          _buildMarker(100, 150, 'Truck A'),
          _buildMarker(200, 300, 'Van B'),
          _buildMarker(50, 400, 'Truck C'),
        ],
      ),
    );
  }

  Widget _buildMarker(double top, double left, String label) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 40),
          Container(
            padding: const EdgeInsets.all(4),
            color: Colors.white.withOpacity(0.8),
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
