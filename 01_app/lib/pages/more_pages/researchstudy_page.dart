import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const kCardPurple = Color(0xFF7C3AED);

class ResearchStudyPage extends StatefulWidget {
  const ResearchStudyPage({super.key});

  @override
  State<ResearchStudyPage> createState() => _ResearchStudyPageState();
}

class _ResearchStudyPageState extends State<ResearchStudyPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _study;
  String? _studyCode;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStudyInfo();
  }

  Future<void> _fetchStudyInfo() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      // First, get the user's study code from their profile
      final profileResponse = await Supabase.instance.client
          .from('user_profiles')
          .select('research_study_code')
          .eq('id', user.id)
          .single();

      final studyCode = profileResponse['research_study_code'];
      if (studyCode == null) {
        setState(() {
          _errorMessage = 'You are not enrolled in any research study';
          _isLoading = false;
        });
        return;
      }

      _studyCode = studyCode;

      // Now fetch the study details
      final studyResponse = await Supabase.instance.client
          .from('research_studies')
          .select()
          .eq('study_code', studyCode)
          .single();

      setState(() {
        _study = studyResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading study info: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Research Study",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _fetchStudyInfo();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kCardPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildStudyContent(),
    );
  }

  Widget _buildStudyContent() {
    if (_study == null) {
      return const Center(child: Text('No study data found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study Header Card
          _buildStudyHeader(),
          const SizedBox(height: 24),

          // Study Status
          _buildStatusBadge(),
          const SizedBox(height: 24),

          // Study Description
          _buildSection(
            title: 'About This Study',
            icon: Icons.description_outlined,
            iconColor: kCardPurple,
            child: Text(
              _study!['description'] ?? 'No description available.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Principal Investigators
          _buildSection(
            title: 'Principal Investigators',
            icon: Icons.people_outline,
            iconColor: Colors.blue,
            child: _buildInvestigatorsList(),
          ),
          const SizedBox(height: 16),

          // Organization & Contact
          _buildSection(
            title: 'Organization & Contact',
            icon: Icons.business_outlined,
            iconColor: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.apartment,
                  'Organization',
                  _study!['affiliated_organization'] ?? 'Not specified',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.email_outlined,
                  'Contact Email',
                  _study!['contact_email'] ?? 'Not available',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Study Details
          _buildSection(
            title: 'Study Details',
            icon: Icons.info_outline,
            iconColor: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.qr_code,
                  'Study Code',
                  _studyCode ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.verified_outlined,
                  'Ethics Approval',
                  _study!['ethics_approval_id'] ?? 'Not available',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Start Date',
                  _formatDate(_study!['start_date']),
                ),
                if (_study!['end_date'] != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.event_outlined,
                    'End Date',
                    _formatDate(_study!['end_date']),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Thank You Message
          _buildThankYouCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStudyHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kCardPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.science,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _study!['title'] ?? 'Research Study',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Study Code: ${_studyCode ?? "N/A"}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = _study!['status'] ?? 'unknown';
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'recruiting':
        statusColor = Colors.green;
        statusText = 'Actively Recruiting';
        statusIcon = Icons.person_add_outlined;
        break;
      case 'active':
        statusColor = Colors.blue;
        statusText = 'Active';
        statusIcon = Icons.play_circle_outline;
        break;
      case 'completed':
        statusColor = Colors.purple;
        statusText = 'Completed';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'closed':
        statusColor = Colors.grey;
        statusText = 'Closed';
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Status: $statusText',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
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
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                    color: iconColor.withOpacity(0.1),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigatorsList() {
    final investigators = _study!['principal_investigators'];
    if (investigators == null || (investigators is List && investigators.isEmpty)) {
      return Text(
        'Not specified',
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      );
    }

    if (investigators is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: investigators.map((name) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  name.toString(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Text(
      investigators.toString(),
      style: TextStyle(color: Colors.grey[700], fontSize: 14),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThankYouCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.teal.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thank You for Participating!',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your contribution helps advance medical research and improve patient care.',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not specified';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}