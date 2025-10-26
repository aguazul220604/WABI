import 'package:flutter/material.dart';
import 'package:wabi/bd/operaciones.dart';
import 'package:wabi/modelo/perfil_datos.dart';

class Perfil extends StatefulWidget {
  final int idUsuario;
  final String? nombreUsuario;
  final void Function()? onPerfilActualizado;

  const Perfil({
    super.key,
    required this.idUsuario,
    this.nombreUsuario,
    this.onPerfilActualizado,
  });

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  // Controladores
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController estaturaController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController correoController = TextEditingController();

  // Selecciones
  String? generoSeleccionado;
  String? nivelActividad;

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  Future<void> _cargarDatosPerfil() async {
    final perfil = await Operaciones.obtenerPerfil(widget.idUsuario);
    if (perfil != null) {
      setState(() {
        generoSeleccionado = perfil.genero;
        pesoController.text = perfil.peso?.toString() ?? '';
        estaturaController.text = perfil.estatura?.toString() ?? '';
        nivelActividad = perfil.nivelActividad;
      });
    }
    setState(() {
      _cargando = false;
    });
  }

  Future<void> _guardarDatos() async {
    final perfil = PerfilDatos(
      id: widget.idUsuario,
      genero: generoSeleccionado,
      peso: double.tryParse(pesoController.text),
      estatura: double.tryParse(estaturaController.text),
      nivelActividad: nivelActividad,
    );

    await Operaciones.upsertPerfil(perfil);

    // Llamar al callback para actualizar Inicio
    widget.onPerfilActualizado?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos personales guardados exitosamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    pesoController.dispose();
    estaturaController.dispose();
    usernameController.dispose();
    correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.blueAccent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Datos personales',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),

            // Género
            SizedBox(
              width: 350,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Género',
                  prefixIcon: Icon(Icons.person),
                ),
                value: generoSeleccionado,
                items: ['Hombre', 'Mujer']
                    .map(
                      (genero) =>
                          DropdownMenuItem(value: genero, child: Text(genero)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    generoSeleccionado = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Peso
            SizedBox(
              width: 350,
              child: TextField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Estatura
            SizedBox(
              width: 350,
              child: TextField(
                controller: estaturaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Estatura (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nivel de actividad física
            SizedBox(
              width: 350,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nivel de actividad física',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                value: nivelActividad,
                items: ['Bajo', 'Moderado', 'Alto', 'Muy alto']
                    .map(
                      (nivel) =>
                          DropdownMenuItem(value: nivel, child: Text(nivel)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    nivelActividad = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _guardarDatos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(0, 33, 149, 243),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: const Text(
                  'Guardar datos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
