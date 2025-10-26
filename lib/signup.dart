import 'package:flutter/material.dart';
import 'package:wabi/bd/operaciones.dart';
import 'package:wabi/login.dart';
import 'package:wabi/modelo/note.dart';

class Registrar extends StatefulWidget {
  const Registrar({super.key});

  @override
  State<Registrar> createState() => _RegistrarState();
}

class _RegistrarState extends State<Registrar> {
  final _keyForm = GlobalKey<FormState>();

  final usuarioControlador = TextEditingController();
  final correoUsuario = TextEditingController();
  final contrasenaControlador = TextEditingController();
  final confirmarContrasenaControlador = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFF5271FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Form(
            key: _keyForm,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                ClipOval(
                  child: Image.asset(
                    "assets/images/logo_blanco.png", // Asegúrate de que esta imagen exista
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Wabi',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 48,
                    color: Color(0xFF5271FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'SignUp',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Nombre de usuario
                TextFormField(
                  controller: usuarioControlador,
                  validator: (value) => value!.isEmpty ? "Campo vacío" : null,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Nombre de usuario",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),

                // Correo
                TextFormField(
                  controller: correoUsuario,
                  validator: (value) => value!.isEmpty ? "Campo vacío" : null,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Correo electrónico",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 10),

                // Contraseña
                TextFormField(
                  controller: contrasenaControlador,
                  validator: (value) => value!.isEmpty ? "Campo vacío" : null,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility_off_outlined),
                  ),
                ),
                const SizedBox(height: 10),

                // Confirmar contraseña
                TextFormField(
                  controller: confirmarContrasenaControlador,
                  validator: (value) => value!.isEmpty ? "Campo vacío" : null,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Confirmar contraseña",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility_off_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón de registrar
                ElevatedButton(
                  onPressed: () {
                    if (_keyForm.currentState!.validate()) {
                      if (contrasenaControlador.text ==
                          confirmarContrasenaControlador.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Usuario registrado exitosamente'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        Operaciones.insertarUsuario(
                          Note(
                            usuario: usuarioControlador.text,
                            correo: correoUsuario.text,
                            contrasena: contrasenaControlador.text,
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            title: Icon(Icons.error_outline, color: Colors.red),
                            content: Text("Las contraseñas no coinciden"),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5271FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                // Botón de ir a Login
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "¿Ya tienes cuenta? Inicia sesión",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
