
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';



class LivePriceText extends StatefulWidget {
  /// السعر الحقيقي اللي جاي من السوكت
  final double price;

  /// عدد الكسور اللي هتظهر في UI
  final int decimals;

  /// أقل/أكبر مقدار تغيير وهمي لو السعر ثابت
  final double fakeMinDelta;
  final double fakeMaxDelta;

  /// كل قد إيه نعمل وميض لوني وهمي (أخضر/أحمر) أثناء انتظار السعر الحقيقي
  final Duration fakeTickEvery;

  /// تنسيق اختياري قبل/بعد السعر
  final String? prefix;
  final String? suffix;

  /// ألوان الخلفية للحركة
  final Color upColor;
  final Color downColor;
  final Color neutralColor;

  /// TextStyle للسعر
  final TextStyle? style;

  /// Padding و BorderRadius
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  /// محاذاة النص
  final Alignment alignment;

  /// عرض اختياري
  final double? width;
  final double? fontSize;

  const LivePriceText({
    super.key,
    required this.price,
    this.decimals = 2,
    this.fakeMinDelta = 0.01,
    this.fakeMaxDelta = 0.09,
    this.fakeTickEvery = const Duration(milliseconds: 900),
    this.prefix,
    this.suffix,
    this.upColor = Colors.green,
    this.downColor = Colors.red,
    this.neutralColor = const Color(0xFF343A40),
    this.style,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.alignment = Alignment.center,
    this.width,
    this.fontSize,
  });

  @override
  State<LivePriceText> createState() => _LivePriceTextState();
}

class _LivePriceTextState extends State<LivePriceText> {
  final Random _rng = Random();

  // Timers
  Timer? _fractionTimer; // تايمر لحركة الأرقام
  Timer? _fakeColorTimer; // تايمر للحركة الوهمية للألوان
  Timer? _colorResetTimer; // تايمر لإرجاع اللون للمحايد

  late double _realPrice;
  int _timerFraction = 50; // ✅ البداية الافتراضية من 50

  // ============================================================
  // ValueNotifiers
  // ============================================================
  final ValueNotifier<double> _displayNotifier = ValueNotifier<double>(0.0);
  late final ValueNotifier<Color> _bgColorNotifier;

  @override
  void initState() {
    super.initState();
    _realPrice = widget.price;
    _displayNotifier.value = widget.price;
    _bgColorNotifier = ValueNotifier<Color>(widget.neutralColor);

    _startFractionTimer();
    _startFakeColorTimer();
  }

  @override
  void didUpdateWidget(covariant LivePriceText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // وصول سعر حقيقي جديد من السوكت (كل 60 ثانية مثلاً)
    if (widget.price != _realPrice) {
      final double prev = _realPrice;
      final double next = widget.price;

      _realPrice = next;

      // 1. مقارنة السعر الحقيقي وعرض اللون المناسب (أخضر لو زاد، أحمر لو قل)
      _triggerRealFlash(next, prev);

      // 2. إعادة تشغيل تايمر الألوان الوهمية عشان ميتداخلش مع اللون الحقيقي
      _startFakeColorTimer();
    }
  }

  // ============================================================
  // 1. حركة الأرقام المستمرة (عشوائي من 50 لـ 99)
  // ============================================================
  void _startFractionTimer() {
    _fractionTimer?.cancel();

    _fractionTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!mounted) return;

      // ✅ التعديل هنا: توليد رقم عشوائي بين 50 و 99
      // nextInt(50) بتجيب رقم من 0 لـ 49، ولما نجمع عليها 50 الناتج بيبقى من 50 لـ 99
      _timerFraction = _rng.nextInt(50) + 50;

      double integerPart = _realPrice.truncateToDouble();
      double next = integerPart + (_timerFraction / 100.0);

      _displayNotifier.value = next;
    });
  }

  // ============================================================
  // 2. حركة الألوان الوهمية (أثناء انتظار الـ 60 ثانية)
  // ============================================================
  void _startFakeColorTimer() {
    _fakeColorTimer?.cancel();

    _fakeColorTimer = Timer.periodic(widget.fakeTickEvery, (_) {
      if (!mounted) return;

      // اختيار عشوائي للون (إيحاء بحركة السوق)
      final bool isFakeUp = _rng.nextBool();
      _bgColorNotifier.value = isFakeUp ? widget.upColor : widget.downColor;

      // يرجع للون المحايد بعد فترة قصيرة
      _colorResetTimer?.cancel();
      _colorResetTimer = Timer(const Duration(milliseconds: 350), () {
        if (mounted) {
          _bgColorNotifier.value = widget.neutralColor;
        }
      });
    });
  }

  // ============================================================
  // 3. الوميض الحقيقي (بناءً على المقارنة الفعلية)
  // ============================================================
  void _triggerRealFlash(double next, double prev) {
    if (next > prev) {
      _bgColorNotifier.value = widget.upColor; // السعر زاد = أخضر
    } else if (next < prev) {
      _bgColorNotifier.value = widget.downColor; // السعر قل = أحمر
    }

    _colorResetTimer?.cancel();
    // خلينا الوميض الحقيقي يطول شوية (500 مللي ثانية) عشان يلفت انتباه المستخدم
    _colorResetTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _bgColorNotifier.value = widget.neutralColor;
      }
    });
  }

  @override
  void dispose() {
    _fractionTimer?.cancel();
    _fakeColorTimer?.cancel();
    _colorResetTimer?.cancel();
    _displayNotifier.dispose();
    _bgColorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: _bgColorNotifier,
      builder: (context, bgColor, child) {
        return AnimatedContainer(
          alignment: widget.alignment,
          width: widget.width,
          duration: const Duration(milliseconds: 700),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: widget.borderRadius,
          ),
          child: child,
        );
      },
      child: ValueListenableBuilder<double>(
        valueListenable: _displayNotifier,
        builder: (context, price, _) {
          final String txt = price.toStringAsFixed(widget.decimals);

          TextStyle baseStyle = widget.style ??
              const TextStyle(color: Colors.white).copyWith(
                fontSize: widget.fontSize ?? 16,
              );

          final List<FontFeature> features = baseStyle.fontFeatures?.toList() ?? [];
          if (!features.contains(const FontFeature.tabularFigures())) {
            features.add(const FontFeature.tabularFigures());
          }

          final TextStyle finalStyle = baseStyle.copyWith(
            fontFeatures: features,
            height: 1.1,
          );

          return Text(
            '${widget.prefix ?? ''}$txt${widget.suffix ?? ''}',
            style: finalStyle,
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}
// class LivePriceText extends StatefulWidget {
//   /// السعر الحقيقي اللي جاي من السوكت
//   final double price;
//
//   /// عدد الكسور اللي هتظهر في UI
//   final int decimals;
//
//   /// أقل/أكبر مقدار تغيير وهمي لو السعر ثابت
//   final double fakeMinDelta;
//   final double fakeMaxDelta;
//
//   /// كل قد إيه نعمل وميض لوني وهمي (أخضر/أحمر) أثناء انتظار السعر الحقيقي
//   final Duration fakeTickEvery;
//
//   /// تنسيق اختياري قبل/بعد السعر
//   final String? prefix;
//   final String? suffix;
//
//   /// ألوان الخلفية للحركة
//   final Color upColor;
//   final Color downColor;
//   final Color neutralColor;
//
//   /// TextStyle للسعر
//   final TextStyle? style;
//
//   /// Padding و BorderRadius
//   final EdgeInsets padding;
//   final BorderRadius borderRadius;
//
//   /// محاذاة النص
//   final Alignment alignment;
//
//   /// عرض اختياري
//   final double? width;
//   final double? fontSize;
//
//   const LivePriceText({
//     super.key,
//     required this.price,
//     this.decimals = 2,
//     this.fakeMinDelta = 0.01,
//     this.fakeMaxDelta = 0.09,
//     this.fakeTickEvery = const Duration(milliseconds: 900),
//     this.prefix,
//     this.suffix,
//     this.upColor = Colors.green,
//     this.downColor = Colors.red,
//     this.neutralColor = const Color(0xFF343A40),
//     this.style,
//     this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//     this.borderRadius = const BorderRadius.all(Radius.circular(10)),
//     this.alignment = Alignment.center,
//     this.width,
//     this.fontSize,
//   });
//
//   @override
//   State<LivePriceText> createState() => _LivePriceTextState();
// }
//
// class _LivePriceTextState extends State<LivePriceText> {
//   final Random _rng = Random();
//
//   // Timers
//   Timer? _fractionTimer; // تايمر لحركة الأرقام
//   Timer? _fakeColorTimer; // تايمر للحركة الوهمية للألوان
//   Timer? _colorResetTimer; // تايمر لإرجاع اللون للمحايد
//
//   late double _realPrice;
//   int _timerFraction = 10; // العداد اللي هيبدأ من 10
//
//   // ============================================================
//   // ValueNotifiers
//   // ============================================================
//   final ValueNotifier<double> _displayNotifier = ValueNotifier<double>(0.0);
//   late final ValueNotifier<Color> _bgColorNotifier;
//
//   @override
//   void initState() {
//     super.initState();
//     _realPrice = widget.price;
//     _displayNotifier.value = widget.price;
//     _bgColorNotifier = ValueNotifier<Color>(widget.neutralColor);
//
//     _startFractionTimer();
//     _startFakeColorTimer();
//   }
//
//   @override
//   void didUpdateWidget(covariant LivePriceText oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     // وصول سعر حقيقي جديد من السوكت (كل 60 ثانية مثلاً)
//     if (widget.price != _realPrice) {
//       final double prev = _realPrice;
//       final double next = widget.price;
//
//       _realPrice = next;
//
//       // 1. مقارنة السعر الحقيقي وعرض اللون المناسب (أخضر لو زاد، أحمر لو قل)
//       _triggerRealFlash(next, prev);
//
//       // 2. إعادة تشغيل تايمر الألوان الوهمية عشان ميتداخلش مع اللون الحقيقي
//       _startFakeColorTimer();
//     }
//   }
//
//   // ============================================================
//   // 1. حركة الأرقام المستمرة (Stopwatch effect)
//   // ============================================================
//   void _startFractionTimer() {
//     _fractionTimer?.cancel();
//
//     _fractionTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
//       if (!mounted) return;
//
//       _timerFraction++;
//       if (_timerFraction >= 100) {
//         _timerFraction = 10;
//       }
//
//       double integerPart = _realPrice.truncateToDouble();
//       double next = integerPart + (_timerFraction / 100.0);
//
//       _displayNotifier.value = next;
//     });
//   }
//
//   // ============================================================
//   // 2. حركة الألوان الوهمية (أثناء انتظار الـ 60 ثانية)
//   // ============================================================
//   void _startFakeColorTimer() {
//     _fakeColorTimer?.cancel();
//
//     _fakeColorTimer = Timer.periodic(widget.fakeTickEvery, (_) {
//       if (!mounted) return;
//
//       // اختيار عشوائي للون (إيحاء بحركة السوق)
//       final bool isFakeUp = _rng.nextBool();
//       _bgColorNotifier.value = isFakeUp ? widget.upColor : widget.downColor;
//
//       // يرجع للون المحايد بعد فترة قصيرة
//       _colorResetTimer?.cancel();
//       _colorResetTimer = Timer(const Duration(milliseconds: 350), () {
//         if (mounted) {
//           _bgColorNotifier.value = widget.neutralColor;
//         }
//       });
//     });
//   }
//
//   // ============================================================
//   // 3. الوميض الحقيقي (بناءً على المقارنة الفعلية)
//   // ============================================================
//   void _triggerRealFlash(double next, double prev) {
//     if (next > prev) {
//       _bgColorNotifier.value = widget.upColor; // السعر زاد = أخضر
//     } else if (next < prev) {
//       _bgColorNotifier.value = widget.downColor; // السعر قل = أحمر
//     }
//
//     _colorResetTimer?.cancel();
//     // خلينا الوميض الحقيقي يطول شوية (500 مللي ثانية) عشان يلفت انتباه المستخدم
//     _colorResetTimer = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         _bgColorNotifier.value = widget.neutralColor;
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _fractionTimer?.cancel();
//     _fakeColorTimer?.cancel();
//     _colorResetTimer?.cancel();
//     _displayNotifier.dispose();
//     _bgColorNotifier.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<Color>(
//       valueListenable: _bgColorNotifier,
//       builder: (context, bgColor, child) {
//         return AnimatedContainer(
//           alignment: widget.alignment,
//           width: widget.width,
//           duration: const Duration(milliseconds: 700),
//           padding: widget.padding,
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: widget.borderRadius,
//           ),
//           child: child,
//         );
//       },
//       child: ValueListenableBuilder<double>(
//         valueListenable: _displayNotifier,
//         builder: (context, price, _) {
//           final String txt = price.toStringAsFixed(widget.decimals);
//
//           TextStyle baseStyle = widget.style ??
//               const TextStyle(color: Colors.white).copyWith(
//                 fontSize: widget.fontSize ?? 16,
//               );
//
//           final List<FontFeature> features = baseStyle.fontFeatures?.toList() ?? [];
//           if (!features.contains(const FontFeature.tabularFigures())) {
//             features.add(const FontFeature.tabularFigures());
//           }
//
//           final TextStyle finalStyle = baseStyle.copyWith(
//             fontFeatures: features,
//             height: 1.1,
//           );
//
//           return Text(
//             '${widget.prefix ?? ''}$txt${widget.suffix ?? ''}',
//             style: finalStyle,
//             textAlign: TextAlign.center,
//           );
//         },
//       ),
//     );
//   }
// }






// class LivePriceText extends StatefulWidget {
//   /// السعر الحقيقي اللي جاي من السوكت
//   final double price;
//
//   /// عدد الكسور اللي هتظهر في UI
//   final int decimals;
//
//   /// أقل/أكبر مقدار تغيير وهمي لو السعر ثابت
//   final double fakeMinDelta; // 0.01
//   final double fakeMaxDelta; // 0.05
//
//   /// كل قد إيه نعمل fake tick لو السعر ثابت
//   final Duration fakeTickEvery;
//
//   /// تنسيق اختياري قبل/بعد السعر
//   final String? prefix;
//   final String? suffix;
//
//   /// ألوان الخلفية للحركة
//   final Color upColor;
//   final Color downColor;
//   final Color neutralColor;
//
//   /// TextStyle للسعر
//   final TextStyle? style;
//
//   /// Padding و BorderRadius
//   final EdgeInsets padding;
//   final BorderRadius borderRadius;
//
//   /// محاذاة النص
//   final Alignment alignment;
//
//   /// ✅ عرض اختياري (لو null هياخد constraint بتاع الأب)
//   final double? width;
//   final double? fontSize;
//
//   const LivePriceText({
//     super.key,
//     required this.price,
//     this.decimals = 2,
//     this.fakeMinDelta = 0.01,
//     this.fakeMaxDelta = 0.09,
//     this.fakeTickEvery = const Duration(milliseconds: 900),
//     this.prefix,
//     this.suffix,
//     this.upColor = Colors.green,
//     this.downColor = Colors.red,
//     this.neutralColor = const Color(0xFF343A40),
//     this.style,
//     // ✅ خلينا البادينج الرأسي 0 تماماً عشان نلغي أي ارتفاع من الكونتينر
//     this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//     this.borderRadius = const BorderRadius.all(Radius.circular(10)),
//     this.alignment = Alignment.center,
//     this.width,
//     this.fontSize,
//   });
//
//   @override
//   State<LivePriceText> createState() => _LivePriceTextState();
// }
//
// class _LivePriceTextState extends State<LivePriceText> {
//   final Random _rng = Random();
//
//   // Timers
//   Timer? _fakeTimer;
//   Timer? _returnTimer;
//   Timer? _colorResetTimer;
//
//   late double _realPrice;
//
//   // ============================================================
//   // ValueNotifiers
//   // ============================================================
//   final ValueNotifier<double> _displayNotifier = ValueNotifier<double>(0.0);
//   late final ValueNotifier<Color> _bgColorNotifier;
//
//   @override
//   void initState() {
//     super.initState();
//     _realPrice = widget.price;
//     _displayNotifier.value = widget.price;
//     _bgColorNotifier = ValueNotifier<Color>(widget.neutralColor);
//     _startFakeTimer();
//   }
//
//   @override
//   void didUpdateWidget(covariant LivePriceText oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (widget.price != _realPrice) {
//       final double prev = _displayNotifier.value;
//       final double next = widget.price;
//
//       _realPrice = next;
//       _displayNotifier.value = next;
//
//       _triggerFlash(next, prev);
//     }
//
//     if (oldWidget.fakeTickEvery != widget.fakeTickEvery ||
//         oldWidget.fakeMinDelta != widget.fakeMinDelta ||
//         oldWidget.fakeMaxDelta != widget.fakeMaxDelta) {
//       _startFakeTimer();
//     }
//   }
//
//   void _startFakeTimer() {
//     _fakeTimer?.cancel();
//     _fakeTimer = Timer.periodic(widget.fakeTickEvery, (_) {
//       if (!mounted) return;
//
//       final bool isStable = (_displayNotifier.value - _realPrice).abs() < 0.0000001;
//       if (!isStable) return;
//
//       final double delta = _randDelta(widget.fakeMinDelta, widget.fakeMaxDelta);
//       final double sign = _rng.nextBool() ? 1.0 : -1.0;
//
//       final double prev = _displayNotifier.value;
//       final double next = _realPrice + (delta * sign);
//
//       _displayNotifier.value = next;
//       _triggerFlash(next, prev);
//
//       _returnTimer?.cancel();
//       _returnTimer = Timer(const Duration(milliseconds: 220), () {
//         if (!mounted) return;
//         final double prev2 = _displayNotifier.value;
//         final double real = _realPrice;
//
//         _displayNotifier.value = real;
//         _triggerFlash(real, prev2);
//       });
//     });
//   }
//
//   double _randDelta(double min, double max) {
//     if (max <= min) return min;
//     return min + _rng.nextDouble() * (max - min);
//   }
//
//   void _triggerFlash(double next, double prev) {
//     if (next > prev) {
//       _bgColorNotifier.value = widget.upColor;
//     } else if (next < prev) {
//       _bgColorNotifier.value = widget.downColor;
//     }
//
//     _colorResetTimer?.cancel();
//     _colorResetTimer = Timer(const Duration(milliseconds: 350), () {
//       if (mounted) {
//         _bgColorNotifier.value = widget.neutralColor;
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _fakeTimer?.cancel();
//     _returnTimer?.cancel();
//     _colorResetTimer?.cancel();
//     _displayNotifier.dispose();
//     _bgColorNotifier.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<Color>(
//       valueListenable: _bgColorNotifier,
//       builder: (context, bgColor, child) {
//         return AnimatedContainer(
//           // ✅ نقلنا الـ alignment هنا عشان نستغنى عن ويدجت Align اللي كانت بتبوظ الارتفاع
//           alignment: widget.alignment,
//           width: widget.width,
//           duration: const Duration(milliseconds: 700),
//           padding: widget.padding,
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: widget.borderRadius,
//           ),
//           child: child,
//         );
//       },
//       child: ValueListenableBuilder<double>(
//         valueListenable: _displayNotifier,
//         builder: (context, price, _) {
//           final String txt = price.toStringAsFixed(widget.decimals);
//
//           TextStyle baseStyle = widget.style ??
//               const TextStyle(color: Colors.white).copyWith(
//                 fontSize: widget.fontSize ?? 16,
//               );
//
//           final List<FontFeature> features = baseStyle.fontFeatures?.toList() ?? [];
//           if (!features.contains(const FontFeature.tabularFigures())) {
//             features.add(const FontFeature.tabularFigures());
//           }
//
//           // ✅ ضفنا height: 1.1 عشان نلغي المسافات الفاضية اللي جوا الخط نفسه
//           final TextStyle finalStyle = baseStyle.copyWith(
//             fontFeatures: features,
//             height: 1.1,
//           );
//
//           return Text(
//             '${widget.prefix ?? ''}$txt${widget.suffix ?? ''}',
//             style: finalStyle,
//             textAlign: TextAlign.center,
//           );
//         },
//       ),
//     );
//   }
// }
//












/////////////////////////////////////////////////////////////////////////////////////

// class LivePriceText extends StatefulWidget {
//   /// السعر الحقيقي اللي جاي من السوكت
//   final double price;
//
//   /// عدد الكسور اللي هتظهر في UI
//   final int decimals;
//
//   /// أقل/أكبر مقدار تغيير وهمي لو السعر ثابت
//   final double fakeMinDelta; // 0.01
//   final double fakeMaxDelta; // 0.05
//
//   /// كل قد إيه نعمل fake tick لو السعر ثابت
//   final Duration fakeTickEvery;
//
//   /// تنسيق اختياري قبل/بعد السعر
//   final String? prefix;
//   final String? suffix;
//
//   /// ألوان الخلفية للحركة
//   final Color upColor;
//   final Color downColor;
//   final Color neutralColor;
//
//   /// TextStyle للسعر
//   final TextStyle? style;
//
//   /// Padding و BorderRadius
//   final EdgeInsets padding;
//   final BorderRadius borderRadius;
//
//   /// محاذاة النص
//   final Alignment alignment;
//
//   /// ✅ عرض اختياري (لو null هياخد constraint بتاع الأب)
//   final double? width;
//  final double? fontSize;
//   const LivePriceText({
//     super.key,
//     required this.price,
//     this.decimals = 2,
//     this.fakeMinDelta = 0.01,
//     this.fakeMaxDelta = 0.09,
//     this.fakeTickEvery = const Duration(milliseconds: 900),
//     this.prefix,
//     this.suffix,
//     this.upColor = AppColors.green,
//     this.downColor = AppColors.red,
//     this.neutralColor = const Color(0xFF343A40),
//     this.style,
//     this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//     this.borderRadius = const BorderRadius.all(Radius.circular(10)),
//     this.alignment = Alignment.center,
//     this.width, this.fontSize,
//   });
//
//   @override
//   State<LivePriceText> createState() => _LivePriceTextState();
// }
//
// class _LivePriceTextState extends State<LivePriceText>
//     with SingleTickerProviderStateMixin {
//   final _rng = Random();
//   Timer? _fakeTimer;
//
//   double? _lastReal; // آخر سعر حقيقي وصل
//   double? _display; // اللي بنعرضه (حقيقي أو حقيقي + fake)
//   int _dir = 0; // 1 صعود / -1 نزول / 0 ثابت
//
//   late final AnimationController _anim = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 140),
//   );
//
//   late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 1.03)
//       .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
//
//   @override
//   void initState() {
//     super.initState();
//     _lastReal = widget.price;
//     _display = widget.price;
//     _startFakeTimer();
//   }
//
//   @override
//   void didUpdateWidget(covariant LivePriceText oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     // لو السعر الحقيقي اتغير من السوكت
//     if (widget.price != _lastReal) {
//       final prev = _display ?? widget.price;
//       final next = widget.price;
//
//       _dir = next > prev ? 1 : (next < prev ? -1 : 0);
//
//       _lastReal = widget.price;
//       _display = widget.price;
//
//       _pulse();
//     }
//
//     // لو المستخدم غير الـ range/المدة.. نعيد تشغيل التايمر
//     if (oldWidget.fakeTickEvery != widget.fakeTickEvery ||
//         oldWidget.fakeMinDelta != widget.fakeMinDelta ||
//         oldWidget.fakeMaxDelta != widget.fakeMaxDelta) {
//       _startFakeTimer();
//     }
//   }
//
//   void _startFakeTimer() {
//     _fakeTimer?.cancel();
//     _fakeTimer = Timer.periodic(widget.fakeTickEvery, (_) {
//       if (_lastReal == null) return;
//
//       _display ??= _lastReal;
//
//       final bool isStable = (_display! - _lastReal!).abs() < 0.0000001;
//       if (!isStable) return;
//
//       final delta = _randDelta(widget.fakeMinDelta, widget.fakeMaxDelta);
//       final sign = _rng.nextBool() ? 1.0 : -1.0;
//
//       final prev = _display!;
//       final next = _lastReal! + (delta * sign);
//
//       _dir = next > prev ? 1 : (next < prev ? -1 : 0);
//
//       setState(() => _display = next);
//       _pulse();
//
//       Future.delayed(const Duration(milliseconds: 220), () {
//         if (!mounted) return;
//         final prev2 = _display ?? _lastReal!;
//         final real = _lastReal!;
//         _dir = real > prev2 ? 1 : (real < prev2 ? -1 : 0);
//
//         setState(() => _display = real);
//         _pulse();
//       });
//     });
//   }
//
//   double _randDelta(double min, double max) {
//     if (max <= min) return min;
//     return min + _rng.nextDouble() * (max - min);
//   }
//
//   void _pulse() {
//     _anim.forward(from: 0).then((_) {
//       if (!mounted) return;
//       _anim.reverse();
//     });
//   }
//
//   Color _bg() {
//     if (_dir > 0) return widget.upColor;
//     if (_dir < 0) return widget.downColor;
//     return widget.neutralColor;
//   }
//
//   @override
//   void dispose() {
//     _fakeTimer?.cancel();
//     _anim.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final v = _display ?? widget.price;
//     final txt = v.toStringAsFixed(widget.decimals);
//
//     return AnimatedContainer(
//       width: widget.width, // ✅ لو null هياخد عرض الأب
//       duration: const Duration(milliseconds: 700),
//       padding: widget.padding,
//       decoration: BoxDecoration(
//         color: _bg(),
//         borderRadius: widget.borderRadius,
//       ),
//       child: ScaleTransition(
//         scale: _scale,
//         child: Align(
//           alignment: widget.alignment,
//           child: Text(
//             '${widget.prefix ?? ''}$txt${widget.suffix ?? ''}',
//             style: widget.style ??
//                 WhiteTitle.display5(context).copyWith(
//                   fontSize: widget.fontSize??16,
//                 ),
//           ),
//         ),
//       ),
//     );
//   }
// }
