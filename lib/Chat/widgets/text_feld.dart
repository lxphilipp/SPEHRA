import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustumFeld extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPass;
  const CustumFeld({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isPass = false,
  });

  @override
  State<CustumFeld> createState() => _CustumFeldState();
}

class _CustumFeldState extends State<CustumFeld> {
  bool abscure = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        validator: (value) => value!.isEmpty ? "Required" : null,
        obscureText: widget.isPass ? abscure : false,
        controller: widget.controller,
        style: TextStyle(color: Colors.green),
        decoration: InputDecoration(
          suffixIcon: widget.isPass
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      abscure = !abscure;
                    });
                  },
                  icon: const Icon(Iconsax.eye))
              : const SizedBox(),
          contentPadding: const EdgeInsets.all(12),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green)),
          labelText: widget.label,
          prefixIcon: Icon(widget.icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
