import 'package:flutter/material.dart';

import '../../../../../view_model/utils/colors.dart';

class MyAccountsPage extends StatefulWidget {
  final String accountType; // "demo" or "live"

  const MyAccountsPage({Key? key, required this.accountType}) : super(key: key);

  @override
  State<MyAccountsPage> createState() => _MyAccountsPageState();
}

class _MyAccountsPageState extends State<MyAccountsPage> {
  late String selectedTab;
  bool isDemoExpanded = true;
  bool isLiveExpanded = true;

  // Demo account data
  final Map<String, dynamic> demoData = {
    'available': '\$93,893.37',
    'equity': '\$102,255.41',
    'pnl': '+\$49.33',
    'invested': '\$8,362.04',
    'pnlColor': AppColors.blueColor,
  };

  // Live account data
  final Map<String, dynamic> liveData = {
    'available': '\$45,231.89',
    'equity': '\$47,890.23',
    'pnl': '-\$125.67',
    'invested': '\$12,890.45',
    'pnlColor': AppColors.red,
  };

  @override
  void initState() {
    super.initState();
    selectedTab = widget.accountType.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My accounts',
          style: TextStyle(
            color: AppColors.yellow,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tab selector
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 'live'),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: selectedTab == 'live' ? AppColors.yellow : AppColors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            'Live',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: selectedTab == 'live' ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 'demo'),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: selectedTab == 'demo' ? AppColors.yellow : AppColors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            'Demo',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: selectedTab == 'demo' ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account card based on selected tab
            if (selectedTab == 'live')
              _buildAccountCard('Live', liveData, isLiveExpanded, (expanded) {
                setState(() {
                  isLiveExpanded = expanded;
                });
              })
            else
              _buildAccountCard('Demo', demoData, isDemoExpanded, (expanded) {
                setState(() {
                  isDemoExpanded = expanded;
                });
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(String accountType, Map<String, dynamic> data, bool isExpanded, Function(bool) onExpansionChanged) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            initiallyExpanded: isExpanded,
            onExpansionChanged: onExpansionChanged,
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            backgroundColor: AppColors.backgroundGrey2,
            collapsedBackgroundColor: AppColors.backgroundGrey2,
            iconColor: AppColors.lightGrey,
            collapsedIconColor: AppColors.lightGrey,
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$accountType - Account',
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Text(
                    //   'CFD',
                    //   style: TextStyle(
                    //     color: AppColors.greyText,
                    //     fontSize: 14,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.lightGrey,
                  size: 20,
                ),
              ],
            ),
            children: [
              Column(
                children: [
                  _buildAccountRow('Available', data['available']!),
                  const SizedBox(height: 16),
                  _buildAccountRow('Equity', data['equity']!),
                  const SizedBox(height: 16),
                  _buildAccountRow('P&L', data['pnl']!, textColor: data['pnlColor']),
                  const SizedBox(height: 16),
                  _buildAccountRow('Invested amount', data['invested']!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountRow(String label, String value, {Color? textColor}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.greyText,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        // Dotted line
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 1),
            painter: DottedLinePainter(color: AppColors.greyText),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: textColor ?? AppColors.yellow
            ,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 2.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Usage example:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => MyAccountsPage(accountType: 'demo'), // or 'live'
//   ),
// );