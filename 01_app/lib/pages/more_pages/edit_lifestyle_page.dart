import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditLifestylePage extends StatefulWidget {
  final int? currentAlcoholUnits;
  final int? currentExerciseMins;

  const EditLifestylePage({
    super.key,
    this.currentAlcoholUnits,
    this.currentExerciseMins,
  });

  @override
  State<EditLifestylePage> createState() => _EditLifestylePageState();
}

class _EditLifestylePageState extends State<EditLifestylePage> {
  late final TextEditingController _alcoholController;
  late final TextEditingController _exerciseController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _alcoholController =
        TextEditingController(text: widget.currentAlcoholUnits?.toString() ?? '');
    _exerciseController =
        TextEditingController(text: widget.currentExerciseMins?.toString() ?? '');
  }

  @override
  void dispose() {
    _alcoholController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user session');

      await Supabase.instance.client.from('user_profiles').update({
        'avg_alcohol_units_weekly':
            int.tryParse(_alcoholController.text.trim()),
        'avg_exercise_mins_weekly':
            int.tryParse(_exerciseController.text.trim()),
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lifestyle baseline updated'),
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
          'Edit Lifestyle Baseline',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
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
              const Text(
                'Lifestyle Baseline',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update your typical weekly habits',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _alcoholController,
                label: 'Average Alcohol Units per Week',
                hint: '0',
              ),
              const SizedBox(height: 8),
              const Text(
                '1 unit = half pint of beer, small glass of wine, or single measure of spirits',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _exerciseController,
                label: 'Average Exercise Minutes per Week',
                hint: '0',
              ),
              const SizedBox(height: 32),
              HeartbeatButton(
                label: 'Save Changes',
                onPressed: _isLoading ? null : _save,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
}
