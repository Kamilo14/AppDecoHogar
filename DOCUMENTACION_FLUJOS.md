# 🏠 Guía de Funcionamiento - AppDecoHogar

Esta aplicación está diseñada para gestionar el ciclo completo de un negocio de decoración, desde la captación de un cliente hasta la entrega final y el análisis de ganancias.

## 🔄 1. Flujo de Clientes
El cliente es el núcleo de la aplicación. Todo encargo o pago debe estar asociado a uno.
- **Registro:** Se pueden crear clientes con datos básicos (Nombre, Teléfono).
- **Estado de Cuenta:** Cada cliente tiene un balance calculado en tiempo real.
    - **Deuda:** Suma de todos los encargos en cualquier estado distinto a **PENDIENTE** (Comprado, Entregado o Finalizado) menos los pagos realizados.
    - **Saldo a favor:** Si los pagos realizados superan el valor de los productos ya procesados (adquiridos al proveedor o entregados).
- **Visualización:** En la lista de clientes, se usan indicadores visuales (Pills) para saber quién está "Al día", quién tiene "Deuda" o "Crédito".

## 📦 2. Flujo de Encargos (Pedidos)
Es el proceso principal para productos que no están en stock inmediato o requieren gestión.
1. **Creación:** Se selecciona un cliente y se agregan productos del catálogo.
2. **Estados del Encargo:**
    - **PENDIENTE:** El pedido ha sido tomado pero no se ha comprado al proveedor. No afecta la deuda del cliente.
    - **COMPRADO:** El producto ya fue adquirido al proveedor y está en camino o en bodega. **En este punto se fija el precio final y el valor del encargo se suma formalmente a la "Deuda" del cliente.**
    - **ENTREGADO:** El cliente ya tiene el producto en sus manos. Este estado activa el descuento de inventario (si aplica), pero no altera la deuda, ya que esta se contabiliza desde que el encargo dejó de estar pendiente.
    - **FINALIZADO:** El encargo está entregado y pagado en su totalidad.

## ⚡ 3. Ventas Directas
Diseñadas para productos en stock (entrega inmediata).
- Saltan los estados intermedios y nacen directamente en estado **ENTREGADO**.
- Al ser una entrega inmediata (estado != PENDIENTE), **generan deuda inmediata** al cliente en el momento de la creación (a menos que se registre un pago simultáneo).
- Afectan el inventario de forma instantánea.

## 💳 4. Gestión de Pagos (Cuentas por Cobrar)
El sistema permite abonos parciales o pagos totales.
- **Registro:** Se selecciona el cliente y el monto entregado.
- **Impacto:** Los pagos reducen automáticamente la deuda global del cliente (calculada sobre encargos no pendientes).
- **Historial:** Cada cliente tiene su cronología de pagos para resolver disputas o dudas.

## 📊 5. Dashboard y Reportes
La pantalla principal ofrece una visión "Warm" (Cálida y rápida) del negocio:
- **Resumen Rápido:**
    - **Encargos:** Cuántos pedidos están en estado "Pendiente" (aún no suman deuda).
    - **Clientes:** Cuántos clientes tienen saldo deudor (basado en encargos Comprados/Entregados).
    - **Entregas:** Cuántos productos están en estado "Comprado" listos para ser entregados.
    - **Ganancia:** Cálculo real (Precio Venta - Costo) de lo vendido en el mes actual.
- **Accesos Rápidos:** Botones directos para las acciones más comunes (Nuevo encargo, Venta directa, Registrar pago).

## 🛠️ Tecnologías Clave
- **Riverpod:** Gestiona el estado y asegura que si registras un pago, el saldo del cliente se actualice en todas las pantallas instantáneamente.
- **Google Fonts (Outfit):** Proporciona la estética moderna y limpia de la app.
- **Warm UI:** Un set de componentes personalizados (`WarmSurfaceCard`, `WarmStatCard`) que mantienen la coherencia visual.

---
*Documentación generada para el equipo de desarrollo de AppDecoHogar.*
