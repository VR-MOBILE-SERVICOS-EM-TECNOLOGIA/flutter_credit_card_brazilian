class CreditCardModel {
  CreditCardModel(this.cardNumber, this.cardName, this.expiryDate,
      this.cardHolderName, this.cpfCnpj, this.cvvCode, this.isCvvFocused, this.isCardNumberInvalid, this.isCpfCnpjInvalid);

  String? cardNumber = '';
  String? expiryDate = '';
  String? cardHolderName = '';
  String? cpfCnpj = '';
  String? cardName = '';
  String? cvvCode = '';
  bool isCvvFocused = false;
  bool isCardNumberInvalid = false;
  bool isExpiryDateInvalid = false;
  bool isDateExpired = false;
  bool isCpfCnpjInvalid = false;
}
