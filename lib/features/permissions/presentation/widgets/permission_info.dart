import 'package:flutter/material.dart';

import '../../domain/permission.dart';

/// Human-friendly copy and an icon for each permission, used by the checklist
/// and the prominent-disclosure onboarding screen.
class PermissionInfo {
  const PermissionInfo({
    required this.title,
    required this.why,
    required this.icon,
  });

  final String title;
  final String why;
  final IconData icon;

  static PermissionInfo of(PermissionType type) => _map[type]!;

  static const Map<PermissionType, PermissionInfo> _map = {
    PermissionType.accessibility: PermissionInfo(
      title: 'Accessibility Service',
      why:
          'Lets For Anis notice when a blocked app opens and gently close it. '
          'It only watches which app is on screen during a session — nothing you type.',
      icon: Icons.accessibility_new_rounded,
    ),
    PermissionType.deviceAdmin: PermissionInfo(
      title: 'Device Admin',
      why:
          'Makes the app harder to remove mid-session, so a moment of weakness '
          'can\'t undo your focus.',
      icon: Icons.admin_panel_settings_rounded,
    ),
    PermissionType.usageAccess: PermissionInfo(
      title: 'Usage Access',
      why: 'Helps the app tell which app is in the foreground to block it.',
      icon: Icons.query_stats_rounded,
    ),
    PermissionType.overlay: PermissionInfo(
      title: 'Display over other apps',
      why: 'Lets the loving block screen appear instantly over a blocked app.',
      icon: Icons.layers_rounded,
    ),
    PermissionType.batteryOptimization: PermissionInfo(
      title: 'Ignore battery optimization',
      why: 'Keeps the timer running reliably so a session is never cut short.',
      icon: Icons.battery_charging_full_rounded,
    ),
    PermissionType.notifications: PermissionInfo(
      title: 'Notifications',
      why: 'Shows the persistent session notification with your time left.',
      icon: Icons.notifications_active_rounded,
    ),
  };
}
