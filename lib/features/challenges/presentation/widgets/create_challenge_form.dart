import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Provider and Entities
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/challenge_provider.dart';

// The individual pages of our builder
import 'creation_steps/step_1_title_page.dart';
import 'creation_steps/step_2_description_page.dart';
import 'creation_steps/step_3_categories_page.dart';
import 'creation_steps/step_4_tasks_page.dart';
import 'creation_steps/step_5_preview_page.dart';

/// This widget is the "builder" or "wizard" for challenge creation.
/// It uses a PageView to guide the user through the individual steps.
class CreateChallengeForm extends StatefulWidget {
  const CreateChallengeForm({super.key});

  @override
  State<CreateChallengeForm> createState() => _CreateChallengeFormState();
}

class _CreateChallengeFormState extends State<CreateChallengeForm> {
  final List<Widget> _pages = [
    const Step1TitlePage(),
    const Step2DescriptionPage(),
    const Step3CategoriesPage(),
    const Step4TasksPage(),
    const Step5PreviewPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authorId = context.read<AuthenticationProvider>().currentUserId;
      if (authorId != null) {
        context.read<ChallengeProvider>().startChallengeCreation(authorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final theme = Theme.of(context);

    // Show a loading circle until the builder is initialized
    if (provider.challengeInProgress == null || provider.pageController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isLastPage = provider.currentPage == _pages.length - 1;

    return Column(
      children: [
        // 1. A progress indicator that visualizes the current step
        LinearProgressIndicator(
          value: (provider.currentPage + 1) / _pages.length,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),

        // 2. The PageView that occupies most of the screen
        Expanded(
          child: PageView.builder(
            controller: provider.pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swiping
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
        ),

        // 3. A fixed navigation bar at the bottom
        _buildBottomNavigationBar(context, provider, isLastPage),
      ],
    );
  }

  /// Builds the navigation bar at the bottom of the screen.
  Widget _buildBottomNavigationBar(BuildContext context, ChallengeProvider provider, bool isLastPage) {
    // Validation for the "Next" or "Publish" button
    bool canProceed = false;
    final challenge = provider.challengeInProgress;
    if (challenge != null) {
      switch (provider.currentPage) {
        case 0: // Title
          canProceed = challenge.title.isNotEmpty;
          break;
        case 1: // Description
          canProceed = challenge.description.isNotEmpty;
          break;
        case 2: // Categories
          canProceed = challenge.categories.isNotEmpty;
          break;
        case 3: // Tasks
          canProceed = challenge.tasks.isNotEmpty;
          break;
        case 4: // Preview
          canProceed = true; // On the preview page, you can always publish
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "Back" button (only visible from the second page)
          if (provider.currentPage > 0)
            TextButton(
              onPressed: () => provider.previousPage(),
              child: const Text('Back'),
            )
          else
            const SizedBox(), // Empty placeholder so the "Next" button stays on the right

          // The final button: "Next" or "Publish"
          ElevatedButton.icon(
            icon: provider.isCreatingChallenge
                ? Container()
                : Icon(isLastPage ? Iconsax.send_1 : Icons.arrow_forward_ios_rounded, size: 18),
            label: provider.isCreatingChallenge
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isLastPage ? 'Publish' : 'Next'),
            onPressed: canProceed && !provider.isCreatingChallenge
                ? () async {
              if (isLastPage) {
                final newId = await provider.saveChallenge();
                if (!context.mounted) return;

                if (newId != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Challenge successfully created!')),
                  );
                  Navigator.of(context).pop();
                }
              } else {
                provider.nextPage();
              }
            }
                : null,
          ),
        ],
      ),
    );
  }
}