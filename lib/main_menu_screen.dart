import 'package:flutter/material.dart';
import 'analytics_service.dart';
import 'home_screen.dart';
import 'sugoroku/sugoroku_screens.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static bool _isPhoneLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!_isPhoneLayout(context)) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: _DesktopMenu(
                      width: constraints.maxWidth.clamp(0, 480),
                      onMaruBatsu: () => _openMaruBatsu(context),
                      onSugoroku: () => _openSugoroku(context),
                      onComingSoon: (name) => _showComingSoon(context, name),
                    ),
                  ),
                ),
              );
            }

            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isCompact = constraints.maxHeight < 520;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: isLandscape && constraints.maxWidth >= 560
                        ? _LandscapeMenu(
                            maxHeight: constraints.maxHeight,
                            onMaruBatsu: () => _openMaruBatsu(context),
                            onSugoroku: () => _openSugoroku(context),
                            onComingSoon: (name) => _showComingSoon(context, name),
                          )
                        : _PortraitMenu(
                            width: constraints.maxWidth,
                            isCompact: isCompact,
                            onMaruBatsu: () => _openMaruBatsu(context),
                            onSugoroku: () => _openSugoroku(context),
                            onComingSoon: (name) => _showComingSoon(context, name),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openMaruBatsu(BuildContext context) {
    AnalyticsService.instance.logMainMenuSelect('maru_batsu');
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: AnalyticsRoutes.boardSelect),
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  void _openSugoroku(BuildContext context) {
    AnalyticsService.instance.logMainMenuSelect('sugoroku');
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/sugoroku/select'),
        builder: (_) => const SugorokuBoardSelectScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String name) {
    final gameId = switch (name) {
      'カルタ' => 'karuta',
      _ => 'other',
    };
    AnalyticsService.instance.logMainMenuSelect(gameId);
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

/// PCブラウザ向けの元の縦並びレイアウト
class _DesktopMenu extends StatelessWidget {
  final double width;
  final VoidCallback onMaruBatsu;
  final VoidCallback onSugoroku;
  final void Function(String name) onComingSoon;

  const _DesktopMenu({
    required this.width,
    required this.onMaruBatsu,
    required this.onSugoroku,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = (width * 0.5).clamp(120.0, 200.0);
    final titleSize = (width * 0.055).clamp(16.0, 24.0);
    final subtitleSize = (width * 0.045).clamp(14.0, 20.0);

    return Column(
      children: [
        SizedBox(height: width * 0.07),
        _MenuHeader(
          logoSize: logoSize,
          titleSize: titleSize,
          subtitleSize: subtitleSize,
        ),
        SizedBox(height: width * 0.1),
        _GameButtonList(
          compact: false,
          onMaruBatsu: onMaruBatsu,
          onSugoroku: onSugoroku,
          onComingSoon: onComingSoon,
          spacing: 20,
        ),
        const Spacer(),
        const _Footer(),
      ],
    );
  }
}

class _PortraitMenu extends StatelessWidget {
  final double width;
  final bool isCompact;
  final VoidCallback onMaruBatsu;
  final VoidCallback onSugoroku;
  final void Function(String name) onComingSoon;

  const _PortraitMenu({
    required this.width,
    required this.isCompact,
    required this.onMaruBatsu,
    required this.onSugoroku,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = isCompact
        ? (width * 0.28).clamp(64.0, 100.0)
        : (width * 0.5).clamp(120.0, 200.0);
    final titleSize = isCompact ? 16.0 : (width * 0.055).clamp(16.0, 24.0);
    final subtitleSize = isCompact ? 14.0 : (width * 0.045).clamp(14.0, 20.0);
    final topSpacing = isCompact ? 8.0 : width * 0.07;
    final buttonSpacing = isCompact ? 12.0 : 20.0;

    return Column(
      mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        SizedBox(height: topSpacing),
        _MenuHeader(
          logoSize: logoSize,
          titleSize: titleSize,
          subtitleSize: subtitleSize,
        ),
        SizedBox(height: isCompact ? 16 : width * 0.1),
        _GameButtonList(
          compact: isCompact,
          onMaruBatsu: onMaruBatsu,
          onSugoroku: onSugoroku,
          onComingSoon: onComingSoon,
          spacing: buttonSpacing,
        ),
        SizedBox(height: isCompact ? 12 : 24),
        const _Footer(),
      ],
    );
  }
}

class _LandscapeMenu extends StatelessWidget {
  final double maxHeight;
  final VoidCallback onMaruBatsu;
  final VoidCallback onSugoroku;
  final void Function(String name) onComingSoon;

  const _LandscapeMenu({
    required this.maxHeight,
    required this.onMaruBatsu,
    required this.onSugoroku,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = (maxHeight * 0.45).clamp(56.0, 120.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: _MenuHeader(
            logoSize: logoSize,
            titleSize: 16,
            subtitleSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: _GameButtonList(
            compact: true,
            onMaruBatsu: onMaruBatsu,
            onSugoroku: onSugoroku,
            onComingSoon: onComingSoon,
            spacing: 10,
          ),
        ),
      ],
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final double logoSize;
  final double titleSize;
  final double subtitleSize;

  const _MenuHeader({
    required this.logoSize,
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/ksn_logo.png',
          height: logoSize,
        ),
        const SizedBox(height: 8),
        Text(
          'ことばサポートネット',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5BAD5B),
          ),
        ),
        Text(
          '練習アプリ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5BAD5B),
          ),
        ),
      ],
    );
  }
}

class _GameButtonList extends StatelessWidget {
  final bool compact;
  final VoidCallback onMaruBatsu;
  final VoidCallback onSugoroku;
  final void Function(String name) onComingSoon;
  final double spacing;

  const _GameButtonList({
    required this.compact,
    required this.onMaruBatsu,
    required this.onSugoroku,
    required this.onComingSoon,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GameButton(
            label: 'まるばつゲーム',
            icon: Icons.grid_3x3,
            color: const Color(0xFF64B5F6),
            compact: compact,
            onTap: onMaruBatsu,
          ),
          SizedBox(height: spacing),
          _GameButton(
            label: 'すごろく',
            icon: Icons.casino,
            color: const Color(0xFF8BC34A),
            compact: compact,
            onTap: onSugoroku,
          ),
          SizedBox(height: spacing),
          _GameButton(
            label: 'カルタ',
            icon: Icons.style,
            color: const Color(0xFFFFB74D),
            compact: compact,
            onTap: () => onComingSoon('カルタ'),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        '一般社団法人 ことばサポートネット',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool compact;
  final VoidCallback onTap;

  const _GameButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(compact ? 12 : 16),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: compact ? 12 : 18,
            horizontal: compact ? 16 : 24,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: compact ? 24 : 32),
              SizedBox(width: compact ? 12 : 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: compact ? 14 : 18),
            ],
          ),
        ),
      ),
    );
  }
}