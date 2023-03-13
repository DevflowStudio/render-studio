import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

typedef CustomRichTextMatchBuilder = InlineSpan Function(RegExpMatch? match);

class CustomRichTextPattern {
  ///target string that you want to format
  final dynamic targetString;

  ///string before target string.
  ///useful when you want to format text after specified words
  final String stringBeforeTarget;

  ///string after target string.
  ///useful when you want to format text before specified words
  final String stringAfterTarget;

  //Apply Word Boundaries in RegExp. The default value is true.
  ///when all values are set to true. matchLeftWordBoundary and matchRightWordBoundary has higher priority than matchWordBoundaries.
  final bool matchWordBoundaries;

  ///Apply only left Word Boundary in RegExp. The default value is false.
  /// It Will be set to false when matchWordBoundaries is true.
  ////when all values are set to true. matchLeftWordBoundary has higher priority than matchWordBoundaries and matchRightWordBoundary.
  final bool matchLeftWordBoundary;

  ///Apply only left Word Boundary in RegExp. The default value is false.
  ///It Will be set to false when matchWordBoundaries or matchLeftWordBoundary is true.
  ////when all values are set to true. matchRightWordBoundary have higher priority than matchWordBoundaries but lower priority than matchLeftWordBoundary.
  final bool matchRightWordBoundary;

  ///convert targetString to superScript
  ///superscript has higher priority than subscript
  final bool superScript;

  ///convert targetString to subscript
  final bool subScript;

  ///Style of target text
  final TextStyle? style;

  ///apply url_launcher, support email, website, and telephone
  final String? urlType;

  ///GestureRecognizer
  final GestureRecognizer? recognizer;

  ///set true if the targetString contains specified characters \[]()^*+?.$-{}|!
  final bool hasSpecialCharacters;

  ///match first, last, or all [0, 1, 'last']
  ///default match all
  final dynamic matchOption;

  final CustomRichTextMatchBuilder? matchBuilder;

  CustomRichTextPattern({
    Key? key,
    required this.targetString,
    this.stringBeforeTarget = '',
    this.stringAfterTarget = '',
    this.matchWordBoundaries = true,
    this.matchLeftWordBoundary = true,
    this.matchRightWordBoundary = true,
    this.superScript = false,
    this.subScript = false,
    this.style,
    this.urlType,
    this.recognizer,
    this.hasSpecialCharacters = false,
    this.matchOption = 'all',
    this.matchBuilder,
  });

  CustomRichTextPattern copyWith({
    targetString,
    stringBeforeTarget,
    stringAfterTarget,
    matchWordBoundaries,
    matchLeftWordBoundary,
    matchRightWordBoundary,
    superScript,
    subScript,
    style,
    urlType,
    recognizer,
    hasSpecialCharacters,
    matchOption,
    matchBuilder,
  }) {
    return CustomRichTextPattern(
      targetString: targetString ?? this.targetString,
      stringBeforeTarget: stringBeforeTarget ?? this.stringBeforeTarget,
      stringAfterTarget: stringAfterTarget ?? this.stringAfterTarget,
      matchWordBoundaries: matchWordBoundaries ?? this.matchWordBoundaries,
      matchLeftWordBoundary:
          matchLeftWordBoundary ?? this.matchLeftWordBoundary,
      matchRightWordBoundary:
          matchRightWordBoundary ?? this.matchRightWordBoundary,
      superScript: superScript ?? this.superScript,
      subScript: subScript ?? this.subScript,
      style: style ?? this.style,
      urlType: urlType ?? this.urlType,
      recognizer: recognizer ?? this.recognizer,
      hasSpecialCharacters: hasSpecialCharacters ?? this.hasSpecialCharacters,
      matchOption: matchOption ?? this.matchOption,
      matchBuilder: matchBuilder ?? this.matchBuilder,
    );
  }
}

TextSpan textSpanBuilder({
  required String text,
  required List<CustomRichTextPattern> patternList,
  required TextStyle? defaultStyle,
  bool caseSensitive = true,
  bool multiLine = false,
  bool dotAll = false,
}) {
  _launchURL(String str) async {
    String url = str;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
  List<String> specialCharacters() {
    return '\\~[]{}#%^*+=_|<>£€•.,!’()?-\$'.split('');
  }

  TapGestureRecognizer? tapGestureRecognizerForUrls(String str, String urlType) {
    TapGestureRecognizer? tapGestureRecognizer;
    switch (urlType) {
      case 'web':
        if (str.substring(0, 4) != "http") {
          str = "https://$str";
        }
        tapGestureRecognizer = TapGestureRecognizer()
          ..onTap = () {
            _launchURL(str);
          };
        break;
      case 'email':
        tapGestureRecognizer = TapGestureRecognizer()
          ..onTap = () {
            _launchURL("mailto:$str");
          };
        break;
      case 'tel':
        tapGestureRecognizer = TapGestureRecognizer()
          ..onTap = () {
            _launchURL("tel:${str.replaceAll(' ', '')}");
            // In order to recognize the number, iOS requires no empty spaces.
          };
        break;
      default:
        TapGestureRecognizer();
    }
    return tapGestureRecognizer;
  }

  List<String> processStrList(List<CustomRichTextPattern> patternList, String temText) {
    List<String> strList = [];
    List<List<int>> positions = [];

    patternList.asMap().forEach((index, pattern) {
      String thisRegExPattern;
      String targetString = pattern.targetString;
      String stringBeforeTarget = pattern.stringBeforeTarget;
      String stringAfterTarget = pattern.stringAfterTarget;

      bool matchLeftWordBoundary = pattern.matchLeftWordBoundary;
      bool matchRightWordBoundary = pattern.matchRightWordBoundary;
      bool matchWordBoundaries = pattern.matchWordBoundaries;
      //if hasSpecialCharacters then unicode is
      bool unicode = !pattern.hasSpecialCharacters;

      String wordBoundaryStringBeforeTarget1 = "\\b";
      String wordBoundaryStringBeforeTarget2 = "\\s";
      String wordBoundaryStringAfterTarget1 = "\\s";
      String wordBoundaryStringAfterTarget2 = "\\b";

      String leftBoundary = "(?<!\\w)";
      String rightBoundary = "(?!\\w)";

      ///if any of matchWordBoundaries or matchLeftWordBoundary is false
      ///set leftBoundary = ""
      if (!matchWordBoundaries || !matchLeftWordBoundary) {
        leftBoundary = "";
        wordBoundaryStringBeforeTarget1 = "";
        wordBoundaryStringAfterTarget1 = "";
      }

      if (!matchWordBoundaries || !matchRightWordBoundary) {
        rightBoundary = "";
        wordBoundaryStringBeforeTarget2 = "";
        wordBoundaryStringAfterTarget2 = "";
      }

      bool isHan = RegExp(
        r"[\u4e00-\u9fa5]+",
        caseSensitive: caseSensitive,
        unicode: unicode,
        multiLine: multiLine,
        dotAll: dotAll,
      ).hasMatch(targetString);

      bool isArabic = RegExp(r"[\u0621-\u064A]+",
              caseSensitive: caseSensitive, unicode: unicode)
          .hasMatch(targetString);

      /// if target string is Han or Arabic character
      /// set matchWordBoundaries = false
      /// set wordBoundaryStringBeforeTarget = ""
      if (isHan || isArabic) {
        matchWordBoundaries = false;
        leftBoundary = "";
        rightBoundary = "";
        wordBoundaryStringBeforeTarget1 = "";
        wordBoundaryStringBeforeTarget2 = "";
        wordBoundaryStringAfterTarget1 = "";
        wordBoundaryStringAfterTarget2 = "";
      }

      String stringBeforeTargetRegex = "";
      if (stringBeforeTarget != "") {
        stringBeforeTargetRegex =
            "(?<=$wordBoundaryStringBeforeTarget1$stringBeforeTarget$wordBoundaryStringBeforeTarget2)";
      }
      String stringAfterTargetRegex = "";
      if (stringAfterTarget != "") {
        stringAfterTargetRegex =
            "(?=$wordBoundaryStringAfterTarget1$stringAfterTarget$wordBoundaryStringAfterTarget2)";
      }

      //modify targetString by matchWordBoundaries and wordBoundaryStringBeforeTarget settings
      thisRegExPattern =
          '($stringBeforeTargetRegex$leftBoundary$targetString$rightBoundary$stringAfterTargetRegex)';
      RegExp exp = new RegExp(
        thisRegExPattern,
        caseSensitive: caseSensitive,
        unicode: unicode,
        multiLine: multiLine,
        dotAll: dotAll,
      );
      var allMatches = exp.allMatches(temText);

      //check matchOption ['all','first','last', 0, 1, 2, 3, 10]

      int matchesLength = allMatches.length;
      List<int> matchIndexList = [];
      var matchOption = pattern.matchOption;
      if (matchOption is String) {
        switch (matchOption) {
          case 'all':
            matchIndexList = new List<int>.generate(matchesLength, (i) => i);
            break;
          case 'first':
            matchIndexList = [0];
            break;
          case 'last':
            matchIndexList = [matchesLength - 1];
            break;
          default:
            matchIndexList = new List<int>.generate(matchesLength, (i) => i);
        }
      } else if (matchOption is List<dynamic>) {
        matchOption.forEach(
          (option) {
            switch (option) {
              case 'all':
                matchIndexList =
                    new List<int>.generate(matchesLength, (i) => i);
                break;
              case 'first':
                matchIndexList.add(0);
                break;
              case 'last':
                matchIndexList.add(matchesLength - 1);
                break;
              default:
                if (option is int) matchIndexList.add(option);
            }
          },
        );
      }

      ///eg. positions = [[7,11],[26,30],]
      allMatches.toList().asMap().forEach((index, match) {
        if (matchIndexList.indexOf(index) > -1) {
          positions.add([match.start, match.end]);
        }
      });
    });
    //in some cases the sorted result is still disordered;need re-sort the 1d list;
    positions.sort((a, b) => a[0].compareTo(b[0]));

    //remove invalid positions
    List<List<int>> positionsToRemove = [];
    for (var i = 1; i < positions.length; i++) {
      if (positions[i][0] < positions[i - 1][1]) {
        positionsToRemove.add(positions[i]);
      }
    }
    positionsToRemove.forEach((position) {
      positions.remove(position);
    });

    //convert positions to 1d list
    List<int> splitPositions = [0];
    positions.forEach((position) {
      splitPositions.add(position[0]);
      splitPositions.add(position[1]);
    });
    splitPositions.add(temText.length);
    splitPositions.sort();

    splitPositions.asMap().forEach((index, splitPosition) {
      if (index != 0) {
        strList
            .add(temText.substring(splitPositions[index - 1], splitPosition));
      }
    });
    return strList;
  }

  String replaceSpecialCharacters(str) {
    String tempStr = str;
    //\[]()^*+?.$-{}|!
    specialCharacters().forEach((chr) {
      tempStr = tempStr.replaceAll(chr, '\\$chr');
    });

    return tempStr;
  }
  String temText = text;
  List<CustomRichTextPattern> tempPatternList = patternList;
  List<CustomRichTextPattern> finalTempPatternList = [];
  List<CustomRichTextPattern> finalTempPatternList2 = [];
  List<String> strList = [];
  bool unicode = true;

  if (tempPatternList.isEmpty) {
    strList = [temText];
  } else {
    tempPatternList.asMap().forEach((index, pattern) {
      ///if targetString is a list
      if (pattern.targetString is List<String>) {
        pattern.targetString.asMap().forEach((index, eachTargetString) {
          finalTempPatternList
              .add(pattern.copyWith(targetString: eachTargetString));
        });
      } else {
        finalTempPatternList.add(pattern);
      }
    });

    finalTempPatternList.asMap().forEach((index, pattern) {
      if (pattern.hasSpecialCharacters) {
        unicode = false;
        String newTargetString =
            replaceSpecialCharacters(pattern.targetString);
        finalTempPatternList2
            .add(pattern.copyWith(targetString: newTargetString));
      } else {
        finalTempPatternList2.add(pattern);
      }
    });

    strList = processStrList(finalTempPatternList2, temText);
  }

  List<InlineSpan> textSpanList = [];
  strList.forEach((str) {
    var inlineSpan;
    int targetIndex = -1;
    RegExpMatch? match;
    if (tempPatternList.isNotEmpty) {
      finalTempPatternList2.asMap().forEach((index, pattern) {
        String targetString = pattern.targetString;

        //\$, match end
        RegExp targetStringExp = RegExp(
          '^$targetString\$',
          caseSensitive: caseSensitive,
          unicode: unicode,
          multiLine: multiLine,
          dotAll: dotAll,
        );

        RegExpMatch? tempMatch = targetStringExp.firstMatch(str);
        if (tempMatch is RegExpMatch) {
          targetIndex = index;
          match = tempMatch;
        }
      });
    }

    ///If str is targetString
    if (targetIndex > -1) {
      //if str is url
      var pattern = finalTempPatternList2[targetIndex];
      var urlType = pattern.urlType;

      if (null != pattern.matchBuilder && match is RegExpMatch) {
        inlineSpan = pattern.matchBuilder!(match);
      } else if (urlType != null) {
        inlineSpan = TextSpan(
          text: str,
          recognizer: tapGestureRecognizerForUrls(str, urlType),
          style: pattern.style
        );
      } else {
        inlineSpan = TextSpan(
          text: str,
          recognizer: pattern.recognizer,
          style: pattern.style,
        );
      }
    } else {
      inlineSpan = TextSpan(
        text: str,
      );
    }
    textSpanList.add(inlineSpan);
  });
  return TextSpan(
    children: textSpanList,
    style: defaultStyle
  );
}