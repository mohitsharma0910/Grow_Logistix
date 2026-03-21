import 'package:flutter/material.dart';

enum VehicleStatus { active, idle, maintenance, outOfService }

class Vehicle {
  final String id;
  final String label;
  final double top;
  final double left;
  final VehicleStatus status;
  final String driver;

  const Vehicle({
    required this.id,
    required this.label,
    required this.top,
    required this.left,
    required this.status,
    required this.driver,
  });
}

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final List<Vehicle> _vehicles = const [
    Vehicle(id: '1', label: 'Truck A', top: 100, left: 150, status: VehicleStatus.active, driver: 'John Doe'),
    Vehicle(id: '2', label: 'Van B', top: 250, left: 200, status: VehicleStatus.idle, driver: 'Jane Smith'),
    Vehicle(id: '3', label: 'Truck C', top: 50, left: 400, status: VehicleStatus.maintenance, driver: 'Sam Brown'),
    Vehicle(id: '4', label: 'Van D', top: 350, left: 50, status: VehicleStatus.active, driver: 'Lisa Ray'),
    Vehicle(id: '5', label: 'Truck E', top: 400, left: 300, status: VehicleStatus.outOfService, driver: 'Tom Wilson'),
  ];

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return Colors.green;
      case VehicleStatus.idle:
        return Colors.blue;
      case VehicleStatus.maintenance:
        return Colors.orange;
      case VehicleStatus.outOfService:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Fleet Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // Map Placeholder
          Container(
            color: const Color(0xFFE5E5E5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 120, color: Colors.grey),
                  Text('GPS Map View', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                  Text('Tracking 5 active units', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          ),

          // Markers
          ..._vehicles.map((v) => _buildMarker(v)),

          // Top Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for vehicle ID, driver...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: const Icon(Icons.filter_list, color: Colors.red),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),
          ),

          // Status Filter Horizontal List
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All', Colors.black, true),
                _buildFilterChip('Active', Colors.green, false),
                _buildFilterChip('Idle', Colors.blue, false),
                _buildFilterChip('Maintenance', Colors.orange, false),
                _buildFilterChip('Out of Service', Colors.grey, false),
              ],
            ),
          ),

          // Draggable Bottom Sheet for Fleet Overview
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.08,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fleet Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('5 Vehicles', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: _vehicles.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final v = _vehicles[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(v.status).withValues(alpha: 0.1),
                              child: Icon(Icons.local_shipping, color: _getStatusColor(v.status)),
                            ),
                            title: Text(v.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Driver: ${v.driver}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(v.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                v.status.name.toUpperCase(),
                                style: TextStyle(color: _getStatusColor(v.status), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
        selectedColor: color,
        selected: isSelected,
        onSelected: (bool value) {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color),
        ),
      ),
    );
  }

  Widget _buildMarker(Vehicle v) {
    return Positioned(
      top: v.top,
      left: v.left,
      child: Column(
        children: [
          Icon(Icons.location_on, color: _getStatusColor(v.status), size: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Text(v.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
