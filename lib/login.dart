import 'package:flutter/material.dart';
import 'package:wabi/menu.dart';
import 'package:wabi/modelo/note.dart';
import 'package:wabi/bd/operaciones.dart';
import 'package:wabi/signup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _error = false;

  void _login() async {
    String usuario = _usuarioController.text.trim();
    String contrasena = _contrasenaController.text.trim();

    Note? user = await Operaciones.autenticarUsuario(usuario, contrasena);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Menu(nombreUsuario: user.usuario, idUsuario: user.id!),
        ),
      );
    } else {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFF5271FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo circular
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo_blanco.png',
                    width: 130,
                    height: 130,
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
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Usuario
                TextField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),

                // Contraseña
                TextField(
                  controller: _contrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5271FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: const Text(
                    "Ingresar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                if (_error)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      "Usuario o contraseña incorrectos",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 20),

                // Botón Registrarse
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Registrar(),
                      ),
                    );
                  },
                  child: const Text(
                    "¿No tienes cuenta? Regístrate",
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
