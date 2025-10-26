import 'package:flutter/material.dart';
import 'package:wabi/modelo/perfil_datos.dart';
import 'package:wabi/bd/operaciones.dart';

class Inicio extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;

  const Inicio({
    super.key,
    required this.nombreUsuario,
    required this.idUsuario,
  });

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  bool _metaAlcanzada = false;
  double? _metaAguaLitros;
  int _consumoMililitros = 0;

  @override
  void initState() {
    super.initState();
    _calcularMetaAgua();
  }

  Future<void> _calcularMetaAgua() async {
    final perfil = await Operaciones.obtenerPerfil(widget.idUsuario);

    if (perfil != null &&
        perfil.peso != null &&
        perfil.nivelActividad != null) {
      double factor = switch (perfil.nivelActividad) {
        'Bajo' => 1.0,
        'Moderado' => 1.1,
        'Alto' => 1.2,
        'Muy alto' => 1.3,
        _ => 1.0,
      };

      final litros = (perfil.peso! * 35 * factor) / 1000;
      final consumo = await Operaciones.obtenerConsumoHoy(widget.idUsuario);
      final metaMililitros = litros * 1000;

      setState(() {
        _metaAguaLitros = double.parse(litros.toStringAsFixed(2));
        _consumoMililitros = consumo;
        _metaAlcanzada = consumo >= metaMililitros;
      });
    } else {
      setState(() {
        _metaAguaLitros = null;
      });
    }
  }

  Future<void> _registrarConsumo(int cantidad) async {
    if (_metaAlcanzada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Ya alcanzaste tu meta de agua hoy! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }
    await Operaciones.registrarConsumoAgua(widget.idUsuario, cantidad);
    await _calcularMetaAgua();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent, // Color de fondo
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/gato.jpg', width: 150, height: 150),
            const SizedBox(height: 20),
            Text(
              'Hola, ${widget.nombreUsuario}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Ajusta el color si es necesario
              ),
            ),
            const SizedBox(height: 10),
            _metaAguaLitros != null
                ? Column(
                    children: [
                      Text(
                        'Tu meta es: $_metaAguaLitros litros de agua',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (_consumoMililitros / (_metaAguaLitros! * 1000))
                            .clamp(0, 1),
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Has tomado ${_consumoMililitros} ml',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _registrarConsumo(250),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            0,
                            33,
                            149,
                            243,
                          ),
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
                          '+ 250ml',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_metaAlcanzada) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green, // Fondo verde
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Bordes redondeados (opcional)
                          ),
                          child: const Text(
                            '🎉 ¡Felicidades! Has alcanzado tu meta de agua hoy',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ), // Texto blanco
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  )
                : const Text(
                    'Completa tu perfil para calcular tu meta de agua',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
          ],
        ),
      ),
    );
  }
}
