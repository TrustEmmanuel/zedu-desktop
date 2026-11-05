import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

/// Existing roles, a Create Role action and, per role, its permissions.
class RolesAndPermissionsSection extends StatelessWidget {
  const RolesAndPermissionsSection({
    super.key,
    required this.roles,
    required this.onLoadPermissions,
    required this.onCreateRole,
  });

  final List<RolePermission> roles;

  /// Loads the toggleable permission catalog for the Create Role dialog.
  final Future<List<SystemPermission>> Function() onLoadPermissions;

  /// Creates a custom role. Returns true when the role was created, in which
  /// case the dialog closes; failures stay open and surface through the
  /// profile state's error toast.
  final Future<bool> Function({
    required String name,
    required String description,
    required Map<String, bool> permissions,
  })
  onCreateRole;

  void _openCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => CreateRoleDialog(
        loadPermissions: onLoadPermissions,
        onCreate: onCreateRole,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: 'Roles & permissions',
          subtitle:
              'Define and manage roles, then assign their associated permissions.',
          trailing: FilledButton.icon(
            onPressed: () => _openCreateDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Role'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
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

/// A role, its description and, once opened, the permissions it grants.
class _RoleCard extends StatefulWidget {
  const _RoleCard({required this.role});
  final RolePermission role;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    const hint = Color(0xFF6B7280);
    return Semantics(
      button: true,
      expanded: _expanded,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: ProfileCard(
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
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      size: 20,
                      color: hint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                role.description,
                style: context.textTheme.bodySmall?.copyWith(color: hint),
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                if (role.permissions.isEmpty)
                  Text(
                    'No permissions listed for this role.',
                    style: context.textTheme.bodySmall?.copyWith(color: hint),
                  )
                else
                  for (final permission in role.permissions)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: hint,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              permission,
                              style: context.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog that names a custom role and toggles its permissions, matching the
/// web role-modal: name, description and permission toggles grouped by
/// category, posted as `{name, description, permission_list}`.
class CreateRoleDialog extends StatefulWidget {
  const CreateRoleDialog({
    super.key,
    required this.loadPermissions,
    required this.onCreate,
  });

  final Future<List<SystemPermission>> Function() loadPermissions;
  final Future<bool> Function({
    required String name,
    required String description,
    required Map<String, bool> permissions,
  })
  onCreate;

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final Set<String> _selected = {};

  List<SystemPermission>? _catalog;
  bool _catalogFailed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _loadCatalog() {
    setState(() {
      _catalog = null;
      _catalogFailed = false;
    });
    widget.loadPermissions().then((catalog) {
      if (mounted) setState(() => _catalog = catalog);
    }).catchError((Object _) {
      if (mounted) setState(() => _catalogFailed = true);
    });
  }

  void _toggle(String key, bool enabled) {
    setState(() {
      if (enabled) {
        _selected.add(key);
      } else {
        _selected.remove(key);
      }
    });
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _saving || _catalog == null) return;
    setState(() => _saving = true);
    final created = await widget.onCreate(
      name: name,
      description: _descriptionCtrl.text.trim(),
      permissions: {
        for (final permission in _catalog!) permission.key: _selected.contains(
          permission.key,
        ),
      },
    );
    if (!mounted) return;
    if (created) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  /// The catalog grouped by category, preserving catalog order.
  Map<String, List<SystemPermission>> _grouped(
    List<SystemPermission> catalog,
  ) {
    final grouped = <String, List<SystemPermission>>{};
    for (final permission in catalog) {
      final category = permission.category.isEmpty
          ? 'general'
          : permission.category;
      grouped.putIfAbsent(category, () => []).add(permission);
    }
    return grouped;
  }

  String _categoryLabel(String category) {
    if (category.isEmpty) return 'General';
    return category[0].toUpperCase() + category.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final catalog = _catalog;

    return Dialog(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 560,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create Role',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colors.textHint, size: 20),
                      splashRadius: 18,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(
                        label: 'Role name',
                        controller: _nameCtrl,
                        hint: 'e.g. Community manager',
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        label: 'Description',
                        controller: _descriptionCtrl,
                        hint: 'What this role can do',
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Permissions',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (catalog == null && !_catalogFailed)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_catalogFailed || catalog == null)
                        _CatalogLoadError(onRetry: _loadCatalog)
                      else if (catalog.isEmpty)
                        Text(
                          'No permissions available.',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.textHint,
                          ),
                        )
                      else
                        for (final entry in _grouped(catalog).entries) ...[
                          const SizedBox(height: 8),
                          Text(
                            _categoryLabel(entry.key),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.textHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          for (final permission in entry.value)
                            CheckboxListTile(
                              value: _selected.contains(permission.key),
                              onChanged: (v) =>
                                  _toggle(permission.key, v ?? false),
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              dense: true,
                              activeColor: colors.primary,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                permission.name,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              subtitle: permission.description.isEmpty
                                  ? null
                                  : Text(
                                      permission.description,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(color: colors.textHint),
                                    ),
                            ),
                        ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.borderOutline),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      key: const Key('create-role-submit'),
                      onPressed:
                          _saving || _nameCtrl.text.trim().isEmpty || catalog == null
                          ? null
                          : _create,
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Role',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool autofocus = false,
  }) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: colors.textHint,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.borderOutline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.borderOutline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CatalogLoadError extends StatelessWidget {
  const _CatalogLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text("We couldn't load the permission list."),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
