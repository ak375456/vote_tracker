import 'package:flutter/material.dart';

class DateOfBirthFormField extends StatefulWidget {
  const DateOfBirthFormField({
    super.key,
    required this.controller,
    required this.validator,
  });

  final TextEditingController controller;
  final String? Function(DateTime?) validator;

  @override
  _DateOfBirthFormFieldState createState() => _DateOfBirthFormFieldState();
}

class _DateOfBirthFormFieldState extends State<DateOfBirthFormField> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Use a different format for setting the text
        widget.controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: widget.controller,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your date of birth';
        }
        DateTime? selectedDate = DateTime.tryParse(value);
        if (selectedDate == null) {
          return 'Please enter a valid date...';
        }
        DateTime currentDate = DateTime.now();
        DateTime minDate = DateTime(
          currentDate.year - 6,
          currentDate.month,
          currentDate.day,
        );
        if (selectedDate.isAfter(minDate)) {
          return 'You must be at least 6 years old';
        }

        return widget.validator(selectedDate);
      },
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        prefixIcon: Icon(Icons.calendar_today),
        focusColor: Colors.blue,
      ),
    );
  }
}
