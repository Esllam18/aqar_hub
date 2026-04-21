import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/view/add_property_view.dart';
import 'package:flutter/material.dart';

class AppFabButton extends StatefulWidget {
  final Animation<double> scale;
  final VoidCallback onPressed;

  const AppFabButton({super.key, required this.scale, required this.onPressed});

  @override
  State<AppFabButton> createState() => _AppFabButtonState();
}

class _AppFabButtonState extends State<AppFabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.scale,
      child: ScaleTransition(
        scale: _pressCtrl,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _pressed = true);
            _pressCtrl.reverse();
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            _pressCtrl.forward();
            widget.onPressed();
          },
          onTapCancel: () {
            setState(() => _pressed = false);
            _pressCtrl.forward();
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.height * 0.01,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: context.r(56),
              height: context.r(56),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.r(16)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: _pressed ? 0.2 : 0.4,
                    ),
                    blurRadius: _pressed ? 6 : 14,
                    offset: Offset(0, _pressed ? 2 : 5),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () => Navigation.to(const AddPropertyView()),
                child: Center(
                  child: AnimatedRotation(
                    turns: _pressed ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: context.r(28),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
