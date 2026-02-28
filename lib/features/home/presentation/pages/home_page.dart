import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الرئيسية'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.waving_hand,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً!',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'نتمنى لك يوماً سعيداً',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30.h),
            
            // Section Title
            Text(
              'الأقسام الرئيسية',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Grid of Cards
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16.w,
              crossAxisSpacing: 16.w,
              childAspectRatio: 1.0,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.person_outline,
                  title: 'الملف الشخصي',
                  subtitle: 'بياناتك الشخصية',
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Navigate to profile
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'الإعدادات',
                  subtitle: 'تخصيص التطبيق',
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'الإشعارات',
                  subtitle: 'إدارة الإشعارات',
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Navigate to notifications
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.help_outline,
                  title: 'المساعدة',
                  subtitle: 'الأسئلة الشائعة',
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to help
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go(AppRoutes.login);
        },
        icon: Icon(Icons.logout),
        label: Text('تسجيل الخروج'),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color: color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
