class PeriodoReporte {
  final String modo;
  final DateTime fecha;

  const PeriodoReporte(this.modo, this.fecha);

  DateTime get inicio {
    if (modo == 'Día') {
      return DateTime(fecha.year, fecha.month, fecha.day);
    } else if (modo == 'Semana') {
      final weekday = fecha.weekday; // 1 = Lunes, 7 = Domingo
      final lunes = fecha.subtract(Duration(days: weekday - 1));
      return DateTime(lunes.year, lunes.month, lunes.day);
    } else if (modo == 'Mes') {
      return DateTime(fecha.year, fecha.month, 1);
    }
    return DateTime(2000);
  }

  DateTime get fin {
    if (modo == 'Día') {
      return DateTime(fecha.year, fecha.month, fecha.day + 1);
    } else if (modo == 'Semana') {
      return inicio.add(const Duration(days: 7));
    } else if (modo == 'Mes') {
      return DateTime(fecha.year, fecha.month + 1, 1);
    }
    return DateTime(2100);
  }

  bool contiene(DateTime valor) {
    if (modo == 'Todos') return true;
    return !valor.isBefore(inicio) && valor.isBefore(fin);
  }

  String get etiqueta {
    if (modo == 'Día') {
      final d = fecha.day.toString().padLeft(2, '0');
      final m = fecha.month.toString().padLeft(2, '0');
      return '$d-$m';
    } else if (modo == 'Semana') {
      final ini = inicio;
      final f = fin.subtract(const Duration(days: 1));
      final d1 = ini.day.toString().padLeft(2, '0');
      final m1 = ini.month.toString().padLeft(2, '0');
      final d2 = f.day.toString().padLeft(2, '0');
      final m2 = f.month.toString().padLeft(2, '0');
      return '$d1/$m1 - $d2/$m2';
    } else if (modo == 'Mes') {
      const meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${meses[fecha.month - 1]} ${fecha.year}';
    }
    return 'Todos';
  }
}
