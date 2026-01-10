import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget pour saisir un code de sécurité à 6 chiffres
class SecurityCodeInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onCompleted;
  final bool enabled;

  const SecurityCodeInput({
    super.key,
    required this.controller,
    this.onCompleted,
    this.enabled = true,
  });

  @override
  State<SecurityCodeInput> createState() => _SecurityCodeInputState();
}

class _SecurityCodeInputState extends State<SecurityCodeInput> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    final text = widget.controller.text;
    for (int i = 0; i < 6; i++) {
      if (i < text.length) {
        _controllers[i].text = text[i];
      } else {
        _controllers[i].clear();
      }
    }
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Mettre à jour le controller principal
      final currentText = widget.controller.text;
      final newText = currentText.padRight(6, ' ').substring(0, index) +
          value +
          currentText.padRight(6, ' ').substring(index + 1);
      widget.controller.text = newText.trim();

      // Passer au champ suivant
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Dernier chiffre, enlever le focus
        _focusNodes[index].unfocus();
        
        // Appeler le callback si le code est complet
        if (widget.controller.text.length == 6) {
          widget.onCompleted?.call(widget.controller.text);
        }
      }
    }
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      
      // Mettre à jour le controller principal
      final currentText = widget.controller.text;
      if (currentText.length > index - 1) {
        widget.controller.text = currentText.substring(0, index - 1) +
            currentText.substring(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: widget.enabled ? Colors.white : Colors.grey[200],
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.isNotEmpty) {
                _onChanged(index, value);
              }
            },
            onTap: () {
              // Sélectionner tout le texte au tap
              _controllers[index].selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controllers[index].text.length,
              );
            },
            onEditingComplete: () {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
