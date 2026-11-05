import 'package:zedu/core/core.dart';

/// Profile popup for a chat participant: avatar, name and, when known,
/// email and user id. Opened by tapping a message avatar.
class MemberProfileDialog extends StatelessWidget {
  const MemberProfileDialog({
    super.key,
    required this.name,
    this.avatarUrl,
    this.email,
    this.userId,
  });

  final String name;
  final String? avatarUrl;
  final String? email;
  final String? userId;

  /// Shows the dialog for [member] fields.
  static Future<void> show(
    BuildContext context, {
    required String name,
    String? avatarUrl,
    String? email,
    String? userId,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => MemberProfileDialog(
        name: name,
        avatarUrl: avatarUrl,
        email: email,
        userId: userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = avatarInitial(name);

    return Dialog(
      backgroundColor: colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
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
                      'Profile',
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: colors.primary,
                  backgroundImage: avatarUrl != null &&
                          avatarUrl!.isNotEmpty
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null || avatarUrl!.isEmpty
                      ? Text(
                          initial,
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (email != null && email!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DetailRow(label: 'Email', value: email!, colors: colors),
              ],
              if (userId != null && userId!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DetailRow(label: 'User ID', value: userId!, colors: colors),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: colors.textHint,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
