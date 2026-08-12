import 'package:app_deco_hogar/features/auth/domain/entities/usuario_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lógica de Saludo del Usuario', () {
    test('Debe extraer el primer nombre correctamente de un nombre completo', () {
      final usuario = Usuario(
        nombre: 'Martina Pérez',
        fechaNacimiento: DateTime(1990, 1, 1),
      );

      expect(usuario.primerNombre, 'Martina');
    });

    test('Debe funcionar correctamente con un solo nombre', () {
      final usuario = Usuario(
        nombre: 'Martina',
        fechaNacimiento: DateTime(1990, 1, 1),
      );

      expect(usuario.primerNombre, 'Martina');
    });

    test('Debe funcionar con nombres compuestos', () {
      final usuario = Usuario(
        nombre: 'Maria José Rodriguez',
        fechaNacimiento: DateTime(1990, 1, 1),
      );

      expect(usuario.primerNombre, 'Maria');
    });
  });
}
