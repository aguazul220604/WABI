class NotificacionesDatos {
  final int? id;
  final int? hora_inicio;
  final int? hora_fin;
  final int? canal;

  NotificacionesDatos({
    required this.id,
    this.hora_inicio,
    this.hora_fin,
    this.canal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hora_inicio': hora_inicio,
      'hora_fin': hora_fin,
      'canal': canal,
    };
  }
}
