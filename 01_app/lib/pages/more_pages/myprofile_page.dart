import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const kBrandBlue = Color(0xFF1E40AF);
const kBackgroundWhite = Color(0xFFFAFAFA);

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        _profile = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundWhite,
      appBar: AppBar(
        title: const Text(
          "My Profile",
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _fetchProfile();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_profile == null) {
      return const Center(child: Text('No profile data found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(),
          const SizedBox(height: 24),

          // Demographics Section
          _buildSection(
            title: 'Demographics',
            icon: Icons.person_outline,
            iconColor: kBrandBlue,
            children: [
              _buildInfoRow('Age', _profile!['age']?.toString() ?? 'Not specified'),
              _buildInfoRow('Gender', _profile!['gender'] ?? 'Not specified'),
              _buildInfoRow('Race/Ethnicity', _profile!['race'] ?? 'Not specified'),
            ],
          ),
          const SizedBox(height: 16),

          // Medical History Section
          _buildSection(
            title: 'Medical History',
            icon: Icons.medical_services_outlined,
            iconColor: Colors.red,
            children: [
              _buildInfoRow(
                'Comorbidities',
                _formatComorbidities(_profile!['comorbidities']),
              ),
              _buildInfoRow(
                'Medications',
                _profile!['medications']?.isNotEmpty == true
                    ? _profile!['medications']
                    : 'None specified',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lifestyle Section
          _buildSection(
            title: 'Lifestyle Baseline',
            icon: Icons.fitness_center_outlined,
            iconColor: Colors.green,
            children: [
              _buildInfoRow(
                'Alcohol (units/week)',
                _profile!['avg_alcohol_units_weekly']?.toString() ?? 'Not specified',
              ),
              _buildInfoRow(
                'Exercise (mins/week)',
                _profile!['avg_exercise_mins_weekly']?.toString() ?? 'Not specified',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // HADS Scores Section
          _buildSection(
            title: 'Mental Health Baseline (HADS)',
            icon: Icons.psychology_outlined,
            iconColor: Colors.purple,
            children: [
              _buildHADSScoreRow(
                'Anxiety Score',
                _profile!['hads_anxiety_score'],
              ),
              _buildHADSScoreRow(
                'Depression Score',
                _profile!['hads_depression_score'],
              ),
              _buildHADSScoreRow(
                'Total Score',
                _profile!['hads_total_score'],
                isTotal: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Research Study Section
          _buildSection(
            title: 'Research Study',
            icon: Icons.science_outlined,
            iconColor: Colors.orange,
            children: [
              _buildInfoRow(
                'Study Code',
                _profile!['research_study_code'] ?? 'Not enrolled',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account Info
          _buildSection(
            title: 'Account Info',
            icon: Icons.email_outlined,
            iconColor: Colors.teal,
            children: [
              _buildInfoRow('Email', _profile!['email'] ?? 'Not available'),
              _buildInfoRow(
                'Member Since',
                _formatDate(_profile!['created_at']),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 48),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile!['email'] ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_profile!['age'] ?? '?'} years old • ${_profile!['gender'] ?? 'Not specified'}',
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
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHADSScoreRow(String label, int? score, {bool isTotal = false}) {
    String severityLabel;
    Color severityColor;

    if (score == null) {
      severityLabel = 'Not completed';
      severityColor = Colors.grey;
    } else if (isTotal) {
      // Total score interpretation (0-42)
      if (score <= 14) {
        severityLabel = 'Normal';
        severityColor = Colors.green;
      } else if (score <= 20) {
        severityLabel = 'Borderline';
        severityColor = Colors.orange;
      } else {
        severityLabel = 'Abnormal';
        severityColor = Colors.red;
      }
    } else {
      // Individual subscale interpretation (0-21)
      if (score <= 7) {
        severityLabel = 'Normal';
        severityColor = Colors.green;
      } else if (score <= 10) {
        severityLabel = 'Borderline';
        severityColor = Colors.orange;
      } else {
        severityLabel = 'Abnormal';
        severityColor = Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(
                  score?.toString() ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (score != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      severityLabel,
                      style: TextStyle(
                        color: severityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatComorbidities(dynamic comorbidities) {
    if (comorbidities == null) return 'None specified';
    if (comorbidities is List) {
      if (comorbidities.isEmpty) return 'None specified';
      return comorbidities.join(', ');
    }
    return 'None specified';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}