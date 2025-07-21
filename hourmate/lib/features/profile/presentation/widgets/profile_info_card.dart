import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileInfoCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileInfoCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData['name'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['position'] ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neonYellowGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.neonYellowGreen,
                  child: Text(
                    (userData['avatar'] ?? '').toString(),
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Info Rows
          _buildInfoRow(
            Icons.business_rounded,
            'Company',
            userData['company'] ?? '',
            AppTheme.cyanBlue,
          ),
          const SizedBox(height: 12),
          // Email row removed
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Member since',
            userData['joinDate'] ?? '',
            AppTheme.neonYellowGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
