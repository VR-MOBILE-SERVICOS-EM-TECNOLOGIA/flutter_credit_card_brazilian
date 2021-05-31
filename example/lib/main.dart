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

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    isCardNameInvalid = validCardNamesText != null && cardName != '' && validCardNamesText.indexWhere((String el) => el == cardName) == -1;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: mediaQueryData.size.height - mediaQueryData.viewPadding.bottom - mediaQueryData.viewPadding.top,
            child: Column(
              children: <Widget>[
                Expanded(
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
                      height: 150,
                      width: 250,
                      cardMargin: const EdgeInsets.all(0),
                      frontFontColor: Colors.grey[700],
                      backFontColor: Colors.grey[700],
                      cardBorder: Border(
                        bottom: BorderSide(color: Colors.grey[400], width: 1),
                        top: BorderSide(color: Colors.grey[400], width: 1),
                        left: BorderSide(color: Colors.grey[400], width: 1),
                        right: BorderSide(color: Colors.grey[400], width: 1),
                      ),
                      backgroundGradientColor: const LinearGradient(
                        // Where the linear gradient begins and ends
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: <Color>[
                          Color(0xffbbbbbb),
                          Color(0xffeeeeee),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext contextLayout, BoxConstraints constraints) {
                      void addCardNameWidget(String cardName) {
                        validCardNames.add(Container(
                          height: constraints.biggest.height / 20,
                          width: constraints.biggest.width / 20,
                          child: Container(
                            child: CreditCardWidgetState.getCardTypeIconByCardName(cardName)
                          ),
                        ));

                        validCardNames.add(Container(
                          height: constraints.biggest.height / 20,
                          child: Text(
                            ' ' + cardName + (validCardNamesText.last == cardName ? '' : ', '),
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: constraints.biggest.height / 280 * 12,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ));
                      }

                      if (cardNumber != '' && isCardNameInvalid) {
                        validCardNames.clear();

                        validCardNames.add(Container(
                          height: constraints.biggest.height / 20,
                          child: Text(
                            'Bandeiras válidas:',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.w900,
                              fontSize: constraints.biggest.height / 280 * 12,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ));

                        validCardNamesText.forEach(addCardNameWidget);
                      }

                      return CreditCardForm(
                        validCardNames: validCardNamesText,
                        cardName: cardName,
                        constraints: constraints,
                        invalidCardNameWidget: isCardNameInvalid ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'O estabelecimento não aceita essa bandeira para pagamento online.',
                                  style: TextStyle(
                                    color: Colors.red[800],
                                    fontSize: constraints.biggest.height / 280 * 12,
                                  ),
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
                      );
                    }
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