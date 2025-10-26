import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({super.key});

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
    return TextField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Contraseña',
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
