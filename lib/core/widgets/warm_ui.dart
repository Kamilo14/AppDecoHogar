import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WarmSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const WarmSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class WarmSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double borderRadius;

  const WarmSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.cardTheme.color;
    final content = Padding(padding: padding, child: child);
    
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    return Card(
      color: cardColor,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onTap,
              child: content,
            )
          : content,
    );
  }
}

class WarmStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final Color tint;
  final VoidCallback? onTap;

  const WarmStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WarmSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: tint.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: tint, size: 14),
          ),
          const SizedBox(height: 10), // Espacio fijo en lugar de Spacer
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 9,
              color: theme.textTheme.bodyLarge?.color?.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}

class WarmActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback onTap;

  const WarmActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WarmSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: -0.2,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class WarmPill extends StatelessWidget {
  final String label;
  final Color color;

  const WarmPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
      ),
    );
  }
}

class WarmStatusChip extends StatelessWidget {
  final String estado;

  const WarmStatusChip({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label = estado;
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        color = const Color(0xFFD67C52);
        label = 'Pendiente';
        break;
      case 'COMPRADO':
        color = const Color(0xFF8A6B4F);
        label = 'Comprado';
        break;
      case 'ENTREGADO':
        color = const Color(0xFF6E7E52);
        label = 'Entregado';
        break;
      case 'FINALIZADO':
        color = Colors.blueGrey;
        label = 'Finalizado';
        break;
      default:
        color = Colors.grey;
    }
    return WarmPill(label: label, color: color);
  }
}

class WarmClienteAvatar extends StatelessWidget {
  final String nombre;
  final double radius;
  final double? size;
  final bool tieneDeuda;

  const WarmClienteAvatar({
    super.key,
    required this.nombre,
    this.radius = 24,
    this.size,
    this.tieneDeuda = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tieneDeuda ? const Color(0xFFD67C52) : const Color(0xFF6E7E52);
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    final double effectiveRadius = size != null ? size! / 2 : radius;

    return Container(
      width: effectiveRadius * 2,
      height: effectiveRadius * 2,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(76), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: effectiveRadius * 0.8,
        ),
      ),
    );
  }
}

class WarmTabBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;

  const WarmTabBar({super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: TabBar(
        controller: controller,
        tabs: tabs,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: const Color(0xFF2C221E).withAlpha(150),
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
    );
  }
}

class WarmInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;

  const WarmInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color?.withAlpha(128))),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}