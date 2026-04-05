import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  int? _year;
  String? _branch;
  bool _saving = false;

  final _years = ['1st year', '2nd year', '3rd year', '4th year'];
  final _branches = ['CS', 'IT', 'Mech', 'Civil', 'ENTC', 'EE', 'Chem', 'Other'];

  String _yearLabel(int y) {
    const labels = ['1st', '2nd', '3rd', '4th'];
    return labels[y - 1];
  }

  Future<void> _save() async {
    if (_year == null || _branch == null) return;
    setState(() => _saving = true);
    try {
      final currentUser = Supabase.instance.client.auth.currentUser!;
      final tag = '${_yearLabel(_year!)} Year $_branch';
      await Supabase.instance.client.from('users').upsert({
        'id': currentUser.id,
        'email': currentUser.email ?? '',
        'year': _year,
        'branch': _branch,
        'display_tag': tag,
        'onboarding_complete': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/wiki');
        }
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Progress dots
              Row(
                children: List.generate(3, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  width: _step == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _step == i ? AppTheme.accent : AppTheme.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
              const SizedBox(height: 28),

              // Step icon
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Icon(
                  _step == 0 ? Icons.school_rounded : Icons.account_tree_rounded,
                  color: AppTheme.accent, size: 24,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                _step == 0 ? 'Which year are you in?' : 'What is your branch?',
                style: AppText.h2,
              ),
              const SizedBox(height: 6),
              Text(
                _step == 0
                    ? "We'll personalise your feed and wiki content based on your year."
                    : "Branch-specific questions and guides will appear first for you.",
                style: AppText.bodySmall,
              ),
              const SizedBox(height: 24),

              // Chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: (_step == 0 ? _years : _branches).asMap().entries.map((e) {
                  final val = _step == 0 ? (e.key + 1) : e.value;
                  final selected = _step == 0 ? _year == val : _branch == val;
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (_step == 0) {
                        _year = val as int;
                      } else {
                        _branch = val as String;
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.accent : AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppTheme.accent : AppTheme.border,
                          width: selected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(
                        _step == 0 ? e.value : e.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Preview card (step 0 only)
              if (_step == 0 && _year != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What you\'ll see as a ${_yearLabel(_year!)} year', style: AppText.label),
                      const SizedBox(height: 10),
                      ..._previewItems(_year!).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(item, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Continue button
              _saving
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : ElevatedButton(
                      onPressed: (_step == 0 ? _year : _branch) != null
                          ? () {
                              if (_step == 0) {
                                setState(() => _step = 1);
                              } else {
                                _save();
                              }
                            }
                          : null,
                      child: Text(_step < 1 ? 'Continue' : 'Get started'),
                    ),
              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/wiki');
                    }
                  },
                  child: const Text("I'll set this later — Skip", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _previewItems(int year) {
    switch (year) {
      case 1: return ['Orientation & hostel guides', 'Basic campus navigation', '1st year common Q&A'];
      case 2: return ['Mid-semester exam guides', 'Internship prep resources', '2nd year Q&A questions'];
      case 3: return ['Placement readiness guides', 'Core subject resources', '3rd year Q&A feed'];
      case 4: return ['Final year project tips', 'Placement drive updates', 'Alumni advice Q&A'];
      default: return [];
    }
  }
}
