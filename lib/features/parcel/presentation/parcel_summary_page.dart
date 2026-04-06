import 'package:flutter/material.dart';

class ParcelSummaryPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ParcelSummaryPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order Summary', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 40),
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem('Sender', data['sender'], Icons.person, Colors.indigo),
          const SizedBox(height: 12),
          _buildSummaryItem('Pickup', data['pickup'], Icons.location_on, Colors.green),
          const Divider(height: 32, thickness: 1),
          _buildSummaryItem('Receiver', data['receiver'], Icons.person_outline, Colors.indigo),
          const SizedBox(height: 12),
          _buildSummaryItem('Delivery', data['delivery'], Icons.map, Colors.orange),
          const Divider(height: 32, thickness: 1),
          Row(
            children: [
              Expanded(child: _buildSummaryItem('Type', data['packageType'], Icons.inventory_2_outlined, Colors.indigo)),
              Expanded(child: _buildSummaryItem('Price', data['price'], Icons.payments_outlined, Colors.indigo)),
            ],
          ),
          const Divider(height: 32, thickness: 1),
          Row(
            children: [
              Expanded(child: _buildSummaryItem('Date', data['date'], Icons.calendar_today_outlined, Colors.indigo)),
              Expanded(child: _buildSummaryItem('Time', data['time'], Icons.access_time, Colors.indigo)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Confirm Order', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

