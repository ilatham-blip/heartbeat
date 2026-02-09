import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'app_layout.dart';
import 'user_login_page.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  String? _userId; // Store user ID from signup

  // Step 1: Account
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studyCodeController = TextEditingController();

  // Step 2: Demographics
  final _ageController = TextEditingController();
  String? _selectedGender;
  String? _selectedRace;

  // Step 3: Medical History
  final Set<String> _selectedComorbidities = {};
  final _medicationsController = TextEditingController();

  // Step 4: Lifestyle
  final _alcoholController = TextEditingController();
  final _exerciseController = TextEditingController();

  // Step 5: HADS Scores (set by HADSQuestionnaire)
  int _hadsAnxietyScore = 0;
  int _hadsDepressionScore = 0;

  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  final List<String> _raceOptions = [
    'White',
    'Black or African American',
    'Asian',
    'Hispanic or Latino',
    'Mixed/Multiple ethnic groups',
    'Other',
    'Prefer not to say'
  ];
  final List<String> _comorbidityOptions = [
    'Ehlers-Danlos Syndrome (EDS)',
    'Mast Cell Activation Syndrome (MCAS)',
    'Chronic Fatigue Syndrome',
    'Fibromyalgia',
    'Migraine',
    'Irritable Bowel Syndrome (IBS)',
    'Autoimmune Disorder',
    'Anxiety Disorder',
    'Depression',
    'None',
    'Other'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studyCodeController.dispose();
    _ageController.dispose();
    _medicationsController.dispose();
    _alcoholController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _createAccount() async {
    // Validate Step 1
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError('Please fill in email and password');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    if (_studyCodeController.text.trim().length != 6 ||
        !RegExp(r'^[0-9]{6}$').hasMatch(_studyCodeController.text.trim())) {
      _showError('Research study code must be exactly 6 digits');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verify study code exists
      final studyCheck = await Supabase.instance.client
          .from('research_studies')
          .select('study_code')
          .eq('study_code', _studyCodeController.text.trim())
          .maybeSingle();

      if (studyCheck == null) {
        _showError('Invalid research study code');
        setState(() => _isLoading = false);
        return;
      }

      // Create auth user
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        // Store user ID for later use (in case email confirmation is required)
        _userId = response.user!.id;
        _nextStep();
      } else {
        _showError('Failed to create account');
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error creating account: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      // Use stored user ID, or fall back to current session
      final userId = _userId ?? Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _showError('No user session found. Please try signing up again.');
        return;
      }

      final hadsTotal = _hadsAnxietyScore + _hadsDepressionScore;

      await Supabase.instance.client.from('user_profiles').upsert({
        'id': userId,
        'email': _emailController.text.trim(),
        'research_study_code': _studyCodeController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'gender': _selectedGender,
        'race': _selectedRace,
        'comorbidities': _selectedComorbidities.toList(),
        'medications': _medicationsController.text.trim().isEmpty
            ? null
            : _medicationsController.text.trim(),
        'avg_alcohol_units_weekly': int.tryParse(_alcoholController.text.trim()),
        'avg_exercise_mins_weekly': int.tryParse(_exerciseController.text.trim()),
        'hads_anxiety_score': _hadsAnxietyScore,
        'hads_depression_score': _hadsDepressionScore,
        'hads_total_score': hadsTotal,
      });

      if (mounted) {
        final appState = Provider.of<MyAppState>(context, listen: false);
        appState.changeIndex(0);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppLayout()),
        );
      }
    } catch (e) {
      _showError('Error saving profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF111827)),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    // If nothing to pop, replace with login page
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const UserLoginPage()),
                    );
                  }
                },
              ),
        title: Text(
          'Create Profile (${_currentStep + 1}/5)',
          style: const TextStyle(color: Color(0xFF111827)),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E40AF)),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAccountStep(),
                _buildDemographicsStep(),
                _buildMedicalHistoryStep(),
                _buildLifestyleStep(),
                _buildHADSStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ STEP 1: ACCOUNT ============
  Widget _buildAccountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildCard(
        title: 'Account Setup',
        subtitle: 'Create your secure account',
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: '••••••••',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _studyCodeController,
            label: 'Research Study Code',
            hint: '123456',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the 6-digit code provided by your research coordinator',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          _buildButton('Create Account', _isLoading ? null : _createAccount),
        ],
      ),
    );
  }

  // ============ STEP 2: DEMOGRAPHICS ============
  Widget _buildDemographicsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildCard(
        title: 'Demographics',
        subtitle: 'Help us understand your background',
        children: [
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            hint: 'Enter your age',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Gender',
            value: _selectedGender,
            items: _genderOptions,
            onChanged: (val) => setState(() => _selectedGender = val),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Race/Ethnicity',
            value: _selectedRace,
            items: _raceOptions,
            onChanged: (val) => setState(() => _selectedRace = val),
          ),
          const SizedBox(height: 24),
          _buildButton('Continue', _nextStep),
        ],
      ),
    );
  }

  // ============ STEP 3: MEDICAL HISTORY ============
  Widget _buildMedicalHistoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildCard(
        title: 'Medical History',
        subtitle: 'Select any conditions that apply',
        children: [
          const Text('Comorbidities', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _comorbidityOptions.map((condition) {
              final isSelected = _selectedComorbidities.contains(condition);
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedComorbidities.add(condition);
                    } else {
                      _selectedComorbidities.remove(condition);
                    }
                  });
                },
                selectedColor: const Color(0xFF1E40AF).withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _medicationsController,
            label: 'Current Medications',
            hint: 'List your current medications',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          _buildButton('Continue', _nextStep),
        ],
      ),
    );
  }

  // ============ STEP 4: LIFESTYLE ============
  Widget _buildLifestyleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildCard(
        title: 'Lifestyle Baseline',
        subtitle: 'Your typical weekly habits',
        children: [
          _buildTextField(
            controller: _alcoholController,
            label: 'Average Alcohol Units per Week',
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 8),
          const Text(
            '1 unit = half pint of beer, small glass of wine, or single measure of spirits',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _exerciseController,
            label: 'Average Exercise Minutes per Week',
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),
          _buildButton('Continue to Questionnaire', _nextStep),
        ],
      ),
    );
  }

  // ============ STEP 5: HADS ============
  Widget _buildHADSStep() {
    return HADSQuestionnaire(
      onComplete: (anxietyScore, depressionScore) {
        setState(() {
          _hadsAnxietyScore = anxietyScore;
          _hadsDepressionScore = depressionScore;
        });
        _saveProfile();
      },
      isLoading: _isLoading,
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _buildCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: Text('Select $label'),
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}

// ===================================================================
// HADS QUESTIONNAIRE WIDGET
// ===================================================================
class HADSQuestionnaire extends StatefulWidget {
  final Function(int anxietyScore, int depressionScore) onComplete;
  final bool isLoading;

  const HADSQuestionnaire({
    super.key,
    required this.onComplete,
    required this.isLoading,
  });

  @override
  State<HADSQuestionnaire> createState() => _HADSQuestionnaireState();
}

class _HADSQuestionnaireState extends State<HADSQuestionnaire> {
  final Map<int, int> _answers = {};

  // HADS Questions with options
  // isReversed means: Positive answer = 0, Negative = 3 (needs flipping for score)
  static const List<Map<String, dynamic>> _questions = [
    // Anxiety Questions (1-7)
    {
      'id': 1,
      'subscale': 'A',
      'question': 'I feel tense or "wound up"',
      'options': [
        {'text': 'Most of the time', 'value': 3},
        {'text': 'A lot of the time', 'value': 2},
        {'text': 'From time to time, occasionally', 'value': 1},
        {'text': 'Not at all', 'value': 0},
      ],
    },
    {
      'id': 2,
      'subscale': 'A',
      'question': 'I get a sort of frightened feeling as if something awful is about to happen',
      'options': [
        {'text': 'Very definitely and quite badly', 'value': 3},
        {'text': 'Yes, but not too badly', 'value': 2},
        {'text': 'A little, but it doesn\'t worry me', 'value': 1},
        {'text': 'Not at all', 'value': 0},
      ],
    },
    {
      'id': 3,
      'subscale': 'A',
      'question': 'Worrying thoughts go through my mind',
      'options': [
        {'text': 'A great deal of the time', 'value': 3},
        {'text': 'A lot of the time', 'value': 2},
        {'text': 'From time to time, but not too often', 'value': 1},
        {'text': 'Only occasionally', 'value': 0},
      ],
    },
    {
      'id': 4,
      'subscale': 'A',
      'question': 'I can sit at ease and feel relaxed',
      'options': [
        {'text': 'Definitely', 'value': 0},
        {'text': 'Usually', 'value': 1},
        {'text': 'Not often', 'value': 2},
        {'text': 'Not at all', 'value': 3},
      ],
    },
    {
      'id': 5,
      'subscale': 'A',
      'question': 'I get a sort of frightened feeling like "butterflies" in the stomach',
      'options': [
        {'text': 'Not at all', 'value': 0},
        {'text': 'Occasionally', 'value': 1},
        {'text': 'Quite often', 'value': 2},
        {'text': 'Very often', 'value': 3},
      ],
    },
    {
      'id': 6,
      'subscale': 'A',
      'question': 'I feel restless as if I have to be on the move',
      'options': [
        {'text': 'Very much indeed', 'value': 3},
        {'text': 'Quite a lot', 'value': 2},
        {'text': 'Not very much', 'value': 1},
        {'text': 'Not at all', 'value': 0},
      ],
    },
    {
      'id': 7,
      'subscale': 'A',
      'question': 'I get sudden feelings of panic',
      'options': [
        {'text': 'Very often indeed', 'value': 3},
        {'text': 'Quite often', 'value': 2},
        {'text': 'Not very often', 'value': 1},
        {'text': 'Not at all', 'value': 0},
      ],
    },
    // Depression Questions (8-14)
    {
      'id': 8,
      'subscale': 'D',
      'question': 'I still enjoy the things I used to enjoy',
      'options': [
        {'text': 'Definitely as much', 'value': 0},
        {'text': 'Not quite so much', 'value': 1},
        {'text': 'Only a little', 'value': 2},
        {'text': 'Hardly at all', 'value': 3},
      ],
    },
    {
      'id': 9,
      'subscale': 'D',
      'question': 'I can laugh and see the funny side of things',
      'options': [
        {'text': 'As much as I always could', 'value': 0},
        {'text': 'Not quite so much now', 'value': 1},
        {'text': 'Definitely not so much now', 'value': 2},
        {'text': 'Not at all', 'value': 3},
      ],
    },
    {
      'id': 10,
      'subscale': 'D',
      'question': 'I feel cheerful',
      'options': [
        {'text': 'Most of the time', 'value': 0},
        {'text': 'Sometimes', 'value': 1},
        {'text': 'Not often', 'value': 2},
        {'text': 'Not at all', 'value': 3},
      ],
    },
    {
      'id': 11,
      'subscale': 'D',
      'question': 'I feel as if I am slowed down',
      'options': [
        {'text': 'Nearly all the time', 'value': 3},
        {'text': 'Very often', 'value': 2},
        {'text': 'Sometimes', 'value': 1},
        {'text': 'Not at all', 'value': 0},
      ],
    },
    {
      'id': 12,
      'subscale': 'D',
      'question': 'I have lost interest in my appearance',
      'options': [
        {'text': 'Definitely', 'value': 3},
        {'text': 'I don\'t take as much care as I should', 'value': 2},
        {'text': 'I may not take quite as much care', 'value': 1},
        {'text': 'I take just as much care as ever', 'value': 0},
      ],
    },
    {
      'id': 13,
      'subscale': 'D',
      'question': 'I look forward with enjoyment to things',
      'options': [
        {'text': 'As much as I ever did', 'value': 0},
        {'text': 'Rather less than I used to', 'value': 1},
        {'text': 'Definitely less than I used to', 'value': 2},
        {'text': 'Hardly at all', 'value': 3},
      ],
    },
    {
      'id': 14,
      'subscale': 'D',
      'question': 'I can enjoy a good book or radio or TV program',
      'options': [
        {'text': 'Often', 'value': 0},
        {'text': 'Sometimes', 'value': 1},
        {'text': 'Not often', 'value': 2},
        {'text': 'Very seldom', 'value': 3},
      ],
    },
  ];

  int get _anxietyScore {
    int score = 0;
    for (var q in _questions.where((q) => q['subscale'] == 'A')) {
      score += _answers[q['id']] ?? 0;
    }
    return score;
  }

  int get _depressionScore {
    int score = 0;
    for (var q in _questions.where((q) => q['subscale'] == 'D')) {
      score += _answers[q['id']] ?? 0;
    }
    return score;
  }

  bool get _allAnswered => _answers.length == 14;

  String _getSeverityLabel(int score) {
    if (score <= 7) return 'Normal';
    if (score <= 10) return 'Borderline';
    return 'Abnormal';
  }

  Color _getSeverityColor(int score) {
    if (score <= 7) return Colors.green;
    if (score <= 10) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _questions.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader();
              }
              return _buildQuestionCard(_questions[index - 1]);
            },
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mental Health Assessment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hospital Anxiety and Depression Scale (HADS)\n\nPlease read each item and select the response which comes closest to how you have been feeling in the past week.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final int id = question['id'];
    final String subscale = question['subscale'] == 'A' ? 'Anxiety' : 'Depression';
    final List<Map<String, dynamic>> options = List<Map<String, dynamic>>.from(question['options']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: subscale == 'Anxiety'
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Q$id · $subscale',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subscale == 'Anxiety' ? Colors.purple : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question['question'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            final isSelected = _answers[id] == option['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _answers[id] = option['value'];
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E40AF).withOpacity(0.1)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E40AF) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1E40AF) : Colors.grey,
                          width: 2,
                        ),
                        color: isSelected ? const Color(0xFF1E40AF) : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option['text'],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF1E40AF) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_allAnswered) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreChip('Anxiety', _anxietyScore),
                _buildScoreChip('Depression', _depressionScore),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_answers.length}/14 answered',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: _allAnswered && !widget.isLoading
                    ? () => widget.onComplete(_anxietyScore, _depressionScore)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Complete Registration'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip(String label, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getSeverityColor(score).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getSeverityColor(score)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: $score/21',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _getSeverityColor(score),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(${_getSeverityLabel(score)})',
            style: TextStyle(
              fontSize: 12,
              color: _getSeverityColor(score),
            ),
          ),
        ],
      ),
    );
  }
}
