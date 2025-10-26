class PerfilDatos {
  final int? id;
  final String? genero;
  final double? peso;
  final double? estatura;
  final String? nivelActividad;

  PerfilDatos({
    required this.id,
    this.genero,
    this.peso,
    this.estatura,
    this.nivelActividad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'genero': genero,
      'peso': peso?.toString(),
      'estatura': estatura?.toString(),
      'nivelActividad': nivelActividad,
    };
  }
}
