class PeriodoReporte {
  final String modo;
  final DateTime fecha;
  const PeriodoReporte(this.modo, this.fecha);
  bool contiene(DateTime valor) {
    if (modo == 'Todos') return true;
    final inicio = modo == 'Mes'
        ? DateTime(fecha.year, fecha.month)
        : DateTime(fecha.year, fecha.month, fecha.day);
    final fin = modo == 'Mes'
        ? DateTime(fecha.year, fecha.month + 1)
        : DateTime(fecha.year, fecha.month, fecha.day + 1);
    return !valor.isBefore(inicio) && valor.isBefore(fin);
  }
}
