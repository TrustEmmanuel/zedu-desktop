import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

/// "Pinned messages" for a DM: everything pinned in the conversation,
/// newest first. Tapping a pinned message closes the dialog with that
/// record so the chat can jump to it.
class PinnedMessagesDialog extends ConsumerStatefulWidget {
  const PinnedMessagesDialog({
    super.key,
    required this.channelId,
    required this.conversationName,
  });

  final String channelId;
  final String conversationName;

  @override
  ConsumerState<PinnedMessagesDialog> createState() =>
      _PinnedMessagesDialogState();
}

class _PinnedMessagesDialogState extends ConsumerState<PinnedMessagesDialog> {
  List<Map<String, dynamic>>? _pinned;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _pinned = null;
      _error = null;
    });
    try {
      final repository = ref.read(dmRepositoryProvider);
      final pinned = await repository.getPinnedMessages(widget.channelId);
      if (!mounted) return;
      setState(() => _pinned = pinned);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = "Couldn't load pinned messages.");
    }
  }

  static String _plainContent(Object? content) {
    var text = (content ?? '').toString();
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _sender(Map<String, dynamic> record) {
    final fullName = record['full_name']?.toString();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    final username = record['username']?.toString();
    if (username != null && username.isNotEmpty) return username;
    return 'Someone';
  }

  static String _sentAt(Object? value) {
    final time = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (time == null) return '';
    final now = DateTime.now();
    final sameDay =
        time.year == now.year && time.month == now.month && time.day == now.day;
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    if (sameDay) return '$hour:$minute $period';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[time.month - 1]} ${time.day}, $hour:$minute $period';
  }

  void _jump(Map<String, dynamic> record) {
    Navigator.pop(context, record);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final pinned = _pinned;

    return AlertDialog(
      title: Text('Pinned messages'),
      content: SizedBox(
        width: 420,
        height: 360,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pinned in ${widget.conversationName}',
              style: textTheme.bodySmall?.copyWith(color: colors.textHint),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _error != null
                  ? _ErrorState(message: _error!, onRetry: _load)
                  : pinned == null
                  ? const Center(child: CircularProgressIndicator())
                  : pinned.isEmpty
                  ? const Center(
                      child: Text('No pinned messages in this conversation.'),
                    )
                  : ListView.separated(
                      itemCount: pinned.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: colors.divider),
                      itemBuilder: (context, index) {
                        final record = pinned[index];
                        final content = _plainContent(record['message']);
                        final sender = _sender(record);
                        final sentAt = _sentAt(record['created_at']);
                        return Tooltip(
                          message: 'Jump to message',
                          child: ListTile(
                            mouseCursor: SystemMouseCursors.click,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            title: Text(
                              '$sender${sentAt.isEmpty ? '' : ' · $sentAt'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            subtitle: content.isEmpty
                                ? Text(
                                    'Attachment',
                                    style: TextStyle(
                                      color: colors.textHint,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                : Text(
                                    content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                            trailing: Icon(
                              Icons.arrow_upward,
                              size: 18,
                              color: colors.textHint,
                            ),
                            onTap: () => _jump(record),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: TextStyle(color: colors.error)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
