import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card_brazilian/flutter_credit_card.dart';
import 'package:flutter_credit_card_brazilian/credit_card_widget.dart';
import 'credit_card_model.dart';
import 'flutter_credit_card.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    Key key,
    this.cardNumber,
    this.cardName,
    this.expiryDate,
    this.cardHolderName,
    this.cvvCode,
    this.height,
    this.width,
    @required this.onCreditCardModelChange,
    this.themeColor,
    this.textStyle,
    this.cursorColor,
    this.constraints,
    this.localizedText = const LocalizedText(),
    this.validCardNames,
    this.invalidCardNameWidget,
  })  : assert(localizedText != null),
        super(key: key);

  final String cardNumber;
  final String cardName;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final double height;
  final double width;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final Color themeColor;
  final TextStyle textStyle;
  final Color cursorColor;
  final BoxConstraints constraints;
  final LocalizedText localizedText;
  final List<String> validCardNames;
  final Widget invalidCardNameWidget;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  String cardNumber;
  String cardName;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused = false;
  Color themeColor;
  TextStyle textStyle;

  void Function(CreditCardModel) onCreditCardModelChange;
  CreditCardModel creditCardModel;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber ?? '';
    cardName = widget.cardName ?? '';
    expiryDate = widget.expiryDate ?? '';
    cardHolderName = widget.cardHolderName ?? '';
    cvvCode = widget.cvvCode ?? '';

    creditCardModel = CreditCardModel(cardNumber, cardName, expiryDate,
        cardHolderName, cvvCode, isCvvFocused);
  }

  @override
  void initState() {
    super.initState();

    createCreditCardModel();

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);

    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel.cardName = cardName;
        creditCardModel.cardNumber = cardNumber;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
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
    final double firstHeight = widget.height == null && widget.constraints != null && widget.constraints.biggest != null ? widget.constraints.biggest.height : widget.height;
    final double firstWidth = widget.width == null && widget.constraints != null && widget.constraints.biggest != null ? widget.constraints.biggest.width : widget.width;

    return Theme(
      data: ThemeData(
        primaryColor: themeColor.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Container(
        height: firstHeight,
        width: firstWidth,
        child: Form(
          child: Column(
            children: <Widget>[
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext contextLayout, BoxConstraints constraints) {
                    final double height = constraints.biggest.height;
                    final double width = constraints.biggest.width;
                    textStyle = TextStyle(
                      color: Colors.black,
                      fontSize: height / heightFactor * 14,
                    );
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: height / heightFactor * (widget.invalidCardNameWidget != null ? 2 : 8)),
                      margin: EdgeInsets.symmetric(horizontal: width / widthFactor * 16, vertical: height / heightFactor * 4),
                      alignment: Alignment.centerLeft,
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        controller: _cardNumberController,
                        cursorColor: widget.cursorColor ?? themeColor,
                        style: textStyle,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: width / widthFactor * 8),
                          border: const OutlineInputBorder(),
                          labelText: widget.localizedText.cardNumberLabel,
                          hintText: widget.localizedText.cardNumberHint,
                          errorStyle: const TextStyle(fontSize: 0, height: 0),
                          alignLabelWithHint: true,
                          isDense: true,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.always,
                        validator: (String value) {
                          return widget.invalidCardNameWidget != null ? '' : null;
                        },
                      ),
                    );
                  }
                ),
              ),
              widget.invalidCardNameWidget != null ? Container(
                height: widget.height != null ? firstHeight / 7 : null,
                width: widget.width != null ? firstWidth : null,
                margin: EdgeInsets.symmetric(horizontal: firstWidth / widthFactor * 16, vertical: firstHeight / heightFactor),
                child: widget.invalidCardNameWidget
              ) : Container(),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext contextLayout, BoxConstraints constraints) {
                    final double height = constraints.biggest.height;
                    final double width = constraints.biggest.width;
                    textStyle = TextStyle(
                      color: Colors.black,
                      fontSize: height / heightFactor * 14,
                    );
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: height / heightFactor * (widget.invalidCardNameWidget != null ? 2 : 8)),
                            margin: EdgeInsets.only(right: height / heightFactor * (widget.invalidCardNameWidget != null ? 2 : 8) + height / heightFactor * 4, left: width / widthFactor * 16, bottom: height / heightFactor * 4, top: height / heightFactor * 4),
                            child: TextFormField(
                              expands: true,
                              maxLines: null,
                              minLines: null,
                              controller: _expiryDateController,
                              cursorColor: widget.cursorColor ?? themeColor,
                              style: textStyle,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: width / widthFactor * 8),
                                border: const OutlineInputBorder(),
                                labelText: widget.localizedText.expiryDateLabel,
                                hintText: widget.localizedText.expiryDateHint,
                                alignLabelWithHint: true,
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: height / heightFactor * (widget.invalidCardNameWidget != null ? 2 : 8)),
                            margin: EdgeInsets.only(right: width / widthFactor * 16, left: height / heightFactor * (widget.invalidCardNameWidget != null ? 2 : 8) + height / heightFactor * 4, bottom: height / heightFactor * 4, top: height / heightFactor * 4),
                            child: TextField(
                              expands: true,
                              maxLines: null,
                              minLines: null,
                              focusNode: cvvFocusNode,
                              controller: _cvvCodeController,
                              cursorColor: widget.cursorColor ?? themeColor,
                              style: textStyle,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: width / widthFactor * 8),
                                border: const OutlineInputBorder(),
                                labelText: widget.localizedText.cvvLabel,
                                hintText: widget.localizedText.cvvHint,
                                alignLabelWithHint: true,
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onChanged: (String text) {
                                setState(() {
                                  cvvCode = text;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext contextLayout, BoxConstraints constraints) {
                    final double height = constraints.biggest.height;
                    final double width = constraints.biggest.width;
                    textStyle = TextStyle(
                      color: Colors.black,
                      fontSize: height / heightFactor * 14,
                    );
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: height / heightFactor * (widget.invalidCardNameWidget != null ? 2 : 8)),
                      margin: EdgeInsets.symmetric(horizontal: width / widthFactor * 16, vertical: height / heightFactor * 4),
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        controller: _cardHolderNameController,
                        cursorColor: widget.cursorColor ?? themeColor,
                        style: textStyle,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: width / widthFactor * 8),
                          border: const OutlineInputBorder(),
                          labelText: widget.localizedText.cardHolderLabel,
                          hintText: widget.localizedText.cardHolderHint,
                          alignLabelWithHint: true,
                          isDense: true,
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
