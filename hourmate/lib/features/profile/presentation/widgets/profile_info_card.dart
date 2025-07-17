import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileInfoCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileInfoCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFF2C2C2C),
            const Color(0xFF1A1A1A).withValues(alpha: 0.5),
            const Color(0xFF0D0D0D).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Name and Position
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['name'],
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData['position'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.neonYellowGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
                    userData['avatar'],
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
            userData['company'],
            AppTheme.cyanBlue,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.email_rounded,
            'Email',
            userData['email'],
            AppTheme.orange,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Member since',
            userData['joinDate'],
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
