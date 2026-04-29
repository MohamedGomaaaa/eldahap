
import 'package:official_gold/view_model/utils/text_style.dart';
import '../../view_model/utils/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';


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

  /// محاذاة النص
  final Alignment alignment;

  /// ✅ عرض اختياري (لو null هياخد constraint بتاع الأب)
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
    this.upColor = AppColors.green,
    this.downColor = AppColors.red,
    this.neutralColor = const Color(0xFF343A40),
    this.style,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.alignment = Alignment.center,
    this.width, this.fontSize,
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

  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 1.03)
      .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _lastReal = widget.price;
    _display = widget.price;
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
      if (_lastReal == null) return;

      _display ??= _lastReal;

      final bool isStable = (_display! - _lastReal!).abs() < 0.0000001;
      if (!isStable) return;

      final delta = _randDelta(widget.fakeMinDelta, widget.fakeMaxDelta);
      final sign = _rng.nextBool() ? 1.0 : -1.0;

      final prev = _display!;
      final next = _lastReal! + (delta * sign);

      _dir = next > prev ? 1 : (next < prev ? -1 : 0);

      setState(() => _display = next);
      _pulse();

      Future.delayed(const Duration(milliseconds: 220), () {
        if (!mounted) return;
        final prev2 = _display ?? _lastReal!;
        final real = _lastReal!;
        _dir = real > prev2 ? 1 : (real < prev2 ? -1 : 0);

        setState(() => _display = real);
        _pulse();
      });
    });
  }

  double _randDelta(double min, double max) {
    if (max <= min) return min;
    return min + _rng.nextDouble() * (max - min);
  }

  void _pulse() {
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
      width: widget.width, // ✅ لو null هياخد عرض الأب
      duration: const Duration(milliseconds: 700),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: widget.borderRadius,
      ),
      child: ScaleTransition(
        scale: _scale,
        child: Align(
          alignment: widget.alignment,
          child: Text(
            '${widget.prefix ?? ''}$txt${widget.suffix ?? ''}',
            style: widget.style ??
                WhiteTitle.display5(context).copyWith(
                  fontSize: widget.fontSize??16,
                ),
          ),
        ),
      ),
    );
  }
}
