class LocalizedText {
  const LocalizedText({
    this.cardNumberLabel = _cardNumberLabelDefault,
    this.cardNumberHint = _cardNumberHintDefault,
    this.expiryDateLabel = _expiryDateLabelDefault,
    this.expiryDateHint = _expiryDateHintDefault,
    this.cvvLabel = _cvvLabelDefault,
    this.cvvHint = _cvvHintDefault,
    this.cardHolderLabel = _cardHolderLabelDefault,
    this.cardHolderHint = _cardHolderHintDefault,
    this.cpfCnpjLabelDefault = _cpfCnpjLabelDefault,
    this.cpfHintDefault = _cpfHintDefault,
    this.cnpjHintDefault = _cnpjHintDefault,
  });

  static const String _cardNumberLabelDefault = 'Número do cartão';
  static const String _cardNumberHintDefault = '**** **** **** ****';
  static const String _expiryDateLabelDefault = 'Validade';
  static const String _expiryDateHintDefault = 'MM/YY';
  static const String _cvvLabelDefault = 'CVV';
  static const String _cvvHintDefault = '***';
  static const String _cardHolderLabelDefault = 'Nome do titular';
  static const String _cardHolderHintDefault = '';
  static const String _cpfCnpjLabelDefault = 'CPF/CNPJ';
  static const String _cpfHintDefault = '*';
  static const String _cnpjHintDefault = '*';
  

  final String cardNumberLabel;
  final String cardNumberHint;
  final String expiryDateLabel;
  final String expiryDateHint;
  final String cvvLabel;
  final String cvvHint;
  final String cardHolderLabel;
  final String cardHolderHint;
  final String cpfCnpjLabelDefault;
  final String cpfHintDefault;
  final String cnpjHintDefault;
}
