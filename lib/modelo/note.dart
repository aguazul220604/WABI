class Note {
  int? id;
  String usuario;
  String correo;
  String contrasena;

  Note({
    this.id,
    required this.usuario,
    required this.correo,
    required this.contrasena,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario': usuario,
      'correo': correo,
      'contrasena': contrasena,
    };
  }
}
