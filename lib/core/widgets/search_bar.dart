// ===== شريط البحث المحسن =====
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomSearchBar({
    Key? key,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.controller,
    this.leading,
    this.actions,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey300),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: widget.leading!,
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.search,
                color: AppTheme.grey500,
                size: 20,
              ),
            ),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                hintStyle: TextStyle(
                  color: AppTheme.grey500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (_hasText) ...[
            IconButton(
              onPressed: _onClear,
              icon: const Icon(
                Icons.clear,
                color: AppTheme.grey500,
                size: 20,
              ),
            ),
          ],
          if (widget.actions != null) ...widget.actions!,
        ],
      ),
    );
  }
}