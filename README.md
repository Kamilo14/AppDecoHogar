# App Deco Hogar 🏠✨

Una aplicación móvil profesional diseñada para la gestión integral de negocios de decoración del hogar. Permite administrar clientes, pedidos (encargos), inventario de productos, catálogos, reportes financieros y logística de viajes de compra.

## 🚀 Características Principales

- **Gestión de Clientes:** Ficha técnica, historial de compras y seguimiento de saldos/deudas.
- **Control de Encargos:** Flujo completo desde el pedido pendiente hasta la entrega final.
- **Inventario y Productos:** Catálogo digital con gestión de stock y categorías.
- **Finanzas y Pagos:** Registro de abonos, pagos totales y visualización de utilidades.
- **Logística de Viajes:** Control de gastos de compra y distribución de costos logísticos en productos.
- **Reportes Avanzados:** Gráficos de rendimiento de ventas, ganancias netas y estado de deudas.

## 🎨 Diseño y UI

La aplicación cuenta con una interfaz **Warm UI**, diseñada para ser limpia, profesional y acogedora:
- **Colores:** Paleta terracota, crema y verde salvia.
- **Tipografía:** Google Fonts (Outfit) para una lectura clara y moderna.
- **UX:** Navegación fluida y componentes visuales consistentes en toda la app.

## 🛠 Tech Stack

- **Framework:** Flutter
- **Estado:** Flutter Riverpod
- **Base de Datos:** Drift (SQLite local) / Firebase (si aplica)
- **Gráficos:** fl_chart
- **Fuentes:** google_fonts

## 📂 Estructura del Proyecto

El proyecto sigue una arquitectura limpia (Clean Architecture) organizada por características (Features):
- `lib/core`: Temas, widgets compartidos, utilidades y configuración global.
- `lib/features`: Módulos específicos (clientes, encargos, productos, pagos, gastos, reportes).
- `lib/presentation`: Pantallas principales y navegación global.

## 📝 Instalación

1. Clona el repositorio.
2. Ejecuta `flutter pub get` para instalar las dependencias.
3. Ejecuta `flutter run` para iniciar la aplicación en tu dispositivo o emulador.

---
Desarrollado con ❤️ para AppDecoHogar.
