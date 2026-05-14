import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card_brazilian/flutter_credit_card.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

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
  
    cpf = cpf.replaceAll(RegExp(r'[^A-z|0-9]'), '');
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
      v1 += (int.tryParse(cpfSplitted[i]) ?? 0) * p; 
    } 
    
    v1 = v1 * 10 % 11;
    
    if (v1 == 10) {
      v1 = 0; 
    }
    
    if (cpfSplitted.length <= 9 || v1 != int.tryParse(cpfSplitted[9])) {
      return false; 
    } 
    
    for (int i = 0, p = 11; (cpfSplitted.length - 1) > i; i++, p--) {
      v2 += (int.tryParse(cpfSplitted[i]) ?? 0) * p; 
    } 
    
    v2 = v2 * 10 % 11;
    
    if (v2 == 10) {
      v2 = 0; 
    }
    
    if (cpfSplitted.length <= 10 || v2 != int.tryParse(cpfSplitted[10])) {
      return false; 
    } else {   
      return true; 
    }
  } else if (val.length == 18) {
    // Remove caracteres não alfanuméricos (pontos, barras, traços)
    final String cnpj = val.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // O CNPJ deve ter exatamente 14 caracteres (12 base + 2 DVs)
    if (cnpj.length != 14) {
      return false;
    }

    // Separa os 12 primeiros caracteres e os 2 DVs informados
    final String base = cnpj.substring(0, 12);
    final int dv1Informado = int.tryParse(cnpj[12]) ?? -1;
    final int dv2Informado = int.tryParse(cnpj[13]) ?? -1;

    // --- Cálculo do Primeiro Dígito Verificador ---
    int somatorio1 = 0;
    // Pesos para 12 caracteres: 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 
    final List<int> pesos1 = <int>[5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    for (int i = 0; i < 12; i++) {
      final int valor = base.codeUnitAt(i) - 48; // Atribuição: Valor ASCII - 48 
      somatorio1 += valor * pesos1[i]; // Multiplicação de valor e peso [cite: 28]
    }

    final int resto1 = somatorio1 % 11; // Resto da divisão por 11 [cite: 31]
    final int dv1Calculado = (resto1 == 0 || resto1 == 1) ? 0 : 11 - resto1; // Lógica do DV [cite: 32, 33]

    if (dv1Calculado != dv1Informado) {
      return false;
    }

    // --- Cálculo do Segundo Dígito Verificador ---
    // Para o 2º DV, acrescenta-se o primeiro DV calculado ao final [cite: 38]
    final String base2 = base + dv1Calculado.toString();
    int somatorio2 = 0;
    // Pesos para 13 caracteres: 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 
    final List<int> pesos2 = <int>[6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    for (int i = 0; i < 13; i++) {
      final int valor = base2.codeUnitAt(i) - 48;
      somatorio2 += valor * pesos2[i];
    }

    final int resto2 = somatorio2 % 11;
    final int dv2Calculado = (resto2 == 0 || resto2 == 1) ? 0 : 11 - resto2;

    return dv2Calculado == dv2Informado;
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
  LengthLimitingTextFieldFormatterFixed(int super.maxLength);

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
    super.key,
    this.cardNumber,
    this.cardName,
    required this.cardNameWithRadioVoucherOptions,
    this.expiryDate,
    this.cardHolderName,
    this.cpfCnpj,
    this.cvvCode,
    this.voucherTypeSelected,
    this.height,
    this.width,
    this.radioScale = 0.6,
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
  });

  final String? cardNumber;
  final String? cardName;
  final bool cardNameWithRadioVoucherOptions;
  final String? expiryDate;
  final String? cardHolderName;
  final String? cpfCnpj;
  final String? cvvCode;
  final int? voucherTypeSelected;
  final double? height;
  final double? width;
  final double radioScale;
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
  CreditCardFormState createState() => CreditCardFormState();
}

class CreditCardFormState extends State<CreditCardForm> {
  String? cardNumber;
  String? cardName;
  String? expiryDate;
  String? cardHolderName;
  String? cpfCnpj;
  String? cvvCode;
  bool isCvvFocused = false;
  int? voucherTypeSelected;
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
      MaskedTextController(mask: '@@@.@@@.@@@-@@', maxLength: 18);
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
    
    if (value.length < qtdDigits) {
      return true;
    }

    int sum = 0;
    bool shouldDouble = false;
    // loop through values starting at the rightmost side
    for (int i = value.length - 1; i >= 0; i--) {
      int digit = int.tryParse(value[i])!;
      
      if (shouldDouble) {
        if ((digit *= 2) > 9) {
          digit -= 9;
        }
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
    voucherTypeSelected = widget.voucherTypeSelected;
    expiryDate = widget.expiryDate ?? '';
    cardHolderName = widget.cardHolderName ?? '';
    cpfCnpj = widget.cpfCnpj ?? '';
    cvvCode = widget.cvvCode ?? '';

    creditCardModel = CreditCardModel(
      cardNumber,
      cardName,
      expiryDate,
      cardHolderName,
      cpfCnpj,
      cvvCode,
      voucherTypeSelected,
      isCvvFocused,
      !checkLuhn(cardNumber!),
      !validaCpfCnpj(cpfCnpj!)
    );

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
    if (_cpfCnpjController.text.replaceAll(RegExp(r'[^A-z|0-9]'), '').length <= 11) {
      _cpfCnpjController.updateMask('@@@.@@@.@@@-@@');
    }
    else {
      _cpfCnpjController.updateMask('@@.@@@.@@@/@@@@-00');
    }
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
        creditCardModel!.voucherType = voucherTypeSelected;
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
    final double height = firstHeight / 7;
    textStyle = TextStyle(
      color: Colors.black,
      fontSize: height / heightFactor * widget.fontSizeFactor,
    );

    return Theme(
      data: ThemeData(
        primaryColor: themeColor!.withValues(alpha: 0.8),
        primaryColorDark: themeColor,
      ),
      child: SizedBox(
        height: firstHeight,
        width: firstWidth,
        child: Form(
          child: widget.creditCardFormScrollController == null ? Column(
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
                  alignment: Alignment.centerLeft,
                  child: widget.invalidCardNameWidget,
                ) : Container(),
                widget.invalidCardNameWidget == null && widget.cardNameWithRadioVoucherOptions ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstWidth / widthFactor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Modalidade',
                        style: textStyle,
                      ),
                      RadioGroup<int?>(
                        groupValue: voucherTypeSelected,
                        onChanged: (int? value) {
                          setState(() {
                            voucherTypeSelected = value;
                          
                            if (creditCardModel != null) {
                              creditCardModel!.voucherType = voucherTypeSelected;
                              onCreditCardModelChange(creditCardModel);
                            }
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Transform.scale(
                              scale: 0.7,
                              child: const Radio<int?>(
                                value: 0,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Text(
                              'Alimentação',
                              style: textStyle,
                            ),
                            Transform.scale(
                              scale: 0.7,
                              child: const Radio<int?>(
                                value: 1,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Text(
                              'Refeição',
                              style: textStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                    inputFormatters: <TextInputFormatter>[
                      TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      contentPadding: widget.textFieldsContentPadding,
                      border: const OutlineInputBorder(),
                      labelText: localizedText.cpfCnpjLabelDefault,
                      hintText: localizedText.cardHolderHint,
                      alignLabelWithHint: true,
                      labelStyle: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 14) ? TextStyle(color: Colors.red[800]!) : null,
                      enabledBorder: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 14) ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red[800]!
                        ),
                      ) : null,
                      focusedBorder: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 14) ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red[800]!
                        ),
                      ) : null,
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                creditCardModel!.isCpfCnpjInvalid && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 14) ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstHeight / heightFactor),
                  child: creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length <= 11 ? 
                    widget.invalidCpfWidget : widget.invalidCnpjWidget,
                ) : Container(),
              ],
            ) : SingleChildScrollView(
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
                  alignment: Alignment.centerLeft,
                  child: widget.invalidCardNameWidget,
                ) : Container(),
                widget.invalidCardNameWidget == null && widget.cardNameWithRadioVoucherOptions ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstWidth / widthFactor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Modalidade',
                        style: textStyle,
                      ),
                      RadioGroup<int?>(
                        groupValue: voucherTypeSelected,
                        onChanged: (int? value) {
                          setState(() {
                            voucherTypeSelected = value;
                          
                            if (creditCardModel != null) {
                              creditCardModel!.voucherType = voucherTypeSelected;
                              onCreditCardModelChange(creditCardModel);
                            }
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Transform.scale(
                              scale: 0.7,
                              child: const Radio<int?>(
                                value: 0,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Text(
                              'Alimentação',
                              style: textStyle,
                            ),
                            Transform.scale(
                              scale: 0.7,
                              child: const Radio<int?>(
                                value: 1,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Text(
                              'Refeição',
                              style: textStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                    inputFormatters: <TextInputFormatter>[
                      TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      contentPadding: widget.textFieldsContentPadding,
                      border: const OutlineInputBorder(),
                      labelText: localizedText.cpfCnpjLabelDefault,
                      hintText: localizedText.cardHolderHint,
                      alignLabelWithHint: true,
                      labelStyle: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 14) ? TextStyle(color: Colors.red[800]!) : null,
                      enabledBorder: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 14) ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red[800]!
                        ),
                      ) : null,
                      focusedBorder: !validaCpfCnpj(_cpfCnpjController.text) && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 14) ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red[800]!
                        ),
                      ) : null,
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                creditCardModel!.isCpfCnpjInvalid && (creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 11 || creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length == 14) ? Container(
                  margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstHeight / heightFactor),
                  child: creditCardModel!.cpfCnpj!.replaceAll(RegExp(r'[^A-z|0-9]'), '').length <= 11 ? 
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
