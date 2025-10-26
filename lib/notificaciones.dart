import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wabi/bd/operaciones.dart';
import 'package:wabi/global.dart';
import 'package:wabi/modelo/notificaciones_datos.dart';

class Notificaciones extends StatefulWidget {
  final int idUsuario;

  const Notificaciones({super.key, required this.idUsuario});

  @override
  State<Notificaciones> createState() => _NotificacionesState();
}

class _NotificacionesState extends State<Notificaciones> {
  final TextEditingController _inicioController = TextEditingController();
  final TextEditingController _finController = TextEditingController();
  String dispositivoSeleccionado = 'smartphone';

  @override
  void initState() {
    super.initState();
    UsuarioGlobal.idUsuario = widget.idUsuario; // 👈 Aquí
    _configurarNotificaciones();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await Operaciones.obtenerNotificaciones(widget.idUsuario);

    if (datos != null) {
      setState(() {
        _inicioController.text = _formatearHora(datos.hora_inicio);
        _finController.text = _formatearHora(datos.hora_fin);

        switch (datos.canal) {
          case 1:
            dispositivoSeleccionado = 'smartphone';
            break;
          case 2:
            dispositivoSeleccionado = 'smartwatch';
            break;
          case 3:
            dispositivoSeleccionado = 'ambos';
            break;
        }
      });
    }
  }

  String _formatearHora(int? horaEnMinutos) {
    if (horaEnMinutos == null) return '';
    final horas = horaEnMinutos ~/ 60;
    final minutos = horaEnMinutos % 60;
    final time = TimeOfDay(hour: horas, minute: minutos);
    return time.format(context);
  }

  int? _parsearHora(String texto) {
    try {
      final parts = texto.split(RegExp(r'[: ]'));
      final hora = int.parse(parts[0]);
      final minutos = int.parse(parts[1]);
      final ampm = texto.toLowerCase().contains('pm');

      int hora24 = ampm && hora != 12 ? hora + 12 : hora;
      if (!ampm && hora == 12) hora24 = 0;

      return hora24 * 60 + minutos;
    } catch (_) {
      return null;
    }
  }

  int _canalDesdeString(String valor) {
    switch (valor) {
      case 'smartphone':
        return 1;
      case 'smartwatch':
        return 2;
      case 'ambos':
        return 3;
      default:
        return 1;
    }
  }

  Future<void> _guardar() async {
    final inicioMin = _parsearHora(_inicioController.text);
    final finMin = _parsearHora(_finController.text);
    final canal = _canalDesdeString(dispositivoSeleccionado);

    if (inicioMin == null || finMin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa horarios válidos')),
      );
      return;
    }

    final noti = NotificacionesDatos(
      id: widget.idUsuario,
      hora_inicio: inicioMin,
      hora_fin: finMin,
      canal: canal,
    );

    await Operaciones.upsertNotificaciones(noti);
    await Operaciones.enviarNotificacionPrueba(canal: canal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificaciones guardadas exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _seleccionarHora(TextEditingController controller) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      controller.text = hora.format(context);
    }
  }

  Widget _buildTimePickerField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: SizedBox(
              width: 350,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Seleccionar hora',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _configurarNotificaciones() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'registrar_consumo') {
          final id = UsuarioGlobal.idUsuario;
          if (id != null) {
            await Operaciones.registrarConsumoAgua(id, 250);
            print('Agua registrada desde notificación (ID: $id)');
          } else {
            print('No se encontró idUsuario al procesar la notificación.');
          }
        }
      },
    );
  }

  Future<void> enviarNotificacionConBoton() async {
    await flutterLocalNotificationsPlugin.show(
      1001,
      '¡Hora de beber agua!',
      'Recuerda tomar un vaso de agua 💧',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_id',
          'Notificaciones Wabi',
          importance: Importance.max,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction('registrar_consumo', 'Ya tomé agua'),
          ],
        ),
      ),
      payload: widget.idUsuario.toString(), // Pasamos el ID
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Horario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            _buildTimePickerField(
              label: 'Horario de inicio:',
              controller: _inicioController,
              onTap: () => _seleccionarHora(_inicioController),
            ),
            const SizedBox(height: 20),

            _buildTimePickerField(
              label: 'Horario de fin:',
              controller: _finController,
              onTap: () => _seleccionarHora(_finController),
            ),
            const SizedBox(height: 30),

            const Text(
              'Sincronización',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            RadioListTile<String>(
              title: const Text(
                'Smartphone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              value: 'smartphone',
              groupValue: dispositivoSeleccionado,
              onChanged: (value) {
                setState(() {
                  dispositivoSeleccionado = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text(
                'Smartwatch',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              value: 'smartwatch',
              groupValue: dispositivoSeleccionado,
              onChanged: (value) {
                setState(() {
                  dispositivoSeleccionado = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text(
                'Ambos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              value: 'ambos',
              groupValue: dispositivoSeleccionado,
              onChanged: (value) {
                setState(() {
                  dispositivoSeleccionado = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: enviarNotificacionConBoton,
              label: const Text('Guardar datos'),
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
            ),
          ],
        ),
      ),
    );
  }
}
