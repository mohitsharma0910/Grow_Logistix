import 'package:flutter/material.dart';

class ParcelOrderPage extends StatelessWidget {
  const ParcelOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parcel Orders'), backgroundColor: Colors.blue),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile( 
            leading: const CircleAvatar(child: Icon(Icons.inventory)),
            title: Text('Order #GRW-00${index + 1}'),
            subtitle: Text('Status: ${index % 2 == 0 ? "Pending" : "In Transit"}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          );
        },
      ),
    );
  }
}
