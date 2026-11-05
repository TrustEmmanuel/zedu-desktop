import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

/// Dialog opened by tapping the channel header: description, topic, members
/// and a leave action, matching the web channel details dialog.
class ChannelDetailsDialog extends ConsumerWidget {
  const ChannelDetailsDialog({super.key, required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final members = ref.watch(channelMembersProvider(channel.id));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(
            channel.isPrivate ? Icons.lock_outline : Icons.tag,
            size: 20,
            color: colors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '# ${channel.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(text: 'Description', colors: colors),
              const SizedBox(height: 4),
              Text(
                channel.description.trim().isEmpty
                    ? 'No description yet.'
                    : channel.description.trim(),
                style: context.textTheme.bodyMedium,
              ),
              if (channel.topic != null &&
                  channel.topic!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionLabel(text: 'Topic', colors: colors),
                const SizedBox(height: 4),
                Text(
                  channel.topic!.trim(),
                  style: context.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              _SectionLabel(text: 'Members', colors: colors),
              const SizedBox(height: 8),
              members.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Could not load members.',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No members yet.',
                        style: context.textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final member = list[index];
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: colors.accent,
                              child: Text(
                                member.username.isEmpty
                                    ? '?'
                                    : member.username.characters.first
                                          .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                member.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () async {
            await confirmAndLeaveChannel(context, ref, channel);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text('Leave channel', style: TextStyle(color: colors.error)),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.colors});

  final String text;
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: colors.textHint,
      ),
    );
  }
}

/// Confirms and performs leaving [channel], then opens another channel so the
/// header never shows one the user left.
Future<void> confirmAndLeaveChannel(
  BuildContext context,
  WidgetRef ref,
  Channel channel,
) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Leave #${channel.name}?'),
      content: Text(
        channel.isPrivate
            ? 'You will stop getting its messages, and someone will need to '
                  'add you again to rejoin.'
            : 'You will stop getting its messages. You can join it again '
                  'from the channel directory.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text('Leave', style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final overlay = Overlay.of(context, rootOverlay: true);
  final result = await ref
      .read(channelProvider.notifier)
      .leaveChannel(channel.id);

  switch (result) {
    case Success<void>():
      final remaining = ref.read(channelProvider).value ?? const <Channel>[];
      ref
          .read(activeChatProvider.notifier)
          .selectChannel(remaining.isEmpty ? 'general' : remaining.first.name);
      AppToastService.showWith(
        overlay,
        type: AppToastType.success,
        message: 'You left #${channel.name}',
      );
    case Failure<void>(:final error):
      AppToastService.showWith(
        overlay,
        type: AppToastType.error,
        message: error.message.isEmpty
            ? 'Could not leave #${channel.name}'
            : error.message,
      );
  }
}
