import 'package:material_ui/material_ui.dart';

import '../theme/text.dart';
import '../theme/tokens.dart';
import 'pixel_art.dart';
import 'pixel_icon.dart';

enum PixelButtonVariant { primary, teal, wood, paper }

/// Square pixel button holding one icon (or any small child), min 48dp.
class PixelIconButton extends StatelessWidget {
  const PixelIconButton({
    super.key,
    required this.semanticLabel,
    required this.onPressed,
    this.icon,
    this.child,
    this.variant = PixelButtonVariant.paper,
    this.iconColor,
  }) : assert(icon != null || child != null);

  final String semanticLabel;
  final VoidCallback? onPressed;
  final PixelIcons? icon;
  final Widget? child;
  final PixelButtonVariant variant;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return _PressableSurface(
      variant: variant,
      semanticLabel: semanticLabel,
      onPressed: onPressed,
      builder: (down) => SizedBox.square(
        dimension: kMinTap,
        child: Center(
          child:
              child ??
              PixelIcon(
                icon!,
                color:
                    iconColor ??
                    (variant == PixelButtonVariant.paper
                        ? CultivaColors.woodDark
                        : Colors.white),
              ),
        ),
      ),
    );
  }
}

/// Shared 9-slice pressable surface used by the pixel buttons.
class _PressableSurface extends StatefulWidget {
  const _PressableSurface({
    required this.variant,
    required this.semanticLabel,
    required this.onPressed,
    required this.builder,
  });

  final PixelButtonVariant variant;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Widget Function(bool down) builder;

  @override
  State<_PressableSurface> createState() => _PressableSurfaceState();
}

class _PressableSurfaceState extends State<_PressableSurface> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final shift = _down ? 2 * PixelArt.uiScale : 0.0;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _set(true) : null,
          onTapCancel: () => _set(false),
          onTapUp: enabled
              ? (_) {
                  _set(false);
                  widget.onPressed!();
                }
              : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  '${PixelArt.ui}/btn_${widget.variant.name}${_down ? '_pressed' : ''}.png',
                ),
                centerSlice: const Rect.fromLTWH(8, 8, 8, 8),
                scale: 1 / PixelArt.uiScale,
                filterQuality: FilterQuality.none,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: shift,
                bottom: 2 * PixelArt.uiScale - shift,
              ),
              child: widget.builder(_down),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chunky pixel button with a 3D lip that presses down.
///
/// One `primary` (terracotta) per screen; secondary actions use teal/wood/paper.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PixelButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PixelButtonVariant variant;
  final PixelIcons? icon;

  /// Shows a busy label and ignores taps (prevents double submit).
  final bool loading;
  final bool expand;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _down = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  Color get _fg => switch (widget.variant) {
    PixelButtonVariant.paper => CultivaColors.ink,
    _ => Colors.white,
  };

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final asset =
        '${PixelArt.ui}/btn_${widget.variant.name}${_down ? '_pressed' : ''}.png';
    final style = Theme.of(context).textTheme.labelLarge!
        .copyWith(color: _fg, fontFamily: kPixelFont);
    // The lip is 3 art px at rest, 1 when pressed; content moves down with the face.
    final shift = _down ? 2 * PixelArt.uiScale : 0.0;
    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && !widget.loading) ...[
          PixelIcon(widget.icon!, color: _fg),
          const SizedBox(width: Space.sm),
        ],
        Flexible(
          child: Text(
            widget.loading ? 'Working…' : widget.label,
            style: style,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      excludeSemantics: true,
      child: Opacity(
        opacity: widget.onPressed == null ? 0.4 : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _set(true) : null,
          onTapCancel: () => _set(false),
          onTapUp: _enabled
              ? (_) {
                  _set(false);
                  widget.onPressed!();
                }
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinTap,
              minWidth: kMinTap,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(asset),
                  centerSlice: const Rect.fromLTWH(8, 8, 8, 8),
                  scale: 1 / PixelArt.uiScale,
                  filterQuality: FilterQuality.none,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.sm + shift,
                  Space.lg,
                  Space.sm + 4 * PixelArt.uiScale - shift,
                ),
                // Same height with or without an icon (icon is 16 art px).
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 16 * PixelArt.uiScale,
                  ),
                  child: Center(widthFactor: 1, child: content),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
