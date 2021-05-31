import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'localized_text_model.dart';

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget({
    Key key,
    @required this.cardNumber,
    this.cardName,
    @required this.expiryDate,
    @required this.cardHolderName,
    @required this.cvvCode,
    @required this.showBackView,
    this.animationDuration = const Duration(milliseconds: 500),
    this.height,
    this.cardMargin = const EdgeInsets.all(16),
    this.width,
    this.textStyle,
    this.frontFontColor = Colors.white,
    this.backFontColor = Colors.black,
    this.fontSizeFactor = 40,
    this.backgroundGradientColor = const LinearGradient(
      // Where the linear gradient begins and ends
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color(0xff1b447b),
        Color(0xff3e6395),
        Color(0xff6182b0),
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
  })  : assert(cardNumber != null),
        assert(showBackView != null),
        assert(localizedText != null),
        super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final EdgeInsetsGeometry cardMargin;
  final TextStyle textStyle;
  final bool showBackView;
  final Duration animationDuration;
  final double height;
  final double width;
  final LocalizedText localizedText;
  final Function(String) cardName;
  final LinearGradient backgroundGradientColor;
  final List<BoxShadow> cardShadow;
  final BoxBorder cardBorder;
  final Color frontFontColor;
  final Color backFontColor;
  final double fontSizeFactor;
  @override
  CreditCardWidgetState createState() => CreditCardWidgetState();
}

class CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> _frontRotation;
  Animation<double> _backRotation;
  bool statusNameCard = true;
  bool isAmex = false;

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

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    Future<dynamic>.delayed(Duration.zero, () async {
      return widget.cardName(getCardTypeName(widget.cardNumber));
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

    if (detectCCType(widget.cardNumber) == CardType.americanExpress)
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
    final TextStyle defaultTextStyle = Theme.of(context).textTheme.headline6.merge(
          TextStyle(
            color: widget.backFontColor,
            fontFamily: 'halter',
            fontSize: widget.fontSizeFactor * (height / 592),
            package: 'flutter_credit_card_brazilian',
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: widget.cardShadow,
        gradient: widget.backgroundGradientColor,
        border: widget.cardBorder,
      ),
      margin: widget.cardMargin,
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(top: height / 100 * 3),
              height: 48,
              color: Colors.black,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(top: height / 100 * 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Container(
                      height: 48,
                      color: Colors.white70,
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
                              ? isAmex ? 'XXXX' : widget.localizedText.cvvHint
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
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(left: width / 60 * 2.5, right: width / 60 * 2.5, bottom: height / 100 * 3),
                child: getCardTypeIcon(widget.cardNumber),
              ),
            ),
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
    final TextStyle defaultTextStyle = Theme.of(context).textTheme.headline6.merge(
          TextStyle(
            color: widget.frontFontColor,
            fontFamily: 'halter',
            fontSize: widget.fontSizeFactor * (height / 592),
            package: 'flutter_credit_card_brazilian',
          ),
        );

    return Container(
      margin: widget.cardMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: widget.cardShadow,
        gradient: widget.backgroundGradientColor,
        border: widget.cardBorder,
      ),
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(left: width / 60 * 2.5, right: width / 60 * 2.5, top: height / 100 * 1.3),
                child: getCardTypeIcon(widget.cardNumber),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: width / 60 * 2.5),
              child: Text(
                widget.cardNumber.isEmpty || widget.cardNumber == null
                    ? widget.localizedText.cardNumberHint
                    : widget.cardNumber,
                style: widget.textStyle ?? defaultTextStyle,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: width / 60 * 2.5),
              child: Text(
                widget.expiryDate.isEmpty || widget.expiryDate == null
                    ? widget.localizedText.expiryDateHint
                    : widget.expiryDate,
                style: widget.textStyle ?? defaultTextStyle,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: width / 60 * 2.5, right: width / 60 * 2.5, bottom: height / 60 * 1.3),
              child: Text(
                widget.cardHolderName.isEmpty || widget.cardHolderName == null
                    ? widget.localizedText.cardHolderLabel.toUpperCase()
                    : widget.cardHolderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: widget.textStyle ?? defaultTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Credit Card prefix patterns as of March 2019
  /// A [List<String>] represents a range.
  /// i.e. ['51', '55'] represents the range of cards starting with '51' to those starting with '55'
  static Map<CardType, Set<List<String>>> cardNumPatterns =
      <CardType, Set<List<String>>>{
    CardType.aura: <List<String>>{
      <String>['50'],
    },
    CardType.visa: <List<String>>{
      <String>['4'],
    },
    CardType.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardType.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'],
      <String>['644', '649'],
      <String>['65']
    },
    CardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
    CardType.dinersclub: <List<String>>{
      <String>['30'],
      <String>['300', '305'],
      <String>['36'],
      <String>['38'],
      <String>['39'],
    },
    CardType.jcb: <List<String>>{
      <String>['3506', '3589'],
      <String>['2131'],
      <String>['1800'],
    },
    CardType.elo: <List<String>>{
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
    CardType.hiper: <List<String>>{
      <String>['637095'],
      <String>['637568'],
      <String>['637599'],
      <String>['637609'],
      <String>['637612'],
    },
    CardType.assomise: <List<String>>{
      <String>['639595'],
      <String>['608732'],
    },
    CardType.fortbrasil: <List<String>>{
      <String>['628167'],
    },
    CardType.sorocred: <List<String>>{
      <String>['627892'],
      <String>['606014'],
      <String>['636414'],
    },
    CardType.realcard: <List<String>>{
      <String>['637176'],
    },
    CardType.hipercard: <List<String>>{
      <String>['6062'],
      <String>['384100'],
      <String>['384140'],
      <String>['384160'],
    },
    CardType.cabal: <List<String>>{
      <String>['60'],
      <String>['99'],
    },
    CardType.credishop: <List<String>>{
      <String>['603136'],
      <String>['603134'],
      <String>['603135'],
    },
    CardType.banese: <List<String>>{
      <String>['6366'],
      <String>['6361'],
      <String>['6374']
    }
  };

  /// This function determines the Credit Card type based on the cardPatterns
  /// and returns it.
  static CardType detectCCType(String cardNumber) {
    //Default card type is other
    CardType cardType = CardType.otherBrand;

    if (cardNumber.isEmpty) {
      return cardType;
    }

    cardNumPatterns.forEach(
      (CardType type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
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
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );

    return cardType;
  }

  // This method returns the icon for the visa card type if found
  // else will return the empty container
  static Widget getCardTypeIcon(String cardNumber) {
    Widget icon;
    switch (detectCCType(cardNumber)) {
      case CardType.visa:
        icon = Image.asset(
          'icons/visa.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.americanExpress:
        icon = Image.asset(
          'icons/amex.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.mastercard:
        icon = Image.asset(
          'icons/mastercard.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.discover:
        icon = Image.asset(
          'icons/discover.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.assomise:
        icon = Image.asset(
          'icons/assomise.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.aura:
        icon = Image.asset(
          'icons/aura.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.dinersclub:
        icon = Image.asset(
          'icons/dinersclub.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.fortbrasil:
        icon = Image.asset(
          'icons/fortbrasil.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.elo:
        icon = Image.asset(
          'icons/elo.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.hiper:
        icon = Image.asset(
          'icons/hiper.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.hipercard:
        icon = Image.asset(
          'icons/hipercard.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.jcb:
        icon = Image.asset(
          'icons/jcb.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.sorocred:
        icon = Image.asset(
          'icons/sorocred.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.realcard:
        icon = Image.asset(
          'icons/realcard.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;
      case CardType.cabal:
        icon = Image.asset(
          'icons/cabal.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.credishop:
        icon = Image.asset(
          'icons/credishop.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case CardType.banese:
        icon = Image.asset(
          'icons/banese.png',
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      default:
        icon = Container(
          height: 48,
          width: 48,
          alignment: Alignment.topRight,
        );
        break;
    }
    return icon;
  }

  // This method returns the icon for the visa card type if found
  // else will return the empty container
  static Widget getCardTypeIconByCardName(String cardName) {
    Widget icon;
    switch (cardName) {
      case 'VISA':
        icon = Image.asset(
          'icons/visa.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'AMEX':
        icon = Image.asset(
          'icons/amex.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'MASTERCARD':
        icon = Image.asset(
          'icons/mastercard.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'DISCOVER':
        icon = Image.asset(
          'icons/discover.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'ASSOMISE':
        icon = Image.asset(
          'icons/assomise.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'AURA':
        icon = Image.asset(
          'icons/aura.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'DINERS':
        icon = Image.asset(
          'icons/dinersclub.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'FORTBRASIL':
        icon = Image.asset(
          'icons/fortbrasil.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'ELO':
        icon = Image.asset(
          'icons/elo.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'HIPER':
        icon = Image.asset(
          'icons/hiper.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'HIPERCARD':
        icon = Image.asset(
          'icons/hipercard.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'JCB':
        icon = Image.asset(
          'icons/jcb.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'SOROCRED':
        icon = Image.asset(
          'icons/sorocred.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'REALCARD':
        icon = Image.asset(
          'icons/realcard.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;
      case 'CABAL':
        icon = Image.asset(
          'icons/cabal.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'CREDISHOP':
        icon = Image.asset(
          'icons/credishop.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      case 'BANESECARD':
        icon = Image.asset(
          'icons/banese.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        break;

      default:
        icon = Container(
          height: 48,
          width: 48,
        );
        break;
    }
    return icon;
  }

  String getCardTypeName(String cardNumber) {
    String name = '';
    switch (detectCCType(cardNumber)) {
      case CardType.visa:
        name = 'VISA';
        break;
      case CardType.americanExpress:
        name = 'AMEX';
        break;
      case CardType.mastercard:
        name = 'MASTERCARD';
        break;
      case CardType.discover:
        name = 'DISCOVER';
        break;
      case CardType.assomise:
        name = 'ASSOMISE';
        break;
      case CardType.aura:
        name = 'AURA';
        break;
      case CardType.dinersclub:
        name = 'DINERS';
        break;
      case CardType.fortbrasil:
        name = 'FORTBRASIL';
        break;
      case CardType.elo:
        name = 'ELO';
        break;
      case CardType.hiper:
        name = 'HIPER';
        break;
      case CardType.hipercard:
        name = 'HIPERCARD';
        break;
      case CardType.jcb:
        name = 'JCB';
        break;
      case CardType.sorocred:
        name = 'SOROCRED';
        break;
      case CardType.realcard:
        name = 'REALCARD';
        break;
      case CardType.cabal:
        name = 'CABAL';
        break;
      case CardType.banese:
        name = 'BANESECARD';
        break;
      case CardType.credishop:
        name = 'CREDISHOP';
        break;
      default:
        name = '';
        break;
    }
    return name;
  }
}

class AnimationCard extends StatelessWidget {
  const AnimationCard({
    @required this.child,
    @required this.animation,
  });

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        final Matrix4 transform = Matrix4.identity();
        transform.setEntry(3, 2, 0.001);
        transform.rotateY(animation.value);
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
  MaskedTextController({String text, this.mask, Map<String, RegExp> translator})
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

  String mask;

  Map<String, RegExp> translator;

  Function afterChange = (String previous, String next) {};
  Function beforeChange = (String previous, String next) {
    return true;
  };

  String _lastUpdatedText = '';

  void updateText(String text) {
    if (text != null) {
      this.text = _applyMask(mask, text);
    } else {
      this.text = '';
    }

    _lastUpdatedText = this.text;
  }

  void updateMask(String mask, {bool moveCursorToEnd = true}) {
    this.mask = mask;
    updateText(text);

    if (moveCursorToEnd) {
      this.moveCursorToEnd();
    }
  }

  void moveCursorToEnd() {
    final String text = _lastUpdatedText;
    selection =
        TextSelection.fromPosition(TextPosition(offset: (text ?? '').length));
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return <String, RegExp>{
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  String _applyMask(String mask, String value) {
    String result = '';

    int maskCharIndex = 0;
    int valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      final String maskChar = mask[maskCharIndex];
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
        if (translator[maskChar].hasMatch(valueChar)) {
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
