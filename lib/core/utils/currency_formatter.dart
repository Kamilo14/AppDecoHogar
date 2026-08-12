String formatCurrencyClp(int? value, {bool compact = false}) {
  if (value == null) return '---';
  
  if (compact) {
    final absVal = value.abs();
    if (absVal >= 1000000) {
      return '${value < 0 ? '-' : ''}\$${(absVal / 1000000).toStringAsFixed(1)}M';
    } else if (absVal >= 1000) {
      return '${value < 0 ? '-' : ''}\$${(absVal / 1000).toStringAsFixed(0)}K';
    }
  }

  final absoluteValue = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < absoluteValue.length; i++) {
    final indexFromEnd = absoluteValue.length - i;
    buffer.write(absoluteValue[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }

  final formatted = buffer.toString().replaceAll(RegExp(r'\.$'), '');
  return value < 0 ? '-\$$formatted' : '\$$formatted';
}
