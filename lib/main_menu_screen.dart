import 'package:flutter/material.dart';
import 'home_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final logoSize = (w * 0.5).clamp(120.0, 200.0);
                final titleSize = (w * 0.055).clamp(16.0, 24.0);
                final subtitleSize = (w * 0.045).clamp(14.0, 20.0);

                return Column(
                  children: [
                    SizedBox(height: w * 0.07),
                    // ロゴ
                    Image.asset(
                      'assets/images/ksn_logo.png',
                      height: logoSize,
                    ),
                    const SizedBox(height: 8),
                    // タイトル
                    Text(
                      'ことばサポートネット',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5BAD5B),
                      ),
                    ),
                    Text(
                      '練習アプリ',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5BAD5B),
                      ),
                    ),
                    SizedBox(height: w * 0.1),
                    // ゲーム選択ボタン
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                      child: Column(
                        children: [
                          _GameButton(
                            label: 'まるばつゲーム',
                            icon: Icons.grid_3x3,
                            color: const Color(0xFF64B5F6),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _GameButton(
                            label: 'すごろく',
                            icon: Icons.casino,
                            color: const Color(0xFF8BC34A),
                            onTap: () => _showComingSoon(context, 'すごろく'),
                          ),
                          const SizedBox(height: 20),
                          _GameButton(
                            label: 'カルタ',
                            icon: Icons.style,
                            color: const Color(0xFFFFB74D),
                            onTap: () => _showComingSoon(context, 'カルタ'),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        '一般社団法人 ことばサポートネット',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(name),
        content: const Text('このゲームは現在準備中です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
