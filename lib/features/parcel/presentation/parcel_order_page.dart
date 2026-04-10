import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'parcel_summary_page.dart';

class ParcelOrderPage extends StatefulWidget {
  const ParcelOrderPage({super.key});

  @override
  State<ParcelOrderPage> createState() => _ParcelOrderPageState();
}

class _ParcelOrderPageState extends State<ParcelOrderPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _pickupAddressController = TextEditingController();
  
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();

  // State Variables
  double _weight = 1.0;
  String _selectedCategory = 'Documents';
  String _selectedPackaging = 'Standard';
  double _estimatedPrice = 10.0;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _senderController.dispose();
    _senderPhoneController.dispose();
    _pickupAddressController.dispose();
    _receiverController.dispose();
    _receiverPhoneController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  void _updatePrice() {
    setState(() {
      _estimatedPrice = PriceCalculator.calculate(
          _weight,
          _selectedCategory,
          _selectedPackaging
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("New Parcel Booking", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Pickup Details"),
              _buildPickupCard(),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Delivery Details"),
              _buildDeliveryCard(),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Parcel Details"),
              _buildParcelCard(),

              const SizedBox(height: 32),
              _buildPriceCard(),

              const SizedBox(height: 24),
              _buildConfirmButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildPickupCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_senderController, "Sender Name", Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(_senderPhoneController, "Sender Phone", Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(_pickupAddressController, "Pickup Address", Icons.location_on_outlined, maxLines: 2),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: _buildDateTimeSelector("Date", DateFormat('MMM dd, yyyy').format(_selectedDate), Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: _buildDateTimeSelector("Time", _selectedTime.format(context), Icons.access_time),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_receiverController, "Receiver Name", Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(_receiverPhoneController, "Receiver Phone", Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(_deliveryAddressController, "Delivery Address", Icons.map_outlined, maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
              items: ['Documents', 'Electronics', 'Fragile', 'Clothing']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedCategory = val!);
                _updatePrice();
              },
            ),
            const SizedBox(height: 20),
            Text("Weight: ${_weight.toStringAsFixed(1)} kg", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            Slider(
              value: _weight,
              min: 0.5,
              max: 50.0,
              divisions: 99,
              activeColor: Colors.indigo,
              label: "${_weight.toStringAsFixed(1)} kg",
              onChanged: (val) {
                setState(() => _weight = val);
                _updatePrice();
              },
            ),
            const SizedBox(height: 12),
            const Text("Packaging Option", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: ["Standard", "Premium", "Eco"].map((label) => _buildPackagingChip(label)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
    );
  }

  Widget _buildDateTimeSelector(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.indigo),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingChip(String label) {
    bool isSelected = _selectedPackaging == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.indigo.withOpacity(0.1),
      labelStyle: TextStyle(color: isSelected ? Colors.indigo : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.indigo : Colors.grey.shade300)),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPackaging = label);
          _updatePrice();
        }
      },
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade600, Colors.indigo.shade800]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Price", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text("Estimated", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            "\$${_estimatedPrice.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final data = {
              'pickup': _pickupAddressController.text,
              'delivery': _deliveryAddressController.text,
              'packageType': _selectedCategory,
              'price': '\$${_estimatedPrice.toStringAsFixed(2)}',
              'date': DateFormat('MMM dd, yyyy').format(_selectedDate),
              'time': _selectedTime.format(context),
              'sender': _senderController.text,
              'receiver': _receiverController.text,
            };
            
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ParcelSummaryPage(data: data))
            );
          }
        },
        child: const Text("Continue to Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class PriceCalculator {
  static double calculate(double weight, String category, String packaging) {
    double base = 10.0;
    double weightCost = weight * 2.0;
    double packagingCost = packaging == "Premium" ? 5.0 : (packaging == "Eco" ? 2.0 : 0.0);
    return base + weightCost + packagingCost;
  }
}