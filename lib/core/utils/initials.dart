String initialsFromName(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final w = parts.single;
    return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
  }
  return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
}
