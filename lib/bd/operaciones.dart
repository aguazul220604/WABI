import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wabi/modelo/note.dart';
import 'package:wabi/modelo/perfil_datos.dart';
import 'package:wabi/modelo/notificaciones_datos.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Operaciones {
  // Abre o crea la base de datos
  static Future<Database> _abrirBD() async {
    return openDatabase(
      join(await getDatabasesPath(), 'appDB.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT,
            correo TEXT,
            contrasena TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS perfil (
            id INTEGER PRIMARY KEY,
            genero TEXT,
            peso REAL,
            estatura REAL,
            nivelActividad TEXT,
            FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS consumo_agua (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            fecha TEXT,
            mililitros INTEGER,
            FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE
          ) 
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS notificaciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            hora_inicio INTEGER,
            hora_fin INTEGER,
            canal INTEGER,
            FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE
          ) 
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS mascotas (
            id INTEGER PRIMARY KEY,
            nombre TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS mascota_usuario (
            id_usuario INTEGER PRIMARY KEY,
            id_mascota INTEGER,
            FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE,
            FOREIGN KEY (id_mascota) REFERENCES mascotas(id)
          );
        ''');
      },
      version: 1,
    );
  }

  static Future<void> enviarNotificacionPrueba({required int canal}) async {
    String destino = switch (canal) {
      1 => 'Smartphone',
      2 => 'Smartwatch',
      3 => 'Smartphone y Smartwatch',
      _ => 'Dispositivo',
    };

    await flutterLocalNotificationsPlugin.show(
      999, // ID arbitrario
      '¡Notificación de prueba!',
      'Esto es una prueba para $destino 💧',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_id',
          'Notificaciones Wabi',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
  // -------------------- USUARIOS --------------------

  // Insertar nuevo usuario
  static Future<void> insertarUsuario(Note note) async {
    final db = await _abrirBD();
    await db.insert('usuarios', note.toMap());
  }

  // Consultar todos los usuarios
  static Future<List<Note>> consultaUsuarios() async {
    final db = await _abrirBD();
    final List<Map<String, dynamic>> resultado = await db.query('usuarios');

    return List.generate(resultado.length, (index) {
      return Note(
        id: resultado[index]['id'],
        usuario: resultado[index]['usuario'],
        correo: resultado[index]['correo'],
        contrasena: resultado[index]['contrasena'],
      );
    });
  }

  // Actualizar datos de un usuario
  static Future<void> actualizarUsuario(Note note) async {
    final db = await _abrirBD();
    await db.update(
      'usuarios',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Eliminar un usuario
  static Future<void> eliminarUsuario(int id) async {
    final db = await _abrirBD();
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  // Buscar usuario por nombre y contraseña (para login)
  static Future<Note?> autenticarUsuario(
    String usuario,
    String contrasena,
  ) async {
    final db = await _abrirBD();
    final resultado = await db.query(
      'usuarios',
      where: 'usuario = ? AND contrasena = ?',
      whereArgs: [usuario, contrasena],
    );

    if (resultado.isNotEmpty) {
      final u = resultado.first;
      return Note(
        id: u['id'] as int?,
        usuario: u['usuario'] as String,
        correo: u['correo'] as String,
        contrasena: u['contrasena'] as String,
      );
    }

    return null;
  }

  // -------------------- PERFIL --------------------

  // Insertar o actualizar datos del perfil
  static Future<void> upsertPerfil(PerfilDatos perfil) async {
    final db = await _abrirBD();
    await db.insert(
      'perfil',
      perfil.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener perfil por ID de usuario
  static Future<PerfilDatos?> obtenerPerfil(int idUsuario) async {
    final db = await _abrirBD();
    final resultado = await db.query(
      'perfil',
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (resultado.isNotEmpty) {
      final p = resultado.first;
      return PerfilDatos(
        id: p['id'] as int?,
        genero: p['genero'] as String?,
        peso: p['peso'] != null ? double.tryParse(p['peso'].toString()) : null,
        estatura: p['estatura'] != null
            ? double.tryParse(p['estatura'].toString())
            : null,
        nivelActividad: p['nivelActividad'] as String?,
      );
    }

    return null;
  }

  // Eliminar perfil (por si eliminas cuenta)
  static Future<void> eliminarPerfil(int idUsuario) async {
    final db = await _abrirBD();
    await db.delete('perfil', where: 'id = ?', whereArgs: [idUsuario]);
  }

  // Obtener usuario por ID
  static Future<Note?> obtenerUsuarioPorId(int idUsuario) async {
    final db = await _abrirBD();
    final resultado = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (resultado.isNotEmpty) {
      final u = resultado.first;
      return Note(
        id: u['id'] as int?,
        usuario: u['usuario'] as String,
        correo: u['correo'] as String,
        contrasena: u['contrasena'] as String,
      );
    }

    return null;
  }

  // Actualizar solo usuario y correo
  static Future<void> actualizarDatosUsuario(
    int id,
    String usuario,
    String correo,
  ) async {
    final db = await _abrirBD();
    await db.update(
      'usuarios',
      {'usuario': usuario, 'correo': correo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------- CONSUMO DE AGUA --------------------

  // Insertar nuevo registro de agua
  static Future<void> registrarConsumoAgua(
    int idUsuario,
    int mililitros,
  ) async {
    final db = await _abrirBD();
    final fechaHoy = DateTime.now().toIso8601String().substring(0, 10);
    await db.insert('consumo_agua', {
      'id_usuario': idUsuario,
      'fecha': fechaHoy,
      'mililitros': mililitros,
    });
  }

  // Obtener total de agua consumida hoy
  static Future<int> obtenerConsumoHoy(int idUsuario) async {
    final db = await _abrirBD();
    final fechaHoy = DateTime.now().toIso8601String().substring(0, 10);
    final resultado = await db.rawQuery(
      '''
    SELECT SUM(mililitros) as total
    FROM consumo_agua
    WHERE id_usuario = ? AND fecha = ?
  ''',
      [idUsuario, fechaHoy],
    );

    return resultado.first['total'] as int? ?? 0;
  }

  // -------------------- NOTIFICACIONES --------------------

  // Insertar o actualizar datos de notificaiones
  static Future<void> upsertNotificaciones(
    NotificacionesDatos notificacion,
  ) async {
    final db = await _abrirBD();
    await db.insert(
      'notificaciones',
      notificacion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener notificaiones por ID de usuario
  static Future<NotificacionesDatos?> obtenerNotificaciones(
    int idUsuario,
  ) async {
    final db = await _abrirBD();
    final resultado = await db.query(
      'notificaciones',
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (resultado.isNotEmpty) {
      final n = resultado.first;
      return NotificacionesDatos(
        id: n['id'] as int?,
        hora_inicio: n['hora_inicio'] as int?,
        hora_fin: n['hora_fin'] as int?,
        canal: n['canal'] as int?,
      );
    }

    return null;
  }

  // -------------------- MASCOTAS --------------------

  static Future<void> asignarMascotaUsuario(
    int idUsuario,
    int idMascota,
  ) async {
    final db = await _abrirBD();

    await db.insert('mascotas', {
      'id': idMascota,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('mascota_usuario', {
      'id_usuario': idUsuario,
      'id_mascota': idMascota,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> obtenerMascotaSeleccionada(
    int idUsuario,
  ) async {
    final db = await _abrirBD();
    final resultado = await db.rawQuery(
      '''
    SELECT m.id, m.nombre
    FROM mascota_usuario mu
    JOIN mascotas m ON mu.id_mascota = m.id
    WHERE mu.id_usuario = ?
    ''',
      [idUsuario],
    );

    if (resultado.isNotEmpty) return resultado.first;
    return null;
  }

  static Future<int> obtenerRachaUsuario(int idUsuario) async {
    final db = await _abrirBD();

    final resultado = await db.rawQuery(
      '''
    SELECT DISTINCT fecha 
    FROM consumo_agua 
    WHERE id_usuario = ? 
    ORDER BY fecha DESC
    ''',
      [idUsuario],
    );

    if (resultado.isEmpty) return 0;

    int racha = 0;
    DateTime hoy = DateTime.now();

    for (var row in resultado) {
      final fechaStr = row['fecha'] as String;
      final fecha = DateTime.parse(fechaStr);
      final diferencia = hoy.difference(fecha).inDays;

      if (diferencia == 0 || diferencia == racha) {
        racha++;
      } else {
        break;
      }
    }

    return racha;
  }

  // -------------------- OBTENER BD --------------------

  static Future<Database> obtenerBD() async {
    return _abrirBD();
  }
}
