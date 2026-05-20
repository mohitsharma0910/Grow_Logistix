import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grow/features/chat/presentation/parcel_chat_page.dart';

class ParcelSummaryPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ParcelSummaryPage({super.key, required this.data});

  @override
  State<ParcelSummaryPage> createState() => _ParcelSummaryPageState();
}

class _ParcelSummaryPageState extends State<ParcelSummaryPage> {
  bool _isConfirming = false;

  Future<void> _confirmOrder() async {
    setState(() => _isConfirming = true);

    try {
      // Save parcel to Firestore and get auto-generated ID
      final docRef = await FirebaseFirestore.instance.collection('parcel_chats').add({
        ...widget.data,
        'status':    'Booked',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Navigate to chat page with the new parcel ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ParcelChatPage(
            parcelId:   docRef.id,
            parcelData: widget.data,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isConfirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to confirm order: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Order Summary',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
            const SizedBox(height: 16),
            _buildInfoNote(),
            const SizedBox(height: 24),
            _buildConfirmButton(),
            const SizedBox(height: 20),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem('Sender',   widget.data['sender'],      Icons.person,               Colors.indigo),
          const SizedBox(height: 12),
          _buildSummaryItem('Pickup',   widget.data['pickup'],      Icons.location_on,           Colors.green),
          const Divider(height: 32, thickness: 1),
          _buildSummaryItem('Receiver', widget.data['receiver'],    Icons.person_outline,        Colors.indigo),
          const SizedBox(height: 12),
          _buildSummaryItem('Delivery', widget.data['delivery'],    Icons.map,                   Colors.orange),
          const Divider(height: 32, thickness: 1),
          Row(
            children: [
              Expanded(child: _buildSummaryItem('Type',  widget.data['packageType'], Icons.inventory_2_outlined, Colors.indigo)),
              Expanded(child: _buildSummaryItem('Price', widget.data['price'],       Icons.payments_outlined,   Colors.indigo)),
            ],
          ),
          const Divider(height: 32, thickness: 1),
          Row(
            children: [
              Expanded(child: _buildSummaryItem('Date', widget.data['date'], Icons.calendar_today_outlined, Colors.indigo)),
              Expanded(child: _buildSummaryItem('Time', widget.data['time'], Icons.access_time,              Colors.indigo)),
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

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline, color: Colors.indigo, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'After confirming, you can track your parcel and chat with support directly.',
              style: TextStyle(fontSize: 12, color: Colors.indigo.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
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
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isConfirming ? null : _confirmOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isConfirming
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Confirm & Open Chat',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
