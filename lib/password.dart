import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    this.label = 'Contraseña',
    required this.controller,
    required this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility,
          ),
          onPressed: _togglePasswordView,
        ),
      ),
    );
  }
}
