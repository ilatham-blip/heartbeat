import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  bool _isExporting = false;
  String? _exportingType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Export My Data",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Export Options
            _buildSection(
              title: 'Available Exports',
              icon: Icons.folder_open,
              iconColor: kBrandBlue,
              children: [
                _buildExportOption(
                  icon: Icons.person,
                  iconColor: Colors.blue,
                  title: 'Profile Data',
                  description: 'Your demographics, medical history, and baseline data',
                  dataType: 'profile',
                ),
                const Divider(height: 1),
                _buildExportOption(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  title: 'Daily Check-ins',
                  description: 'Morning and evening symptom logs',
                  dataType: 'checkins',
                ),
                const Divider(height: 1),
                _buildExportOption(
                  icon: Icons.restaurant,
                  iconColor: Colors.orange,
                  title: 'Lifestyle Logs',
                  description: 'Exercise, diet, and trigger tracking',
                  dataType: 'lifestyle',
                ),
                const Divider(height: 1),
                _buildExportOption(
                  icon: Icons.warning_amber,
                  iconColor: Colors.red,
                  title: 'POTS Episodes',
                  description: 'Recorded symptom flare-ups',
                  dataType: 'episodes',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Export All
            _buildSection(
              title: 'Complete Export',
              icon: Icons.download,
              iconColor: Colors.purple,
              children: [
                _buildExportAllOption(),
              ],
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Data Rights (GDPR)',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You have the right to access and download all data we hold about you. Exports are in JSON format for portability.',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_download, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Download Your Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Export your health data anytime',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String dataType,
  }) {
    final isExporting = _isExporting && _exportingType == dataType;

    return InkWell(
      onTap: isExporting ? null : () => _exportData(dataType, title),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isExporting)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kBrandBlue.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, size: 16, color: kBrandBlue),
                    const SizedBox(width: 4),
                    Text(
                      'Export',
                      style: TextStyle(
                        color: kBrandBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportAllOption() {
    final isExporting = _isExporting && _exportingType == 'all';

    return InkWell(
      onTap: isExporting ? null : () => _exportData('all', 'All Data'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.all_inbox, color: Colors.purple, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export All My Data',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Download everything in a single file',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isExporting)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Export All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(String dataType, String title) async {
    setState(() {
      _isExporting = true;
      _exportingType = dataType;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showError('No user logged in');
        return;
      }

      Map<String, dynamic> exportData = {};

      if (dataType == 'all' || dataType == 'profile') {
        final profile = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        exportData['profile'] = profile;
      }

      if (dataType == 'all' || dataType == 'checkins') {
        final checkins = await Supabase.instance.client
            .from('daily_checkins')
            .select()
            .eq('user_id', user.id)
            .order('date', ascending: false);
        exportData['daily_checkins'] = checkins;
      }

      if (dataType == 'all' || dataType == 'lifestyle') {
        final lifestyle = await Supabase.instance.client
            .from('lifestyle_logs')
            .select()
            .eq('user_id', user.id)
            .order('date', ascending: false);
        exportData['lifestyle_logs'] = lifestyle;
      }

      if (dataType == 'all' || dataType == 'episodes') {
        final episodes = await Supabase.instance.client
            .from('pots_episodes')
            .select()
            .eq('user_id', user.id)
            .order('recorded_at', ascending: false);
        exportData['pots_episodes'] = episodes;
      }



      // Show export result
      if (mounted) {
        _showExportResult(title, exportData);
      }
    } catch (e) {
      _showError('Export failed: $e');
    } finally {
      setState(() {
        _isExporting = false;
        _exportingType = null;
      });
    }
  }

  void _showExportResult(String title, Map<String, dynamic> data) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final recordCount = _countRecords(data);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$title Exported',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$recordCount records found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // In production, implement share/save functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share functionality would be here')),
                          );
                        },
                        icon: Icon(Icons.share, color: kBrandBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFF1E1E1E),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    SelectableText(
                      jsonString,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countRecords(Map<String, dynamic> data) {
    int count = 0;
    for (var value in data.values) {
      if (value is List) {
        count += value.length;
      } else if (value != null) {
        count += 1;
      }
    }
    return count;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}