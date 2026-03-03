// path: lib/models/user_model.dart

class UserModel {
  final String id;
  String nombre;
  String correo;
  String telefono;
  String direccion;
  String ciudad;
  String rut;
  String numeroCliente;
  String imagenPerfil;
  String role;
  bool activo;
  bool notificacionesSms;
  bool requiereCambioPassword;

  UserModel({
    this.id = '',
    required this.nombre,
    required this.correo,
    this.telefono = '',
    this.direccion = '',
    this.ciudad = '',
    this.rut = '',
    this.numeroCliente = '',
    this.imagenPerfil = '',
    this.role = 'cliente',
    this.activo = true,
    this.notificacionesSms = false,
    this.requiereCambioPassword = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      ciudad: json['ciudad'] ?? '',
      rut: json['rut'] ?? '',
      numeroCliente: json['numeroCliente'] ?? '',
      imagenPerfil: json['imagenPerfil'] ?? '',
      role: json['role'] ?? 'cliente',
      activo: json['activo'] ?? true,
      notificacionesSms: json['notificacionesSms'] ?? false,
      requiereCambioPassword:
          json['passwordTemporal'] != null && json['passwordTemporal'] != '',
    );
  }
}
