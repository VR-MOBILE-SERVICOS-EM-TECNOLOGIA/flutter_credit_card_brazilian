import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card_brazilian/flutter_credit_card.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'flutter_credit_card.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

bool validaCpfCnpj(String val) {
  if (val.length == 14) {
    String cpf = val.trim();
  
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    final List<String> cpfSplitted = cpf.split('');
    
    int v1 = 0;
    int v2 = 0;
    bool aux = false;
    
    for (int i = 1; cpfSplitted.length > i; i++) {
      if (cpfSplitted[i - 1] != cpf[i]) {
        aux = true;   
      }
    } 
    
    if (aux == false) {
      return false; 
    } 
    
    for (int i = 0, p = 10; (cpfSplitted.length - 2) > i; i++, p--) {
      v1 += int.parse(cpfSplitted[i]) * p; 
    } 
    
    v1 = v1 * 10 % 11;
    
    if (v1 == 10) {
      v1 = 0; 
    }
    
    if (v1 != int.parse(cpfSplitted[9])) {
      return false; 
    } 
    
    for (int i = 0, p = 11; (cpfSplitted.length - 1) > i; i++, p--) {
      v2 += int.parse(cpfSplitted[i]) * p; 
    } 
    
    v2 = v2 * 10 % 11;
    
    if (v2 == 10) {
      v2 = 0; 
    }
    
    if (v2 != int.parse(cpfSplitted[10])) {
      return false; 
    } else {   
      return true; 
    }
  } else if (val.length == 18) {
    String cnpj = val.trim();
    
    cnpj = cnpj.replaceAll(RegExp(r'\D'), ''); 
    final List<String> cnpjSplitted = cnpj.split(''); 
    
    int v1 = 0;
    int v2 = 0;
    bool aux = false;
    
    for (int i = 1; cnpjSplitted.length > i; i++) { 
      if (cnpjSplitted[i - 1] != cnpjSplitted[i]) {  
        aux = true;   
      } 
    } 
    
    if (aux == false) {  
      return false; 
    }
    
    for (int i = 0, p1 = 5, p2 = 13; (cnpjSplitted.length - 2) > i; i++, p1--, p2--) {
      if (p1 >= 2) {  
        v1 += int.parse(cnpjSplitted[i]) * p1;  
      } else {  
        v1 += int.parse(cnpjSplitted[i]) * p2;  
      } 
    } 
    
    v1 = v1 % 11;
    
    if (v1 < 2) { 
      v1 = 0; 
    } else { 
      v1 = 11 - v1; 
    } 
    
    if (v1 != int.parse(cnpjSplitted[12])) {  
      return false; 
    } 
    
    for (int i = 0, p1 = 6, p2 = 14; (cnpjSplitted.length - 1) > i; i++, p1--, p2--) { 
      if (p1 >= 2) {  
        v2 += int.parse(cnpjSplitted[i]) * p1;  
      } else {   
        v2 += int.parse(cnpjSplitted[i]) * p2; 
      } 
    }
    
    v2 = v2 % 11; 
    
    if (v2 < 2) {  
      v2 = 0;
    } else { 
      v2 = 11 - v2; 
    } 
    
    if (v2 != int.parse(cnpjSplitted[13])) {   
      return false; 
    } else {  
      return true; 
    }
  } else {
    return false;
  }
 }

/// TextInputFormatter that fixes the regression.
/// https://github.com/flutter/flutter/issues/67236
///
/// Remove it once the issue above is fixed.
class LengthLimitingTextFieldFormatterFixed
    extends LengthLimitingTextInputFormatter {
  LengthLimitingTextFieldFormatterFixed(int maxLength) : super(maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null &&
        maxLength! > 0 &&
        newValue.text.characters.length > maxLength!) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (oldValue.text.characters.length == maxLength) {
        return oldValue;
      }
      // ignore: invalid_use_of_visible_for_testing_member
      return LengthLimitingTextInputFormatter.truncate(newValue, maxLength!);
    }
    return newValue;
  }
}

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    Key? key,
    this.cardNumber,
    this.cardName,
    this.expiryDate,
    this.cardHolderName,
    this.cpfCnpj,
    this.cvvCode,
    this.height,
    this.width,
    required this.onCreditCardModelChange,
    this.themeColor,
    this.textStyle,
    this.cursorColor,
    this.constraints,
    this.localizedText = const LocalizedText(),
    this.validCardNames,
    this.invalidCardNameWidget,
    this.invalidCardNumberWidget,
    this.invalidExpiryDateWidget,
    this.expiredDateWidget,
    this.invalidCpfWidget,
    this.invalidCnpjWidget,
    this.creditCardFormScrollController,
    this.fontSizeFactor = 17,
    this.textFieldsContentPadding,
  })  : super(key: key);

  final String? cardNumber;
  final String? cardName;
  final String? expiryDate;
  final String? cardHolderName;
  final String? cpfCnpj;
  final String? cvvCode;
  final double? height;
  final double? width;
  final void Function(CreditCardModel?) onCreditCardModelChange;
  final Color? themeColor;
  final TextStyle? textStyle;
  final Color? cursorColor;
  final BoxConstraints? constraints;
  final LocalizedText localizedText;
  final List<String>? validCardNames;
  final Widget? invalidCardNameWidget;
  final Widget? invalidCardNumberWidget;
  final Widget? invalidExpiryDateWidget;
  final Widget? expiredDateWidget;
  final Widget? invalidCpfWidget;
  final Widget? invalidCnpjWidget;
  final ScrollController? creditCardFormScrollController;
  final int fontSizeFactor;
  final EdgeInsetsGeometry? textFieldsContentPadding;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  String? cardNumber;
  String? cardName;
  String? expiryDate;
  String? cardHolderName;
  String? cpfCnpj;
  String? cvvCode;
  bool isCvvFocused = false;
  Color? themeColor;
  TextStyle? textStyle;
  bool isCardNumberInvalid = false;
  bool isExpiryDateInvalid = false;
  bool isDateExpired = false;
  late LocalizedText localizedText;
  late Map<String, dynamic> cardInfos;
  DateTime? expiryDateTime;

  late void Function(CreditCardModel?) onCreditCardModelChange;
  CreditCardModel? creditCardModel;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final MaskedTextController _cpfCnpjController =
      MaskedTextController(mask: '000.000.000-00', maxLength: 18);
  final MaskedTextController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final MaskedTextController _cvvCodeController =
      MaskedTextController(mask: '000');

  FocusNode cvvFocusNode = FocusNode();

  bool checkLuhn(String value) {
    final int qtdDigits = CreditCardWidgetState.detectCCType(cardNumber!)['mask'].replaceAll(' ', '').length;
    // remove all non digit characters
    value = value.replaceAll(RegExp(r'\D'), '');
    
    if (value.length < qtdDigits)
      return true;

    int sum = 0;
    bool shouldDouble = false;
    // loop through values starting at the rightmost side
    for (int i = value.length - 1; i >= 0; i--) {
      int digit = int.tryParse(value[i])!;
      
      if (shouldDouble) {
        if ((digit *= 2) > 9)
          digit -= 9;
      }

      sum += digit;
      shouldDouble = !shouldDouble;
    }
    return (sum % 10) == 0;
  }

  void textFieldFocusDidChange() {
    creditCardModel!.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber ?? '';
    cardName = widget.cardName ?? '';
    expiryDate = widget.expiryDate ?? '';
    cardHolderName = widget.cardHolderName ?? '';
    cpfCnpj = widget.cpfCnpj ?? '';
    cvvCode = widget.cvvCode ?? '';

    creditCardModel = CreditCardModel(cardNumber, cardName, expiryDate,
        cardHolderName, cpfCnpj, cvvCode, isCvvFocused, !checkLuhn(cardNumber!), !validaCpfCnpj(cpfCnpj!));

    _cardNumberController.text = cardNumber;
    _expiryDateController.text = expiryDate;
    _cardHolderNameController.text = cardHolderName!;
    _cvvCodeController.text = cvvCode;
    _cpfCnpjController.text = cpfCnpj;
  }

  void updateCardNumberMasks() {
    cardInfos = CreditCardWidgetState.detectCCType(cardNumber!);
    _cardNumberController.updateMask(cardInfos['mask']);

    if (cardInfos['type'] == CardType.americanExpress) {
      _cvvCodeController.updateMask('0000');
      localizedText = LocalizedText(
        cardHolderHint: localizedText.cardHolderHint,
        cardHolderLabel: localizedText.cardHolderLabel,
        cardNumberHint: cardInfos['hint'],
        cardNumberLabel: localizedText.cardNumberLabel,
        cvvHint: '****',
        cvvLabel: localizedText.cvvLabel,
        expiryDateHint: localizedText.expiryDateHint,
        expiryDateLabel: localizedText.expiryDateLabel,
      );
    }
    else {
      _cvvCodeController.updateMask('000');
      localizedText = LocalizedText(
        cardHolderHint: localizedText.cardHolderHint,
        cardHolderLabel: localizedText.cardHolderLabel,
        cardNumberHint: cardInfos['hint'],
        cardNumberLabel: localizedText.cardNumberLabel,
        cvvHint: '***',
        cvvLabel: localizedText.cvvLabel,
        expiryDateHint: localizedText.expiryDateHint,
        expiryDateLabel: localizedText.expiryDateLabel,
      );
    }
  }

  void updateCpfCnpjMasks() {
    if (_cpfCnpjController.text.replaceAll(RegExp(r'\D'), '').length <= 11)
      _cpfCnpjController.updateMask('000.000.000-00');
    else
      _cpfCnpjController.updateMask('00.000.000/0000-00');
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR');

    createCreditCardModel();
    localizedText = widget.localizedText;

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);
    updateCardNumberMasks();
    updateCpfCnpjMasks();

    _cardNumberController.addListener(() {
      updateCardNumberMasks();
        
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel!.cardName = cardName;
        creditCardModel!.cardNumber = cardNumber;
        creditCardModel!.isCardNumberInvalid = !checkLuhn(cardNumber!);
        onCreditCardModelChange(creditCardModel);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel!.expiryDate = expiryDate;

        try {
          expiryDateTime = DateFormat('MM/y', 'pt_BR').parseStrict(expiryDate!);
        } catch (e) {
          expiryDateTime = null;
        }
        creditCardModel!.isExpiryDateInvalid = expiryDate!.isNotEmpty && expiryDate!.length == 5 && expiryDateTime == null;
        creditCardModel!.isDateExpired = expiryDate!.isNotEmpty && !creditCardModel!.isExpiryDateInvalid && expiryDate!.length == 5 && expiryDateTime!.year < int.parse(DateFormat('MM/y', 'pt_BR').format(DateTime.now()).substring(5));

        onCreditCardModelChange(creditCardModel);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel!.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel!.cvvCode = cvvCode;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cpfCnpjController.addListener(() {
      updateCpfCnpjMasks();

      setState(() {
        cpfCnpj = _cpfCnpjController.text;
        creditCardModel!.cpfCnpj = cpfCnpj;
        creditCardModel!.isCpfCnpjInvalid = !validaCpfCnpj(cpfCnpj!);
        onCreditCardModelChange(creditCardModel);
      });
    });
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor ?? Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    const double heightFactor = 71;
    const double widthFactor = 360;
    final double firstHeight = widget.height == null && widget.constraints != null ? widget.constraints!.biggest.height : widget.height!;
    final double firstWidth = widget.width == null && widget.constraints != null ? widget.constraints!.biggest.width : widget.width!;
    final double height = firstHeight / 5;
    textStyle = TextStyle(
      color: Colors.black,
      fontSize: height / heightFactor * widget.fontSizeFactor,
    );

    return Theme(
      data: ThemeData(
        primaryColor: themeColor!.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Container(
        height: firstHeight,
        width: firstWidth,
        child: Form(
          child: SingleChildScrollView(
            controller: widget.creditCardFormScrollController,
            child: Column(
              children: <Widget>[
                Container(
                  height: height,
                  padding: EdgeInsets.symmetric(vertical: height / heightFactor * 2),
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: height / heightFactor * 2),
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    maxLines: 1,
                    onChanged: checkLuhn,
                    controller: _cardNumberController,
                    cursorColor: widget.cursorColor ?? themeColor,
                    style: textStyle,
                    decoration: InputDecoration(
                      contentPadding: widget.textFieldsContentPadding,
                      border: const OutlineInputBorder(),
                      labelText: localizedText.cardNumberLabel,
                      hintText: localizedText.cardNumberHint,
                      alignLabelWithHint: true,
                      labelStyle: widget.invalidCardNameWidget != null || !checkLuhn(cardNumber!) ? TextStyle(color: Colors.red[800]!) : null,
                      enabledBorder: widget.invalidCardNameWidget != null || !checkLuhn(cardNumber!) ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red[800]!
                        ),
                      ) : null,
                      focusedBorder: widget.invalidCardNameWidget != null || !checkLuhn(cardNumber!) ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red[800]!
                        ),
                      ) : null,
                      isDense: true,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                !checkLuhn(cardNumber!) && widget.invalidCardNumberWidget != null ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstHeight / heightFactor),
                  child: widget.invalidCardNumberWidget,
                ) : Container(),
                widget.invalidCardNameWidget != null ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstHeight / heightFactor),
                  child: widget.invalidCardNameWidget,
                ) : Container(),
                Container(
                  height: height,
                  padding: EdgeInsets.symmetric(vertical: height / heightFactor * 2),
                  margin: EdgeInsets.symmetric(vertical: height / heightFactor * 2),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: height / heightFactor * 4, left: firstWidth / widthFactor * 16),
                          child: TextFormField(
                            maxLines: 1,
                            controller: _expiryDateController,
                            cursorColor: widget.cursorColor ?? themeColor,
                            style: textStyle,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: widget.textFieldsContentPadding,
                              border: const OutlineInputBorder(),
                              labelText: localizedText.expiryDateLabel,
                              hintText: localizedText.expiryDateHint,
                              alignLabelWithHint: true,
                              labelStyle: creditCardModel!.isExpiryDateInvalid || creditCardModel!.isDateExpired ? TextStyle(color: Colors.red[800]!) : null,
                              enabledBorder: creditCardModel!.isExpiryDateInvalid || creditCardModel!.isDateExpired ? OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red[800]!
                                ),
                              ) : null,
                              focusedBorder: creditCardModel!.isExpiryDateInvalid || creditCardModel!.isDateExpired ? OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red[800]!
                                ),
                              ) : null,
                              focusColor: creditCardModel!.isExpiryDateInvalid || creditCardModel!.isDateExpired ? Colors.red : null,
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: firstWidth / widthFactor * 16, left: height / heightFactor * 4),
                          child: TextField(
                            maxLines: 1,
                            focusNode: cvvFocusNode,
                            controller: _cvvCodeController,
                            cursorColor: widget.cursorColor ?? themeColor,
                            style: textStyle,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: widget.textFieldsContentPadding,
                              border: const OutlineInputBorder(),
                              labelText: localizedText.cvvLabel,
                              hintText: localizedText.cvvHint,
                              alignLabelWithHint: true,
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (String text) {
                              setState(() {
                                cvvCode = text;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                creditCardModel!.isExpiryDateInvalid ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstHeight / heightFactor),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: height / heightFactor * 4),
                          child: widget.invalidExpiryDateWidget
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: height / heightFactor * 4),
                          child: Container(),
                        ),
                      ),
                    ],
                  ),
                ) : creditCardModel!.isDateExpired ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstHeight / heightFactor),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: height / heightFactor * 4),
                          child: widget.expiredDateWidget,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: height / heightFactor * 4),
                          child: Container(),
                        ),
                      ),
                    ],
                  ),
                ) : Container(),
                Container(
                  height: height,
                  padding: EdgeInsets.symmetric(vertical: height / heightFactor * 2),
                  margin: EdgeInsets.symmetric(vertical: height / heightFactor * 2, horizontal: firstWidth / widthFactor * 16),
                  child: TextFormField(
                    maxLines: 1,
                    controller: _cardHolderNameController,
                    cursorColor: widget.cursorColor ?? themeColor,
                    style: textStyle,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding: widget.textFieldsContentPadding,
                      border: const OutlineInputBorder(),
                      labelText: localizedText.cardHolderLabel,
                      hintText: localizedText.cardHolderHint,
                      alignLabelWithHint: true,
                      isDense: true,
                    ),
                    inputFormatters: <TextInputFormatter>[LengthLimitingTextFieldFormatterFixed(20), UpperCaseTextFormatter()],
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Container(
                  height: height,
                  padding: EdgeInsets.symmetric(vertical: height / heightFactor * 2),
                  margin: EdgeInsets.symmetric(vertical: height / heightFactor * 2, horizontal: firstWidth / widthFactor * 16),
                  child: TextFormField(
                    maxLines: 1,
                    controller: _cpfCnpjController,
                    cursorColor: widget.cursorColor ?? themeColor,
                    style: textStyle,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding: widget.textFieldsContentPadding,
                      border: const OutlineInputBorder(),
                      labelText: localizedText.cpfCnpjLabelDefault,
                      hintText: localizedText.cardHolderHint,
                      alignLabelWithHint: true,
                      labelStyle: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length == 14) ? TextStyle(color: Colors.red[800]!) : null,
                      enabledBorder: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length == 14) ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red[800]!
                        ),
                      ) : null,
                      focusedBorder: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length == 14) ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red[800]!
                        ),
                      ) : null,
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                creditCardModel!.isCpfCnpjInvalid && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length == 14) ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstHeight / heightFactor),
                  child: creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'\D'), '').length <= 11 ? 
                    widget.invalidCpfWidget : widget.invalidCnpjWidget,
                ) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
