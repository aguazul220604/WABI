import 'package:flutter/material.dart';
import 'package:wabi/bd/operaciones.dart'; // Ajusta esta importación si tu estructura de carpetas es diferente

class Recompensas extends StatefulWidget {
  final int idUsuario;

  const Recompensas({super.key, required this.idUsuario});

  @override
  State<Recompensas> createState() => _RecompensasState();
}

class _RecompensasState extends State<Recompensas> {
  int _selectedIndex = 0;
  int _racha = 0;
  bool _guardadoExitoso = false;

  final List<Map<String, dynamic>> mascotas = [
    {
      'id': 1,
      'nombre': 'Chimuelo',
      'imagen': 'assets/images/gato.jpg',
      'racha': 0,
    },
    {
      'id': 2,
      'nombre': 'Firulais',
      'imagen': 'assets/images/perro.jpg',
      'racha': 3,
    },
    {
      'id': 3,
      'nombre': 'Capibara peruano',
      'imagen': 'assets/images/capibara.jpeg',
      'racha': 7,
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarRacha();
  }

  Future<void> _cargarRacha() async {
    final racha = await Operaciones.obtenerRachaUsuario(widget.idUsuario);
    setState(() {
      _racha = racha;
    });
  }

  void _guardarMascota() async {
    final mascota = mascotas[_selectedIndex];

    if (_racha >= mascota['racha']) {
      await Operaciones.asignarMascotaUsuario(widget.idUsuario, mascota['id']);

      setState(() {
        _guardadoExitoso = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mascota seleccionada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _guardadoExitoso = false;
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Necesitas una racha de ${mascota['racha']} días para desbloquear a ${mascota['nombre']}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotaActual = mascotas[_selectedIndex];
    final desbloqueada = _racha >= mascotaActual['racha'];

    return Container(
      color: Colors.blueAccent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Elige una mascota!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 90),

            SizedBox(
              height: 230,
              child: PageView.builder(
                itemCount: mascotas.length,
                controller: PageController(viewportFraction: 0.8),
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final mascota = mascotas[index];
                  final esDesbloqueada = _racha >= mascota['racha'];

                  return Opacity(
                    opacity: esDesbloqueada ? 1.0 : 0.4,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: esDesbloqueada
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              mascota['imagen'],
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mascota['nombre'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            esDesbloqueada
                                ? 'Desbloqueada 🎉'
                                : 'Requiere ${mascota['racha']} días',
                            style: TextStyle(
                              fontSize: 12,
                              color: esDesbloqueada
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Botón guardar
            ElevatedButton(
              onPressed: _guardarMascota,
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
                'Seleccionar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Mejora tu racha para desbloquear más mascotas',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
