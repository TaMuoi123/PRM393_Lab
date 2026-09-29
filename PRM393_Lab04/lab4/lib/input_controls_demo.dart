import 'package:flutter/material.dart';

class InputControlsDemo extends StatefulWidget {
  const InputControlsDemo({super.key});

  @override
  State<InputControlsDemo> createState() => _InputControlsDemoState();
}

class _InputControlsDemoState extends State<InputControlsDemo> {
  double _sliderValue = 50;
  bool _switchValue = false;
  String _radioValue = 'None';
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFFF9F9FB),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Exercise 2 – Input Contr...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating (Slider)
            const Text('Rating (Slider)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              activeColor: Colors.indigo.shade400,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
            Text('Current value: ${_sliderValue.toInt()}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 24),
            
            // Active (Switch)
            const Text('Active (Switch)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Text('Is movie active?', style: TextStyle(fontSize: 16, color: Colors.black87)),
                ),
                Switch(
                  value: _switchValue,
                  activeColor: Colors.indigo.shade400,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Genre (RadioListTile)
            const Text('Genre (RadioListTile)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            RadioListTile<String>(
              title: const Text('Action', style: TextStyle(color: Colors.black87)),
              value: 'Action',
              groupValue: _radioValue,
              activeColor: Colors.indigo.shade400,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _radioValue = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Comedy', style: TextStyle(color: Colors.black87)),
              value: 'Comedy',
              groupValue: _radioValue,
              activeColor: Colors.indigo.shade400,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _radioValue = value!;
                });
              },
            ),
            Text('Selected genre: $_radioValue', style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 24),

            // DatePicker button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5FA),
                  foregroundColor: Colors.indigo.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _pickDate(context),
                child: Text(_selectedDate == null ? 'Open Date Picker' : 'Selected: ${_selectedDate!.toLocal()}'.split(' ')[0]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
