import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'localized_text_model.dart';

class CardNameConfig {
  const CardNameConfig({
    required this.name,
    this.url,
    this.backgroundGradient = const LinearGradient(
      // Where the linear gradient begins and ends
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color(0xff132c96),
        Color(0xff35c0fd),
      ],
    )
  });

  final String name;
  final String? url;
  final LinearGradient backgroundGradient;
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.color = const Color(0x22ffffff);
    paint.style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(size.width / 2, size.height);
    path.cubicTo(
      0, size.height / 2,
      size.width / 1.5, - size.height / 1.3,
      size.width, size.height / 2
    );
    path.cubicTo(
      size.width / 1.4, - size.height / 1.25,
      - size.width / 18, size.height / 2.4,
      size.width / 2, size.height
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget({
    Key? key,
    required this.cardNumber,
    this.cardName,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    required this.showBackView,
    this.animationDuration = const Duration(milliseconds: 500),
    this.height,
    this.cardMargin = const EdgeInsets.all(16),
    this.cardPadding = const EdgeInsets.all(0),
    this.width,
    this.textStyle,
    this.frontFontColor = Colors.white,
    this.backFontColor = Colors.black,
    this.fontSizeFactor = 40,
    this.cardNamesConfigs,
    this.backgroundGradientColorNoCardName = const LinearGradient(
      // Where the linear gradient begins and ends
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color(0xff132c96),
        Color(0xff35c0fd),
      ],
    ),
    this.backgroundGradientColor = const LinearGradient(
      // Where the linear gradient begins and ends
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color(0xff1b447b),
        Color(0xff84a2cb),
      ],
    ),
    this.cardShadow = const <BoxShadow>[
      BoxShadow(
        color: Colors.black26,
        offset: Offset(0, 0),
        blurRadius: 24,
      ),
    ],
    this.cardBorder = const Border(),
    this.localizedText = const LocalizedText(),
    this.isCardNameInvalid = false,
  })  : assert(localizedText != null),
        super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final EdgeInsetsGeometry cardMargin;
  final EdgeInsetsGeometry cardPadding;
  final TextStyle? textStyle;
  final bool showBackView;
  final Duration animationDuration;
  final double? height;
  final double? width;
  final LocalizedText? localizedText;
  final Function(String?)? cardName;
  final LinearGradient backgroundGradientColor;
  final LinearGradient backgroundGradientColorNoCardName;
  final List<BoxShadow> cardShadow;
  final BoxBorder cardBorder;
  final Color frontFontColor;
  final Color backFontColor;
  final double fontSizeFactor;
  final List<CardNameConfig>? cardNamesConfigs;
  final bool isCardNameInvalid;
  @override
  CreditCardWidgetState createState() => CreditCardWidgetState();
}

class CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Animation<double>? _frontRotation;
  Animation<double>? _backRotation;
  bool statusNameCard = true;
  bool isAmex = false;
  late LocalizedText localizedText;
  late Map<String, dynamic> cardInfos;

  @override
  void initState() {
    super.initState();

    ///initialize the animation controller
    controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    ///Initialize the Front to back rotation tween sequence.
    _frontRotation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ],
    ).animate(controller);

    _backRotation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateMasks(String cardNumber) {
    cardInfos = CreditCardWidgetState.detectCCType(cardNumber);

    if (cardInfos['type'] == CardType.americanExpress) {
      if (widget.localizedText != null)
        localizedText = LocalizedText(
          cardHolderHint: widget.localizedText!.cardHolderHint,
          cardHolderLabel: widget.localizedText!.cardHolderLabel,
          cardNumberHint: cardInfos['hint'],
          cardNumberLabel: widget.localizedText!.cardNumberLabel,
          cvvHint: '****',
          cvvLabel: widget.localizedText!.cvvLabel,
          expiryDateHint: widget.localizedText!.expiryDateHint,
          expiryDateLabel: widget.localizedText!.expiryDateLabel,
        );
      else
        localizedText = const LocalizedText();
    }
    else {
      if (widget.localizedText != null)
        localizedText = LocalizedText(
          cardHolderHint: widget.localizedText!.cardHolderHint,
          cardHolderLabel: widget.localizedText!.cardHolderLabel,
          cardNumberHint: cardInfos['hint'],
          cardNumberLabel: widget.localizedText!.cardNumberLabel,
          cvvHint: '***',
          cvvLabel: widget.localizedText!.cvvLabel,
          expiryDateHint: widget.localizedText!.expiryDateHint,
          expiryDateLabel: widget.localizedText!.expiryDateLabel,
        );
      else
        localizedText = const LocalizedText();
    }
  }

  @override
  Widget build(BuildContext context) {
    updateMasks(widget.cardNumber);

    final Orientation orientation = MediaQuery.of(context).orientation;
    if (widget.cardName != null)
      Future<dynamic>.delayed(Duration.zero, () async {
        return widget.cardName!(getCardTypeName(widget.cardNumber));
      });

    ///
    /// If uer adds CVV then toggle the card from front to back..
    /// controller forward starts animation and shows back layout.
    /// controller reverse starts animation and shows front layout.
    ///
    if (widget.showBackView) {
      controller.forward();
    } else {
      controller.reverse();
    }

    if (detectCCType(widget.cardNumber)['type'] == CardType.americanExpress)
      isAmex = true;
    else
      isAmex = false;

    return LayoutBuilder(
      builder: (BuildContext contextLayout, BoxConstraints constraints) {
        final double height = widget.height ?? constraints.biggest.height;
        final double width = widget.width ?? constraints.biggest.width;

        return Stack(
          children: <Widget>[
            AnimationCard(
              animation: _frontRotation,
              child: buildFrontContainer(width, height, contextLayout, orientation),
            ),
            AnimationCard(
              animation: _backRotation,
              child: buildBackContainer(width, height, contextLayout, orientation),
            ),
          ],
        );
      },
    );
  }

  ///
  /// Builds a back container containing cvv
  ///
  Container buildBackContainer(
    double width,
    double height,
    BuildContext context,
    Orientation orientation,
  ) {
    final TextStyle defaultTextStyle = Theme.of(context).textTheme.headline6!.merge(
          TextStyle(
            color: widget.backFontColor,
            fontFamily: 'RobotoMono',
            fontSize: widget.fontSizeFactor * (height / 400),
            package: 'flutter_credit_card_brazilian',
            shadows: const <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Colors.black26
              ),
            ]
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: widget.cardShadow,
        gradient: widget.isCardNameInvalid || getCardTypeName(widget.cardNumber) == '' || widget.cardNumber.replaceAll(' ', '').length < 6 ? widget.backgroundGradientColorNoCardName : widget.cardNamesConfigs != null ? getCardBackground(cardInfos['name'], widget.cardNamesConfigs!) : widget.backgroundGradientColor,
        border: widget.cardBorder,
      ),
      margin: widget.cardMargin,
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: ClipRect(
              child: Transform.translate(
                offset: Offset(width / 10, height / 10),
                child: CustomPaint(
                  painter: CurvePainter(),
                  child: Container(),
                ),
              ),
            )
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(top: height / 60 * 4),
                  height: 48,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(top: height / 60 * 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all((width + height) / 100 * 0.7),
                            child: Text(
                              '',
                              maxLines: 1,
                              style: widget.textStyle ?? defaultTextStyle,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all((width + height) / 100 * 0.7),
                            child: Text(
                              widget.cvvCode.isEmpty
                                  ? isAmex ? '****' : localizedText.cvvHint
                                  : widget.cvvCode,
                              maxLines: 1,
                              style: widget.textStyle ?? defaultTextStyle,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.bottomRight,
                  margin: widget.cardPadding,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return widget.isCardNameInvalid ? Container() : Container(
                        height: constraints.biggest.height,
                        width: constraints.biggest.height,
                        child: getCardTypeIcon(widget.cardNumber, widget.cardNamesConfigs)
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  /// Builds a front container containing
  /// Card number, Exp. year and Card holder name
  ///
  Container buildFrontContainer(
    double width,
    double height,
    BuildContext context,
    Orientation orientation,
  ) {
    //widget.cardName(getCardTypeName(widget.cardNumber));
    final TextStyle numberTextStyle = Theme.of(context).textTheme.headline6!.merge(
          TextStyle(
            color: widget.isCardNameInvalid || getCardTypeName(widget.cardNumber) == '' || widget.cardNumber.replaceAll(' ', '').length < 6 ? widget.backFontColor : widget.frontFontColor,
            fontFamily: 'RobotoMono',
            fontSize: widget.fontSizeFactor * ((height + width) / 650),
            letterSpacing: 0.5,
            wordSpacing: -2,
            package: 'flutter_credit_card_brazilian',
            shadows: const <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Colors.black26
              ),
            ],
          ),
        );
    
    final TextStyle dateTextStyle = Theme.of(context).textTheme.headline6!.merge(
          TextStyle(
            color: widget.isCardNameInvalid || getCardTypeName(widget.cardNumber) == '' || widget.cardNumber.replaceAll(' ', '').length < 6 ? widget.backFontColor : widget.frontFontColor,
            fontFamily: 'RobotoMono',
            fontSize: widget.fontSizeFactor * ((height + width) / 1240),
            letterSpacing: 0.5,
            wordSpacing: -2,
            package: 'flutter_credit_card_brazilian',
            shadows: const <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Colors.black26
              ),
            ],
          ),
        );

    final TextStyle holderTextStyle = Theme.of(context).textTheme.headline6!.merge(
          TextStyle(
            color: widget.isCardNameInvalid || getCardTypeName(widget.cardNumber) == '' || widget.cardNumber.replaceAll(' ', '').length < 6 ? widget.backFontColor : widget.frontFontColor,
            fontFamily: 'RobotoMono',
            fontSize: widget.fontSizeFactor * ((height + width) / 1240),
            letterSpacing: 0.5,
            wordSpacing: -2,
            package: 'flutter_credit_card_brazilian',
            shadows: const <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Colors.black26
              ),
            ]
          ),
        );

    return Container(
      margin: widget.cardMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: widget.cardShadow,
        gradient: widget.isCardNameInvalid || getCardTypeName(widget.cardNumber) == '' || widget.cardNumber.replaceAll(' ', '').length < 6 ? widget.backgroundGradientColorNoCardName : widget.cardNamesConfigs != null ? getCardBackground(cardInfos['name'], widget.cardNamesConfigs!) : widget.backgroundGradientColor,
        border: widget.cardBorder,
      ),
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: ClipRect(
              child: Transform.translate(
                offset: Offset(width / 10, height / 10),
                child: CustomPaint(
                  painter: CurvePainter(),
                  child: Container(),
                ),
              ),
            )
          ),
          Container(
            padding: widget.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.all(0),
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        return widget.isCardNameInvalid ? Container() : Container(
                          height: constraints.biggest.height,
                          width: constraints.biggest.height,
                          child: getCardTypeIcon(widget.cardNumber, widget.cardNamesConfigs),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      widget.cardNumber.isEmpty ?
                          localizedText.cardNumberHint! :
                          localizedText.cardNumberHint!.replaceRange(0, widget.cardNumber.length, widget.cardNumber),
                      style: widget.textStyle ?? numberTextStyle,
                      maxLines: 1,
                      stepGranularity: 0.1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.only(bottom: height / 60 * 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              widget.cardHolderName.isEmpty ?
                                localizedText.cardHolderLabel.toUpperCase() :
                                widget.cardHolderName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: widget.textStyle ?? holderTextStyle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              widget.expiryDate.isEmpty ?
                                localizedText.expiryDateHint :
                                localizedText.expiryDateHint.replaceRange(0, widget.expiryDate.length, widget.expiryDate),
                              style: widget.textStyle ?? dateTextStyle,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 'pattern': Credit Card prefix patterns as of March 2019
  /// A [List<String>] represents a range.
  /// i.e. ['51', '55'] represents the range of cards starting with '51' to those starting with '55'
  static List<Map<String, dynamic>> cardsInfos = <Map<String, dynamic>>[
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['500000', '504174'],
        <String>['504176', '506699'],
        <String>['506800', '509999'],
      },
      'icon': Image.asset(
        'icons/aura.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.aura,
      'name': 'AURA',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['4'],
      },
      'icon': Image.asset(
        'icons/visa.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.visa,
      'name': 'VISA',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['34'],
        <String>['37'],
      },
      'icon': Image.asset(
        'icons/amex.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** ****** *****',
      'mask': '0000 000000 00000',
      'type': CardType.americanExpress,
      'name': 'AMEX',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['6011'],
        <String>['622126', '622925'],
        <String>['644', '649'],
        <String>['65']
      },
      'icon': Image.asset(
        'icons/discover.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.discover,
      'name': 'DISCOVER',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['51', '55'],
        <String>['2221', '2229'],
        <String>['223', '229'],
        <String>['23', '26'],
        <String>['270', '271'],
        <String>['2720'],
      },
      'icon': Image.asset(
        'icons/mastercard.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.mastercard,
      'name': 'MASTERCARD',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['30'],
        <String>['300', '305'],
        <String>['36'],
        <String>['38'],
        <String>['39'],
      },
      'icon': Image.asset(
        'icons/dinersclub.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** ****** ****',
      'mask': '0000 000000 0000',
      'type': CardType.dinersclub,
      'name': 'DINERS',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['3506', '3589'],
        <String>['2131'],
        <String>['1800'],
      },
      'icon': Image.asset(
        'icons/jcb.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.jcb,
      'name': 'JCB',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['4011'],
        <String>['401178'],
        <String>['401179'],
        <String>['438935'],
        <String>['457631'],
        <String>['457632'],
        <String>['431274'],
        <String>['451416'],
        <String>['457393'],
        <String>['504175'],
        <String>['506699', '506778'],
        <String>['509000', '509999'],
        <String>['627780'],
        <String>['636297'],
        <String>['636368'],
        <String>['650031', '650033'],
        <String>['650035', '650051'],
        <String>['650405', '650439'],
        <String>['650485', '650538'],
        <String>['650541', '650598'],
        <String>['650700', '650718'],
        <String>['650720', '650727'],
        <String>['650901', '650978'],
        <String>['651652', '651679'],
        <String>['655000', '655019'],
        <String>['655021', '655058'],
        <String>['6555'],
      },
      'icon': Image.asset(
        'icons/elo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.elo,
      'name': 'ELO',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['637095'],
        <String>['637568'],
        <String>['637599'],
        <String>['637609'],
        <String>['637612'],
      },
      'icon': Image.asset(
        'icons/hiper.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.hiper,
      'name': 'HIPER',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['639595'],
        <String>['608732'],
      },
      'icon': Image.asset(
        'icons/assomise.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.assomise,
      'name': 'ASSOMISE',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['628167'],
      },
      'icon': Image.asset(
        'icons/fortbrasil.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.fortbrasil,
      'name': 'FORTBRASIL',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['627892'],
        <String>['606014'],
        <String>['636414'],
      },
      'icon': Image.asset(
        'icons/sorocred.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.sorocred,
      'name': 'SOROCRED',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['637176'],
      },
      'icon': Image.asset(
        'icons/realcard.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.realcard,
      'name': 'REALCARD',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['6062'],
        <String>['384100'],
        <String>['384140'],
        <String>['384160'],
      },
      'icon': Image.asset(
        'icons/hipercard.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.hipercard,
      'name': 'HIPERCARD',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['604201', '604209'],
        <String>['60421', '60429'],
        <String>['60430', '60439'],
        <String>['604400'],
        <String>['99'],
      },
      'icon': Image.asset(
        'icons/cabal.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.cabal,
      'name': 'CABAL',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['603136'],
        <String>['603134'],
        <String>['603135'],
      },
      'icon': Image.asset(
        'icons/credishop.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.credishop,
      'name': 'CREDISHOP',
    },
    <String, dynamic>{
      'pattern': <List<String>>{
        <String>['6366'],
        <String>['6361'],
        <String>['6374'],
      },
      'icon': Image.asset(
        'icons/banese.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        package: 'flutter_credit_card_brazilian',
      ),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.banese,
      'name': 'BANESECARD',
    },
    <String, dynamic>{
      'pattern': <List<String>>{},
      'icon': Container(),
      'hint': '**** **** **** ****',
      'mask': '0000 0000 0000 0000',
      'type': CardType.otherBrand,
      'name': '',
    },
  ];

  /// This function determines the Credit Card type based on the cardPatterns
  /// and returns it.
  static Map<String, dynamic> detectCCType(String cardNumber) {
    //Default card type is other
    Map<String, dynamic> result = cardsInfos.singleWhere((Map<String, dynamic> el) => el['type'] == CardType.otherBrand);

    if (cardNumber.isEmpty || cardNumber.replaceAll(' ', '').length < 6) {
      return result;
    }

    cardsInfos.forEach(
      (Map<String, dynamic> cardInfos) {
        for (List<String> patternRange in cardInfos['pattern']) {
          // Remove any spaces
          String ccPatternStr =
              cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
          final int rangeLen = patternRange[0].length;
          // Trim the Credit Card number string to match the pattern prefix length
          if (rangeLen < cardNumber.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // Credit Card num is in the pattern range.
            // Because Strings don't have '>=' type operators
            final int ccPrefixAsInt = int.parse(ccPatternStr);
            final int startPatternPrefixAsInt = int.parse(patternRange[0]);
            final int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              result = cardInfos;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              result = cardInfos;
              break;
            }
          }
        }
      },
    );

    return result;
  }

  // This method returns the icon for the visa card type if found
  // else will return the empty container
  static Widget? getCardTypeIcon(String cardNumber, List<CardNameConfig>? cardNamesConfigs) {
    String? imageUrl = '';
    
    if (cardNamesConfigs != null)
      imageUrl = cardNamesConfigs.singleWhere((CardNameConfig el) => el.name == detectCCType(cardNumber)['name'], orElse: () => const CardNameConfig(name: '', url: '')).url;
    
    if (imageUrl != '' && imageUrl != null)
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    else
      return detectCCType(cardNumber)['icon'];
  }

  // This method returns the icon for the visa card type if found
  // else will return the empty container
  static LinearGradient getCardBackground(String? cardName, List<CardNameConfig> cardNamesConfigs) {
    return cardNamesConfigs.singleWhere((CardNameConfig el) => el.name == cardName, orElse: () => const CardNameConfig(name: '', url: '')).backgroundGradient;
  }

  // This method returns the icon for the visa card type if found
  // else will return the empty container
  static Widget? getCardTypeIconByCardName(String cardName, {List<CardNameConfig>? cardNamesConfigs, String? cardImageUrl}) {
    String? imageUrl = '';
    
    if (cardNamesConfigs != null)
      imageUrl = cardNamesConfigs.singleWhere((CardNameConfig el) => el.name == cardName, orElse: () => const CardNameConfig(name: '', url: '')).url;

    if ((imageUrl != '' && imageUrl != null) || cardImageUrl != null)
      return Image.network(
        imageUrl ?? cardImageUrl!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    else
      return cardsInfos.singleWhere((Map<String, dynamic> el) => el['name'] == cardName)['icon'];
  }

  static String? getCardTypeName(String cardNumber) {
    return detectCCType(cardNumber)['name'];
  }
}

class AnimationCard extends StatelessWidget {
  const AnimationCard({
    required this.child,
    required this.animation,
  });

  final Widget child;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation!,
      builder: (BuildContext context, Widget? child) {
        final Matrix4 transform = Matrix4.identity();
        transform.setEntry(3, 2, 0.001);
        transform.rotateY(animation!.value);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}

class MaskedTextController extends TextEditingController {
  MaskedTextController({String? text, this.mask, this.maxLength, Map<String, RegExp>? translator})
      : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      final String previous = _lastUpdatedText;
      if (beforeChange(previous, this.text)) {
        updateText(this.text);
        afterChange(previous, this.text);
      } else {
        updateText(_lastUpdatedText);
      }
    });

    updateText(this.text);
  }

  String? mask;
  int? maxLength;

  late Map<String, RegExp> translator;

  Function afterChange = (String previous, String next) {};
  Function beforeChange = (String previous, String next) {
    return true;
  };

  String _lastUpdatedText = '';

  void updateText(String? text) {
    if (text != null) {
      this.text = _applyMask(mask, text);
    } else {
      this.text = '';
    }

    _lastUpdatedText = this.text;
  }

  void updateMask(String? mask) {
    this.mask = mask;
    updateText(text);
  }

  @override
  set text(String? newText) {
    if (super.text != newText)
      value = value.copyWith(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: newText!.length)),
        composing: TextRange.empty,
      );
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return <String, RegExp>{
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  String _applyMask(String? mask, String value) {
    String result = '';

    int maskCharIndex = 0;
    int valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maxLength != null && maskCharIndex == maxLength || maxLength == null && maskCharIndex == mask!.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      String maskChar = '0';

      if (mask!.length > maskCharIndex)
        maskChar = mask[maskCharIndex];

      final String valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar]!.hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }
      
      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}

enum CardType {
  otherBrand,
  mastercard,
  visa,
  americanExpress,
  discover,
  realcard,
  elo,
  assomise,
  dinersclub,
  fortbrasil,
  hiper,
  hipercard,
  jcb,
  sorocred,
  banese,
  credishop,
  cabal,
  aura
}
