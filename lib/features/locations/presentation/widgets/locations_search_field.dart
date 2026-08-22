import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:flutter/material.dart';

class LocationsSearchField extends StatefulWidget {
  const LocationsSearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search country, city, or region',
    this.initialValue = '',
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final String initialValue;

  @override
  State<LocationsSearchField> createState() => _LocationsSearchFieldState();
}

class _LocationsSearchFieldState extends State<LocationsSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasText = _controller.text.isNotEmpty;

    return TextField(
      controller: _controller,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        prefixIcon: Icon(Icons.search_rounded, color: scheme.secondary),
        suffixIcon: hasText
            ? IconButton(
                tooltip: 'Clear search',
                onPressed: _clear,
                icon: Icon(Icons.close_rounded, color: scheme.secondary),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      ),
    );
  }
}
