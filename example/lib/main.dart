import 'package:flutter/material.dart';
import 'package:flutter_credit_card_brazilian/credit_card_form.dart';
import 'package:flutter_credit_card_brazilian/credit_card_model.dart';
import 'package:flutter_credit_card_brazilian/flutter_credit_card.dart';

void main() => runApp(MySample());

class MySample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MySampleState();
  }
}

class MySampleState extends State<MySample> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Credit Card View Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyApp(),
    );
  }
}

/// Componente principal da aplicação
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String cardNumber = '';
  String cardName = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool isCardNameInvalid = false;
  MediaQueryData mediaQueryData;
  List<Widget> validCardNames = <Widget>[];
  List<String> validCardNamesText = const <String>['VISA', 'AMEX', 'HIPERCARD'];

  @override
  void initState() {
    super.initState();
  }

  void addCardNameWidget(String cardName) {
    validCardNames.add(Container(
      height: 16,
      width: 20,
      child: Container(
        child: CreditCardWidgetState.getCardTypeIconByCardName(cardName)
      ),
    ));

    validCardNames.add(Container(
      height: 16,
      child: Text(
        ' ' + cardName + (validCardNamesText.last == cardName ? '' : ', '),
        style: TextStyle(color: Colors.red[800]),
        textAlign: TextAlign.left,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    isCardNameInvalid = validCardNamesText != null && cardName != '' && validCardNamesText.indexWhere((String el) => el == cardName) == -1;

    if (cardNumber != '' && isCardNameInvalid) {
      validCardNames.clear();

      validCardNames.add(Container(
        height: 16,
        child: Text(
          'Bandeiras válidas:',
          style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.w900),
          textAlign: TextAlign.left,
        ),
      ));

      validCardNamesText.forEach(addCardNameWidget);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: mediaQueryData.size.height - mediaQueryData.viewPadding.bottom - mediaQueryData.viewPadding.top,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    child: CreditCardWidget(
                      cardName: (String value) {
                        if (cardName != value)
                          setState(() {
                            cardName = value;
                          });
                      },
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: isCvvFocused,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: CreditCardForm(
                      validCardNames: validCardNamesText,
                      cardName: cardName,
                      invalidCardNameWidget: isCardNameInvalid ? Container(
                        margin: const EdgeInsets.only(left: 18, top: 8, right: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                'O estabelecimento não aceita essa bandeira para pagamento online.',
                                style: TextStyle(color: Colors.red[800]),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Wrap(
                              children: validCardNames,
                            ),
                          ],
                        ),
                      ) : null,
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}