import 'package:flutter/material.dart';
import 'package:wabi/Recompensas.dart';
import 'package:wabi/estadisticas.dart';
import 'package:wabi/inicio.dart';
import 'package:wabi/notificaciones.dart';
import 'package:wabi/perfil.dart';
import 'package:wabi/login.dart';

class Menu extends StatefulWidget {
  final String nombreUsuario;
  final int idUsuario;

  const Menu({super.key, required this.nombreUsuario, required this.idUsuario});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Key _keyInicio = UniqueKey();
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Inicio",
    "Perfil",
    "Estadísticas",
    "Notificaciones",
    "Recompensas",
  ];

  void _onSelectScreen(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // Cierra el Drawer
  }

  void _actualizarInicio() {
    setState(() {
      _keyInicio = UniqueKey(); // Fuerza la reconstrucción de Inicio
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Inicio(
        key: _keyInicio,
        nombreUsuario: widget.nombreUsuario,
        idUsuario: widget.idUsuario,
      ),
      Perfil(
        idUsuario: widget.idUsuario,
        onPerfilActualizado: _actualizarInicio,
      ),
      Estadisticas(idUsuario: widget.idUsuario, metaLitros: 2.0),
      Notificaciones(idUsuario: widget.idUsuario),
      Recompensas(idUsuario: widget.idUsuario),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontSize: 25,
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo_azul.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Wabi",
                    style: TextStyle(
                      fontFamily: "Pacifico",
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, "Inicio", 0),
            _buildDrawerItem(Icons.person, "Perfil", 1),
            _buildDrawerItem(Icons.bar_chart, "Estadísticas", 2),
            _buildDrawerItem(Icons.notifications, "Notificaciones", 3),
            _buildDrawerItem(Icons.star, "Recompensas", 4),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        tileColor: isSelected ? Colors.blueAccent : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.blueAccent,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueAccent,
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => _onSelectScreen(index),
      ),
    );
  }
}
