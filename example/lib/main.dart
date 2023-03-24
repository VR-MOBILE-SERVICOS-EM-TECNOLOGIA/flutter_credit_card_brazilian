import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
  String? cardNumber = '';
  String? cardName = '';
  String? expiryDate = '';
  String? cardHolderName = '';
  String? cvvCode = '';
  String? cpfCnpj = '';
  bool isCvvFocused = false;
  bool isCardNameInvalid = false;
  bool isCardNumberInvalid = false;
  late MediaQueryData mediaQueryData;
  List<Widget> validCardNames = <Widget>[];
  List<String> validCardNamesText = const <String>[
    'VISA',
    'MASTERCARD',
    'HIPERCARD',
    'ELO',
    'ALELO ALIMENTAÇÃO',
    'ALELO REFEIÇÃO',
    'SODEXO ALIMENTAÇÃO',
    'SODEXO REFEIÇÃO',
    'SODEXO GIFT',
    'SODEXO PREMIUM',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    cardName = CreditCardWidgetState.getCardTypeName(cardNumber!);
    isCardNameInvalid = cardNumber!.replaceAll(' ', '').length > 5 && validCardNamesText.indexWhere((String el) => el == cardName) == -1;
    //final ScrollController creditCardFormScrollController = ScrollController();
    final List<CardNameConfig> cardNamesConfigs = <CardNameConfig>[
      const CardNameConfig(
        names: <String>['ELO'],
        cardNamesForInvalidMsg: <String>['ELO'],
        url: null,
        backgroundGradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0xff324f6c),
            Color(0xff50a4ac),
          ],
        ),
      ),
      const CardNameConfig(
        names: <String>['VISA'],
        cardNamesForInvalidMsg: <String>['VISA'],
        url: null,
        backgroundGradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0xff00379f),
            Color(0xff00bcfc),
          ],
        ),
      ),
      const CardNameConfig(
        names: <String>['MASTERCARD'],
        cardNamesForInvalidMsg: <String>['MASTERCARD'],
        url: null,
        backgroundGradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0xff2d4470),
            Color(0xff4998b3),
          ],
        ),
      ),
      const CardNameConfig(
        names: <String>['HIPERCARD'],
        cardNamesForInvalidMsg: <String>['HIPERCARD'],
        url: null,
        backgroundGradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0xff913c3c),
            Color(0xffbe6060),
          ],
        ),
      ),
      const CardNameConfig(
        names: <String>['ALELO REFEIÇÃO', 'ALELO ALIMENTAÇÃO'],
        cardNamesForInvalidMsg: <String>['ALELO'],
        withRadioVoucherOptions: true,
        backgroundGradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0xffd0d83d),
            Color(0xff007858),
          ],
        ),
      ),
      const CardNameConfig(
        names: <String>['SODEXO ALIMENTAÇÃO', 'SODEXO REFEIÇÃO', 'SODEXO GIFT', 'SODEXO PREMIUM'],
        cardNamesForInvalidMsg: <String>['SODEXO'],
        backgroundGradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0xffffffff),
            Color(0xff11498F),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: CreditCardWidget(
                  cardNumber: cardNumber!,
                  expiryDate: expiryDate!,
                  cardHolderName: cardHolderName!,
                  cardNamesConfigs: cardNamesConfigs,
                  isCardNameInvalid: isCardNameInvalid,
                  height: mediaQueryData.size.height / 4.3,
                  width: mediaQueryData.size.height / 2.5,
                  cardMargin: EdgeInsets.symmetric(vertical: mediaQueryData.size.height / 10, horizontal: mediaQueryData.size.width / 20),
                  cardPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  cvvCode: cvvCode!,
                  showBackView: isCvvFocused,
                  frontFontColor: Colors.white,
                  backFontColor: Colors.grey[700]!,
                  fontSizeFactor: 32,
                  cardBorder: Border(
                    bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                    top: BorderSide(color: Colors.grey[400]!, width: 1),
                    left: BorderSide(color: Colors.grey[400]!, width: 1),
                    right: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                  backgroundGradientColorNoCardName: const LinearGradient(
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
              Container(
                height: 400,
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
                            fontSize: constraints.biggest.height / 340 * 12,
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
                          'Bandeiras válidas: ',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.w900,
                            fontSize: constraints.biggest.height / 340 * 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ));

                      validCardNamesText.forEach(addCardNameWidget);
                    }

                    final CardNameConfig? selected = cardNamesConfigs.singleWhereOrNull((CardNameConfig el) => el.names.singleWhereOrNull((String name) => name == cardName) != null);

                    return CreditCardForm(
                      validCardNames: validCardNamesText,
                      cardName: cardName,
                      cardNameWithRadioVoucherOptions: selected != null ? selected.withRadioVoucherOptions : false,
                      cardHolderName: cardHolderName,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      expiryDate: expiryDate,
                      cpfCnpj: cpfCnpj,
                      constraints: constraints,
                      height: 400,
                      fontSizeFactor: 14,
                      textFieldsContentPadding: EdgeInsets.symmetric(vertical: constraints.biggest.height / 71 * 6.5, horizontal: constraints.biggest.width / 360 * 8),
                      //creditCardFormScrollController: creditCardFormScrollController,
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
                                  fontSize: constraints.biggest.height / 340 * 12,
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
                      invalidCardNumberWidget: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Número inválido!',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: constraints.biggest.height / 340 * 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      invalidExpiryDateWidget: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Data inválida.',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: constraints.biggest.height / 340 * 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      expiredDateWidget: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cartão vencido.',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: constraints.biggest.height / 340 * 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      invalidCpfWidget: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'CPF inválido.',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: constraints.biggest.height / 340 * 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      invalidCnpjWidget: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'CNPJ inválido.',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: constraints.biggest.height / 340 * 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    );
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      isCardNumberInvalid = creditCardModel.isCardNumberInvalid;
      cpfCnpj = creditCardModel.cpfCnpj;
    });
  }
}