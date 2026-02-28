import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnlockCollectionDialog extends StatefulWidget {
  final String correctPin;
  final VoidCallback onUnlocked;

  const UnlockCollectionDialog({
    super.key,
    required this.correctPin,
    required this.onUnlocked,
  });

  @override
  State<UnlockCollectionDialog> createState() => _UnlockCollectionDialogState();
}

class _UnlockCollectionDialogState extends State<UnlockCollectionDialog> {
  final _pinController = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock, color: Colors.orange),
          SizedBox(width: 8.w),
          const Text('مجلد مقفل'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'هذا المجلد محمي برقم سري',
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _pinController,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'أدخل الرقم السري',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.pin),
              suffixIcon: IconButton(
                icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
            ),
            onSubmitted: (_) => _handleUnlock(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _handleUnlock,
          child: const Text('فتح'),
        ),
      ],
    );
  }

  void _handleUnlock() {
    final pin = _pinController.text.trim();

    if (pin == widget.correctPin) {
      Navigator.pop(context);
      widget.onUnlocked();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرقم السري غير صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      _pinController.clear();
    }
  }
}
