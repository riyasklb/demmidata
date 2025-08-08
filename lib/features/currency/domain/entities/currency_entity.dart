class CurrencyEntity {
  final String code;
  final String name;

  const CurrencyEntity({
    required this.code,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyEntity &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name;

  @override
  int get hashCode => code.hashCode ^ name.hashCode;
}
