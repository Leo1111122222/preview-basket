import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/link_bloc.dart';

class AddLinksDialog extends StatefulWidget {
  final String collectionId;

  const AddLinksDialog({super.key, required this.collectionId});

  @override
  State<AddLinksDialog> createState() => _AddLinksDialogState();
}

class _AddLinksDialogState extends State<AddLinksDialog> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pasteFromClipboard();
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      _textController.text = clipboardData.text!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Links'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste any text containing URLs. Links will be extracted automatically.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Paste text with links here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addLinks,
          child: const Text('Add Links'),
        ),
      ],
    );
  }

  void _addLinks() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<LinkBloc>().add(
          AddLinksFromTextEvent(
            text: text,
            collectionId: widget.collectionId,
          ),
        );
    Navigator.pop(context);
  }
}
