import 'package:flutter/material.dart';
import '../../parcel/presentation/parcel_order_page.dart';
import '../../delivery/presentation/delivery_details_page.dart';
import '../../location/presentation/location_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GROW Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildMenuCard(
            context,
            'Parcel Orders',
            Icons.inventory_2,
            Colors.blue,
            const ParcelOrderPage(),
          ),
          _buildMenuCard(
            context,
            'Delivery Details',
            Icons.local_shipping,
            const Color.fromARGB(255, 12, 196, 52),
            const DeliveryDetailsPage(),
          ),
          _buildMenuCard(
            context,
            'Locations',
            Icons.location_on,
            Colors.red,
            const LocationPage(),
          ),
          _buildMenuCard(
            context,
            'Fleet Status',
            Icons.directions_bus,
            Colors.orange,
            null,
          ),
          _buildMenuCard(
            context,
            'Performance',
            Icons.analytics,
            Colors.purple,
            null,
          ),
          _buildMenuCard(
            context,
            'Settings',
            Icons.settings,
            Colors.grey,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget? page) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
