import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wabi/bd/operaciones.dart';
import 'dart:math';

class Estadisticas extends StatefulWidget {
  final int idUsuario;
  final double metaLitros;

  const Estadisticas({
    Key? key,
    required this.idUsuario,
    required this.metaLitros,
  }) : super(key: key);

  @override
  State<Estadisticas> createState() => _EstadisticasState();
}

class _EstadisticasState extends State<Estadisticas> {
  String vistaSeleccionada = 'Semanal';

  Future<List<FlSpot>> _obtenerConsumoSemanal() async {
    final db = await Operaciones.obtenerBD(); // <- CORRECTO
    final hoy = DateTime.now();
    final hace6Dias = hoy.subtract(const Duration(days: 6));

    final result = await db.rawQuery(
      '''
    SELECT fecha, SUM(mililitros) as total
    FROM consumo_agua
    WHERE id_usuario = ? AND DATE(fecha) BETWEEN DATE(?) AND DATE(?)
    GROUP BY DATE(fecha)
    ''',
      [
        widget.idUsuario,
        hace6Dias.toIso8601String().substring(0, 10),
        hoy.toIso8601String().substring(0, 10),
      ],
    );

    // Inicializa los 7 días en 0
    List<FlSpot> spots = List.generate(7, (i) => FlSpot(i.toDouble(), 0));

    for (var fila in result) {
      DateTime fecha = DateTime.parse(fila['fecha'].toString());
      int index = fecha.difference(hace6Dias).inDays;
      if (index >= 0 && index < 7) {
        double litros = (fila['total'] as int).toDouble() / 1000;
        spots[index] = FlSpot(index.toDouble(), litros);
      }
    }

    return spots;
  }

  Future<Map<int, bool>> _obtenerDiasConMetaCumplida() async {
    final db = await Operaciones.obtenerBD();
    final hoy = DateTime.now();
    final inicioMes = DateTime(hoy.year, hoy.month, 1);
    final finMes = DateTime(hoy.year, hoy.month + 1, 0);

    final result = await db.rawQuery(
      '''
    SELECT fecha, SUM(mililitros) as total
    FROM consumo_agua
    WHERE id_usuario = ? AND DATE(fecha) BETWEEN DATE(?) AND DATE(?)
    GROUP BY DATE(fecha)
  ''',
      [
        widget.idUsuario,
        inicioMes.toIso8601String().substring(0, 10),
        finMes.toIso8601String().substring(0, 10),
      ],
    );

    Map<int, bool> diasCumplidos = {};

    for (var fila in result) {
      DateTime fecha = DateTime.parse(fila['fecha'].toString());
      double litros = (fila['total'] as int).toDouble() / 1000;
      diasCumplidos[fecha.day] = litros >= widget.metaLitros;
    }

    return diasCumplidos;
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
              'Progreso',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: Colors.white,
                  child: DropdownButton<String>(
                    value: vistaSeleccionada,
                    onChanged: (String? newValue) {
                      setState(() {
                        vistaSeleccionada = newValue!;
                      });
                    },
                    items: <String>['Semanal'].map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 👇 Aquí va tu gráfica dinámica
            SizedBox(
              width: 350,
              child: FutureBuilder<List<FlSpot>>(
                future: _obtenerConsumoSemanal(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Error al cargar datos');
                  }

                  final datos = snapshot.data!;

                  return Container(
                    height: 200,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const dias = [
                                  'L',
                                  'M',
                                  'M',
                                  'J',
                                  'V',
                                  'S',
                                  'D',
                                ];
                                if (value.toInt() >= 0 && value.toInt() < 7) {
                                  return Text(dias[value.toInt()]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: datos,
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.blue,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        gridData: FlGridData(show: true),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              'Racha',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: 350,
              child: FutureBuilder<Map<int, bool>>(
                future: _obtenerDiasConMetaCumplida(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Error al cargar calendario');
                  }

                  final dias = snapshot.data!;
                  final hoy = DateTime.now();
                  final diasMes = DateTime(hoy.year, hoy.month + 1, 0).day;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: diasMes,
                    itemBuilder: (context, index) {
                      final dia = index + 1;
                      final cumplido = dias[dia] ?? false;

                      return Container(
                        decoration: BoxDecoration(
                          color: cumplido ? Colors.green[300] : Colors.red[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            dia.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
