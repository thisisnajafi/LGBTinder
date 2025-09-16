import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/accessibility_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;

  const AccessibleCard({
    Key? key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: accessibilityService.getAccessibleColor(
          baseColor: backgroundColor ?? AppColors.navbarBackground,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: shadow != null ? [shadow!] : null,
        border: Border.all(
          color: accessibilityService.getAccessibleColor(
            baseColor: Colors.white24,
            highContrastColor: Colors.white,
          ),
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return AccessibilityWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      child: card,
    );
  }
}

class AccessibleListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;

  const AccessibleListTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel ?? title,
      semanticHint: semanticHint,
      enabled: enabled,
      child: ListTile(
        title: Text(
          title,
          style: accessibilityService.getAccessibleTextStyle(
            baseStyle: AppTypography.body1.copyWith(
              color: enabled ? Colors.white : Colors.white54,
            ),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: accessibilityService.getAccessibleTextStyle(
                  baseStyle: AppTypography.body2.copyWith(
                    color: enabled ? Colors.white70 : Colors.white38,
                  ),
                ),
              )
            : null,
        leading: leading,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        enabled: enabled,
      ),
    );
  }
}

class AccessibleTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AccessibleTextField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
    this.textInputAction,
  }) : super(key: key);

  @override
  State<AccessibleTextField> createState() => _AccessibleTextFieldState();
}

class _AccessibleTextFieldState extends State<AccessibleTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: widget.semanticLabel ?? widget.label,
      semanticHint: widget.semanticHint,
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        focusNode: _focusNode,
        textInputAction: widget.textInputAction,
        style: accessibilityService.getAccessibleTextStyle(
          baseStyle: TextStyle(
            color: widget.enabled ? Colors.white : Colors.white60,
          ),
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          labelStyle: accessibilityService.getAccessibleTextStyle(
            baseStyle: TextStyle(
              color: Colors.white70,
            ),
          ),
          hintStyle: accessibilityService.getAccessibleTextStyle(
            baseStyle: TextStyle(
              color: Colors.white54,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: accessibilityService.getAccessibleColor(
                baseColor: Colors.white30,
                highContrastColor: Colors.white,
              ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: accessibilityService.getAccessibleColor(
                baseColor: Colors.white30,
                highContrastColor: Colors.white,
              ),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: accessibilityService.getAccessibleColor(
                baseColor: AppColors.primary,
                highContrastColor: Colors.white,
              ),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }
}

class AccessibleSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;

  const AccessibleSwitch({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel ?? title,
      semanticHint: semanticHint,
      enabled: enabled,
      child: SwitchListTile(
        title: Text(
          title,
          style: accessibilityService.getAccessibleTextStyle(
            baseStyle: AppTypography.body1.copyWith(
              color: enabled ? Colors.white : Colors.white54,
            ),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: accessibilityService.getAccessibleTextStyle(
                  baseStyle: AppTypography.body2.copyWith(
                    color: enabled ? Colors.white70 : Colors.white38,
                  ),
                ),
              )
            : null,
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: accessibilityService.getAccessibleColor(
          baseColor: AppColors.primary,
          highContrastColor: Colors.white,
        ),
      ),
    );
  }
}

class AccessibleSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;

  const AccessibleSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel ?? label,
      semanticHint: semanticHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: accessibilityService.getAccessibleTextStyle(
              baseStyle: AppTypography.body1.copyWith(
                color: enabled ? Colors.white : Colors.white54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
            activeColor: accessibilityService.getAccessibleColor(
              baseColor: AppColors.primary,
              highContrastColor: Colors.white,
            ),
            inactiveColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class AccessibleImage extends StatelessWidget {
  final String imageUrl;
  final String? semanticLabel;
  final String? semanticHint;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AccessibleImage({
    Key? key,
    required this.imageUrl,
    this.semanticLabel,
    this.semanticHint,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel ?? accessibilityService.getImageSemanticLabel(imageUrl),
      semanticHint: semanticHint,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      ),
    );
  }
}

class AccessibleFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AccessibleFloatingActionButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.tooltip,
    this.semanticLabel,
    this.semanticHint,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: accessibilityService.getAccessibleColor(
          baseColor: backgroundColor ?? AppColors.primary,
          highContrastColor: Colors.white,
        ),
        foregroundColor: accessibilityService.getAccessibleColor(
          baseColor: foregroundColor ?? Colors.white,
          highContrastColor: Colors.black,
        ),
        tooltip: tooltip,
        child: child,
      ),
    );
  }
}

class AccessibleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AccessibleAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.semanticLabel,
    this.semanticHint,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel ?? title,
      semanticHint: semanticHint,
      child: AppBar(
        title: Text(
          title,
          style: accessibilityService.getAccessibleTextStyle(
            baseStyle: AppTypography.h4.copyWith(
              color: foregroundColor ?? Colors.white,
            ),
          ),
        ),
        actions: actions,
        leading: leading,
        backgroundColor: accessibilityService.getAccessibleColor(
          baseColor: backgroundColor ?? AppColors.navbarBackground,
          highContrastColor: Colors.black,
        ),
        foregroundColor: accessibilityService.getAccessibleColor(
          baseColor: foregroundColor ?? Colors.white,
          highContrastColor: Colors.white,
        ),
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
