import 'package:flutter/material.dart';

/// Search bar for entering stock/forex symbols.
class SymbolSearchBar extends StatefulWidget {
  final String currentSymbol;
  final ValueChanged<String> onSymbolSubmitted;

  const SymbolSearchBar({
    super.key,
    required this.currentSymbol,
    required this.onSymbolSubmitted,
  });

  @override
  State<SymbolSearchBar> createState() => _SymbolSearchBarState();
}

class _SymbolSearchBarState extends State<SymbolSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentSymbol);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final symbol = _controller.text.trim().toUpperCase();
    if (symbol.isNotEmpty) {
      widget.onSymbolSubmitted(symbol);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E293B),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Enter symbol (e.g., AAPL, MSFT)',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _submit,
          ),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}
