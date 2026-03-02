import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:heartbeat/pages/create_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditHADSPage extends StatefulWidget {
  const EditHADSPage({super.key});

  @override
  State<EditHADSPage> createState() => _EditHADSPageState();
}

class _EditHADSPageState extends State<EditHADSPage> {
  bool _isLoading = false;

  Future<void> _saveScores(int anxietyScore, int depressionScore) async {
    // Confirm before overwriting
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update HADS Scores?'),
        content: const Text(
          'This will overwrite your existing mental health baseline scores. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user session');

      final total = anxietyScore + depressionScore;

      await Supabase.instance.client.from('user_profiles').update({
        'hads_anxiety_score': anxietyScore,
        'hads_depression_score': depressionScore,
        'hads_total_score': total,
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HADS scores updated'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // true = data changed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Update HADS Questionnaire',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: HADSQuestionnaire(
        onComplete: _saveScores,
        isLoading: _isLoading,
      ),
    );
  }
}
