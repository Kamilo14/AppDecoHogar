import 'package:app_deco_hogar/features/productos/domain/entities/producto_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lógica de Simulación Proporcional (Regla 8.5)', () {
    test('Debe calcular la comisión proporcionalmente al costo de compra', () {
      // 1. Productos con diferentes inversiones
      const p1 = Producto(id: 1, nombre: 'Caro', precioCompra: 10000, cantidadDisponible: 1, precioVenta: 20000);
      const p2 = Producto(id: 2, nombre: 'Barato', precioCompra: 2000, cantidadDisponible: 1, precioVenta: 4000);
      
      final productos = [p1, p2];
      final totalInversion = productos.fold<int>(0, (sum, p) => sum + (p.precioCompra! * p.cantidadDisponible));
      
      // 2. Monto a recuperar del viaje: $6.000
      const montoRecuperar = 6000;
      
      // 3. Cálculos manuales esperados:
      // p1: $10.000 / $12.000 = 83.33% de la inversión. $6.000 * 0.833 = $5.000
      // p2: $2.000 / $12.000 = 16.66% de la inversión. $6.000 * 0.166 = $1.000
      
      double calcComision(Producto p) {
        final peso = (p.precioCompra! * p.cantidadDisponible) / totalInversion;
        return (montoRecuperar * peso) / p.cantidadDisponible;
      }

      expect(calcComision(p1).round(), 5000);
      expect(calcComision(p2).round(), 1000);
      
      // 4. Verificamos precios finales sugeridos
      expect(p1.precioVenta! + calcComision(p1).round(), 25000);
      expect(p2.precioVenta! + calcComision(p2).round(), 5000);
    });
  });
}
