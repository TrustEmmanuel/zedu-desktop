import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

/// "Rename Folder": edits the name of an existing folder.
class RenameFolderDialog extends ConsumerStatefulWidget {
  const RenameFolderDialog({super.key, required this.folderId, required this.currentName});

  final String folderId;
  final String currentName;

  /// Shows the dialog. Returns true when the folder was renamed.
  static Future<bool> show(
    BuildContext context, {
    required String folderId,
    required String currentName,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => RenameFolderDialog(
          folderId: folderId,
          currentName: currentName,
        ),
      ) ??
      false;

  @override
  ConsumerState<RenameFolderDialog> createState() => _RenameFolderDialogState();
}

class _RenameFolderDialogState extends ConsumerState<RenameFolderDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.currentName.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a folder name.');
      return;
    }
    if (name == widget.currentName) {
      Navigator.of(context).pop(false);
      return;
    }
    final error = await ref
        .read(filesActionsProvider.notifier)
        .renameFolder(widget.folderId, name);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSaving = ref.watch(
      filesActionsProvider.select((s) => s.isCreatingFolder),
    );

    return Dialog(
      backgroundColor: colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rename Folder',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: Icon(Icons.close, color: colors.textHint, size: 20),
                    onPressed: isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Folder name',
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                autofocus: true,
                enabled: !isSaving,
                maxLength: 100,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _save(),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Folder name',
                  hintStyle: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: colors.textHint,
                  ),
                  counterText: '',
                  errorText: _error,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: colors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: colors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: colors.error),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                    onPressed: isSaving ? null : _save,
                    child: isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
