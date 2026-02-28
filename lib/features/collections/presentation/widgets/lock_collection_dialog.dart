import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LockCollectionDialog extends StatefulWidget {
  final bool isCurrentlyLocked;
  final Function(bool isLocked, String? pin) onConfirm;

  const LockCollectionDialog({
    super.key,
    required this.isCurrentlyLocked,
    required this.onConfirm,
  });

  @override
  State<LockCollectionDialog> createState() => _LockCollectionDialogState();
}

class _LockCollectionDialogState extends State<LockCollectionDialog> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isCurrentlyLocked ? 'فتح القفل' : 'قفل المجلد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isCurrentlyLocked)
              Text(
                'هل تريد إزالة القفل من هذا المجلد؟',
                style: TextStyle(fontSize: 14.sp),
              )
            else ...[
              Text(
                'أدخل رقم سري لحماية المجلد',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _pinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'الرقم السري (4-6 أرقام)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _confirmPinController,
                obscureText: _obscureConfirmPin,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'تأكيد الرقم السري',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPin ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPin = !_obscureConfirmPin),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: _handleConfirm,
          child: Text(widget.isCurrentlyLocked ? 'فتح القفل' : 'قفل'),
        ),
      ],
    );
  }

  void _handleConfirm() {
    if (widget.isCurrentlyLocked) {
      // Remove lock
      widget.onConfirm(false, null);
      Navigator.pop(context);
    } else {
      // Add lock
      final pin = _pinController.text.trim();
      final confirmPin = _confirmPinController.text.trim();

      if (pin.isEmpty || pin.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرقم السري يجب أن يكون 4-6 أرقام'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (pin != confirmPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرقم السري غير متطابق'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      widget.onConfirm(true, pin);
      Navigator.pop(context);
    }
  }
}
