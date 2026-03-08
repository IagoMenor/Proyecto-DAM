class Mascota {
  final int? id;
  final String nombre;
  final String especie;
  final String? raza;
  final String? fotoPath;

  Mascota({this.id, required this.nombre, required this.especie, this.raza, this.fotoPath});

  // Convierte un objeto Mascota en un Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'fotoPath': fotoPath,
    };
  }

  // Convierte un Map de SQLite en un objeto Mascota
  factory Mascota.fromMap(Map<String, dynamic> map) {
    return Mascota(
      id: map['id'],
      nombre: map['nombre'],
      especie: map['especie'],
      raza: map['raza'],
      fotoPath: map['fotoPath'],
    );
  }
}