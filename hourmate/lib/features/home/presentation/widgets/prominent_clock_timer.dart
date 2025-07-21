// import 'package:flutter/material.dart';
// import '../../../../core/theme/app_theme.dart';
// import 'rounded_clock_timer.dart';

// class ProminentClockTimer extends StatelessWidget {
//   final DateTime startTime;
//   final double size;
//   final String? title;
//   final String? subtitle;
//   final VoidCallback? onTap;

//   const ProminentClockTimer({
//     super.key,
//     required this.startTime,
//     this.size = 200,
//     this.title,
//     this.subtitle,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               AppTheme.cardColor,
//               AppTheme.cardColor.withValues(alpha: 0.8),
//             ],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: AppTheme.neonYellowGreen.withValues(alpha: 0.1),
//               blurRadius: 24,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.2),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           border: Border.all(
//             color: AppTheme.neonYellowGreen.withValues(alpha: 0.2),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (title != null) ...[
//               Text(
//                 title!,
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   color: AppTheme.primaryTextColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//             ],

//             // Rounded Clock Timer
//             RoundedClockTimer(
//               startTime: startTime,
//               size: size,
//               showDigitalTime: true,
//               showSeconds: true,
//             ),

//             if (subtitle != null) ...[
//               const SizedBox(height: 16),
//               Text(
//                 subtitle!,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: AppTheme.secondaryTextColor,
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
