import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:official_gold/view_model/utils/text_style.dart';

import '../../view_model/utils/colors.dart';

class LivePriceText extends StatefulWidget {
  /// السعر الحقيقي اللي جاي من السوكت
  final double price;

  /// عدد الكسور اللي هتظهر في UI
  final int decimals;

  /// أقل/أكبر مقدار تغيير وهمي لو السعر ثابت
  final double fakeMinDelta; // 0.01
  final double fakeMaxDelta; // 0.05

  /// كل قد إيه نعمل fake tick لو السعر ثابت
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

  const LivePriceText({
    super.key,
    required this.price,
    this.decimals = 2,
    this.fakeMinDelta = 0.01,
    this.fakeMaxDelta = 0.09,
    this.fakeTickEvery = const Duration(milliseconds: 900),
    this.prefix,
    this.suffix,


    this.upColor =  AppColors.green, // أخضر غامق
    this.downColor =  AppColors.red, // أحمر غامق
    this.neutralColor = const Color(0xFF343A40), // رمادي



    this.style,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  State<LivePriceText> createState() => _LivePriceTextState();
}

class _LivePriceTextState extends State<LivePriceText>
    with SingleTickerProviderStateMixin {
  final _rng = Random();

  Timer? _fakeTimer;

  double? _lastReal; // آخر سعر حقيقي وصل
  double? _display; // اللي بنعرضه (حقيقي أو حقيقي + fake)
  int _dir = 0; // 1 صعود / -1 نزول / 0 ثابت

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  );

  // ✅ NEW: بدل الفيد (اختفاء/ظهور) هنستخدم scale بسيط جدًا
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 1.03)
      .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _lastReal = widget.price;
    _display = widget.price;

    // ✅ NEW: تشغيل مؤقت الهزات الوهمية
    _startFakeTimer();
  }

  @override
  void didUpdateWidget(covariant LivePriceText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // لو السعر الحقيقي اتغير من السوكت
    if (widget.price != _lastReal) {
      final prev = _display ?? widget.price;
      final next = widget.price;

      _dir = next > prev ? 1 : (next < prev ? -1 : 0);

      _lastReal = widget.price;
      _display = widget.price;

      _pulse();
    }

    // لو المستخدم غير الـ range/المدة.. نعيد تشغيل التايمر
    if (oldWidget.fakeTickEvery != widget.fakeTickEvery ||
        oldWidget.fakeMinDelta != widget.fakeMinDelta ||
        oldWidget.fakeMaxDelta != widget.fakeMaxDelta) {
      _startFakeTimer();
    }
  }

  void _startFakeTimer() {
    _fakeTimer?.cancel();
    _fakeTimer = Timer.periodic(widget.fakeTickEvery, (_) {
      // ✅ لو السعر الحقيقي ثابت (ما اتغيرش)
      if (_lastReal == null) return;

      // لو display null
      _display ??= _lastReal;

      // لو آخر display قريب جدًا من الحقيقي (يعني ثابت فعلاً)
      final bool isStable = (_display! - _lastReal!).abs() < 0.0000001;

      if (isStable) {
        // ✅ NEW: نعمل delta عشوائي 0.01 -> 0.05
        final delta = _randDelta(widget.fakeMinDelta, widget.fakeMaxDelta);

        // ✅ NEW: نختار اتجاه عشوائي (فوق/تحت)
        final sign = _rng.nextBool() ? 1.0 : -1.0;

        final prev = _display!;
        final next = _lastReal! + (delta * sign);

        // اتجاه الخلفية حسب التغير في المعروض
        _dir = next > prev ? 1 : (next < prev ? -1 : 0);

        setState(() {
          _display = next;
        });

        _pulse();

        // ✅ NEW: بعد نبضة بسيطة، رجّع العرض للحقيقي عشان ما يبعدش
        Future.delayed(const Duration(milliseconds: 220), () {
          if (!mounted) return;
          final prev2 = _display ?? _lastReal!;
          final real = _lastReal!;
          _dir = real > prev2 ? 1 : (real < prev2 ? -1 : 0);

          setState(() {
            _display = real;
          });

          _pulse();
        });
      }
    });
  }

  double _randDelta(double min, double max) {
    if (max <= min) return min;
    return min + _rng.nextDouble() * (max - min);
  }

  void _pulse() {
    // ✅ NEW: scale سريع من غير اختفاء
    _anim.forward(from: 0).then((_) {
      if (!mounted) return;
      _anim.reverse();
    });
  }

  Color _bg() {
    if (_dir > 0) return widget.upColor;
    if (_dir < 0) return widget.downColor;
    return widget.neutralColor;
  }

  @override
  void dispose() {
    _fakeTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _display ?? widget.price;
    final txt = v.toStringAsFixed(widget.decimals);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: widget.borderRadius,
      ),
      // ✅ NEW: scale animation بدل FadeTransition
      child: ScaleTransition(
        scale: _scale,
        child: Text(
          '${widget.prefix ?? ''}$txt${widget.suffix ?? ''}',
          style: widget.style ??
            WhiteTitle.display5(context).copyWith(
              fontSize: 16,
            )
              // const TextStyle(
              //   color: Colors.white,
              //   fontSize: 16,
              //   fontWeight: FontWeight.w600,
              // ),
        ),
      ),
    );
  }
}
