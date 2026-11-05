class RolePermission {
  const RolePermission({
    required this.role,
    required this.description,
    required this.permissions,
  });

  final String role;
  final String description;
  final List<String> permissions;
}

/// One toggleable permission from the system catalog (`GET /permissions`).
class SystemPermission {
  const SystemPermission({
    required this.key,
    required this.name,
    required this.category,
    required this.description,
  });

  final String key;
  final String name;
  final String category;
  final String description;
}
