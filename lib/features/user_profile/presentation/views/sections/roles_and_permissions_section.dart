import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class RolesAndPermissionsSection extends StatelessWidget {
  const RolesAndPermissionsSection({super.key, required this.roles});

  final List<RolePermission> roles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(
          title: 'Roles & permissions',
          subtitle:
              'Define and manage roles, then assign their associated permissions.',
        ),
        const SizedBox(height: 28),
        for (final role in roles) ...[
          _RoleCard(role: role),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});
  final RolePermission role;

  /// The permissions list the card's chevron promises.
  void _showPermissions(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          role.role,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (role.description.isNotEmpty) ...[
                Text(role.description, style: context.textTheme.bodyMedium),
                const SizedBox(height: 16),
              ],
              if (role.permissions.isEmpty)
                Text(
                  'This role has no permissions yet.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                )
              else
                for (final permission in role.permissions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color(0xFF17C9BD),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            permission,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showPermissions(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    role.role,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_right,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                role.description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
