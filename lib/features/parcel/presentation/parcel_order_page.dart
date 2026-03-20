import 'package:flutter/material.dart';
// Ensure these paths match your actual folder structure

class ParcelOrderPage extends StatefulWidget {
  const ParcelOrderPage({super.key});

  @override
  State<ParcelOrderPage> createState() => _ParcelOrderPageState();
}

class _ParcelOrderPageState extends State<ParcelOrderPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();

  // State Variables
  double _weight = 1.0;
  String _selectedCategory = 'Documents';
  String _selectedPackaging = 'Standard';
  double _estimatedPrice = 10.0;

  // Function to update price dynamically
  void _updatePrice() {
    setState(() {
      _estimatedPrice = PriceCalculator.calculate(
          _weight,
          _selectedCategory,
          _selectedPackaging
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Parcel Booking"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sender & Receiver Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              TextFormField(
                controller: _senderController,
                decoration: const InputDecoration(
                  labelText: "Sender Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? "Enter sender name" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _receiverController,
                decoration: const InputDecoration(
                  labelText: "Receiver Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value!.isEmpty ? "Enter receiver name" : null,
              ),

              const SizedBox(height: 25),
              const Text("Parcel Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: ['Documents', 'Electronics', 'Fragile', 'Clothing']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  _selectedCategory = val!;
                  _updatePrice();
                },
              ),

              const SizedBox(height: 20),
              Text("Weight: ${_weight.toStringAsFixed(1)} kg",
                  style: const TextStyle(fontSize: 16)),
              Slider(
                value: _weight,
                min: 0.5,
                max: 50.0,
                divisions: 99,
                label: "${_weight.toStringAsFixed(1)} kg",
                onChanged: (val) {
                  setState(() => _weight = val);
                  _updatePrice();
                },
              ),

              const SizedBox(height: 20),
              const Text("Packaging Option", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildPackagingChip("Standard"),
                  const SizedBox(width: 10),
                  _buildPackagingChip("Premium"),
                  const SizedBox(width: 10),
                  _buildPackagingChip("Eco"),
                ],
              ),

              const SizedBox(height: 30),

              // Dynamic Price Card
              Card(
                color: Colors.blue.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Estimated Total:", style: TextStyle(fontSize: 18)),
                      Text("\$${_estimatedPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Logic to proceed to Map/Payment
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Processing Booking..."))
                      );
                    }
                  },
                  child: const Text("Select Pickup Location", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackagingChip(String label) {
    bool isSelected = _selectedPackaging == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPackaging = label);
          _updatePrice();
        }
      },
    );
  }
}

class PriceCalculator {
  static double calculate(double weight, String category, String packaging) {
    double base = 10.0;
    double weightCost = weight * 2.0;
    // Add your logic here...
    return base + weightCost;
  }
}