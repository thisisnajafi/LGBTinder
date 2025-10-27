import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/haptic_feedback_service.dart';
import '../../providers/theme_provider.dart';

class WizardStep {
  final String id;
  final String title;
  final String description;
  final Widget content;
  final bool isRequired;
  final bool isSkippable;
  final String? skipReason;
  final VoidCallback? onSkip;
  final Function(dynamic)? onComplete;

  const WizardStep({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.isRequired = true,
    this.isSkippable = false,
    this.skipReason,
    this.onSkip,
    this.onComplete,
  });
}

class WizardCustomization {
  final bool allowSkipping;
  final bool showProgress;
  final bool showStepNumbers;
  final bool allowBackNavigation;
  final bool showSkipButton;
  final bool showSkipConfirmation;
  final String? skipConfirmationMessage;
  final Duration animationDuration;
  final Curve animationCurve;

  const WizardCustomization({
    this.allowSkipping = true,
    this.showProgress = true,
    this.showStepNumbers = true,
    this.allowBackNavigation = true,
    this.showSkipButton = true,
    this.showSkipConfirmation = true,
    this.skipConfirmationMessage,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });
}

class CustomizableWizard extends StatefulWidget {
  final List<WizardStep> steps;
  final WizardCustomization customization;
  final Function(int currentStep, int totalSteps)? onStepChanged;
  final Function(List<String> skippedSteps)? onWizardComplete;
  final VoidCallback? onWizardCancel;

  const CustomizableWizard({
    Key? key,
    required this.steps,
    this.customization = const WizardCustomization(),
    this.onStepChanged,
    this.onWizardComplete,
    this.onWizardCancel,
  }) : super(key: key);

  @override
  State<CustomizableWizard> createState() => _CustomizableWizardState();
}

class _CustomizableWizardState extends State<CustomizableWizard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  int _currentStepIndex = 0;
  List<String> _skippedSteps = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.customization.animationDuration,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: widget.customization.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.customization.animationCurve,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: widget.customization.animationCurve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[_currentStepIndex];
    final isLastStep = _currentStepIndex == widget.steps.length - 1;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode 
              ? AppColors.backgroundDark 
              : AppColors.background,
          appBar: _buildAppBar(currentStep, themeProvider),
          body: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value * 100),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      if (widget.customization.showProgress) _buildProgressIndicator(themeProvider),
                      Expanded(
                        child: _buildStepContent(currentStep, themeProvider),
                      ),
                      _buildNavigationButtons(currentStep, isLastStep, themeProvider),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(WizardStep currentStep, ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.isDarkMode 
          ? AppColors.navbarBackground 
          : AppColors.background,
      elevation: 0,
      leading: widget.customization.allowBackNavigation && _currentStepIndex > 0
          ? IconButton(
              icon: Icon(
                Icons.arrow_back, 
                color: themeProvider.isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimary,
              ),
              onPressed: _goToPreviousStep,
            )
          : IconButton(
              icon: Icon(
                Icons.close, 
                color: themeProvider.isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimary,
              ),
              onPressed: () {
                HapticFeedbackService.selection();
                widget.onWizardCancel?.call();
              },
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentStep.title,
            style: AppTypography.titleLarge.copyWith(
              color: themeProvider.isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.customization.showStepNumbers)
            Text(
              'Step ${_currentStepIndex + 1} of ${widget.steps.length}',
              style: AppTypography.bodyMedium.copyWith(
                color: themeProvider.isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: [
        if (widget.customization.showSkipButton && 
            currentStep.isSkippable && 
            !currentStep.isRequired)
          TextButton(
            onPressed: () => _showSkipConfirmation(currentStep),
            child: Text(
              'Skip',
              style: TextStyle(
                color: themeProvider.isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  color: themeProvider.isDarkMode 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentStepIndex + 1) / widget.steps.length * 100).round()}%',
                style: TextStyle(
                  color: themeProvider.isDarkMode 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentStepIndex + 1) / widget.steps.length,
            backgroundColor: themeProvider.isDarkMode 
                ? AppColors.surfaceSecondary 
                : AppColors.surfaceSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(WizardStep currentStep, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentStep.description,
            style: AppTypography.bodyLarge.copyWith(
              color: themeProvider.isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          currentStep.content,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(WizardStep currentStep, bool isLastStep, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (widget.customization.allowBackNavigation && _currentStepIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isAnimating ? null : _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: themeProvider.isDarkMode 
                        ? AppColors.borderDefault 
                        : AppColors.borderDefault,
                  ),
                  foregroundColor: themeProvider.isDarkMode 
                      ? AppColors.textPrimaryDark 
                      : AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (widget.customization.allowBackNavigation && _currentStepIndex > 0)
            const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isAnimating ? null : () => _goToNextStep(isLastStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isLastStep ? 'Complete' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousStep() {
    if (_isAnimating) return;

    setState(() {
      _currentStepIndex--;
      _isAnimating = true;
    });

    _animateTransition(() {
      setState(() {
        _isAnimating = false;
      });
    });

    widget.onStepChanged?.call(_currentStepIndex, widget.steps.length);
    HapticFeedbackService.selection();
  }

  void _goToNextStep(bool isLastStep) {
    if (_isAnimating) return;

    if (isLastStep) {
      _completeWizard();
    } else {
      setState(() {
        _currentStepIndex++;
        _isAnimating = true;
      });

      _animateTransition(() {
        setState(() {
          _isAnimating = false;
        });
      });

      widget.onStepChanged?.call(_currentStepIndex, widget.steps.length);
    }

    HapticFeedbackService.selection();
  }

  void _animateTransition(VoidCallback onComplete) {
    _controller.reverse().then((_) {
      _slideController.forward().then((_) {
        _slideController.reverse().then((_) {
          _controller.forward().then((_) {
            onComplete();
          });
        });
      });
    });
  }

  void _showSkipConfirmation(WizardStep step) {
    final message = step.skipReason ?? 
        widget.customization.skipConfirmationMessage ?? 
        'Are you sure you want to skip this step?';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Skip Step',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _skipStep(step);
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: AppColors.feedbackWarning),
            ),
          ),
        ],
      ),
    );
  }

  void _skipStep(WizardStep step) {
    setState(() {
      _skippedSteps.add(step.id);
    });

    step.onSkip?.call();

    if (_currentStepIndex < widget.steps.length - 1) {
      _goToNextStep(false);
    } else {
      _completeWizard();
    }

    HapticFeedbackService.selection();
  }

  void _completeWizard() {
    widget.onWizardComplete?.call(_skippedSteps);
    HapticFeedbackService.success();
  }
}

class WizardStepBuilder extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final bool isRequired;
  final bool isSkippable;
  final String? skipReason;

  const WizardStepBuilder({
    Key? key,
    required this.title,
    required this.description,
    required this.child,
    this.isRequired = true,
    this.isSkippable = false,
    this.skipReason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

class WizardCustomizationScreen extends StatefulWidget {
  final WizardCustomization initialCustomization;
  final Function(WizardCustomization)? onCustomizationChanged;

  const WizardCustomizationScreen({
    Key? key,
    required this.initialCustomization,
    this.onCustomizationChanged,
  }) : super(key: key);

  @override
  State<WizardCustomizationScreen> createState() => _WizardCustomizationScreenState();
}

class _WizardCustomizationScreenState extends State<WizardCustomizationScreen> {
  late WizardCustomization _customization;

  @override
  void initState() {
    super.initState();
    _customization = widget.initialCustomization;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () {
            HapticFeedbackService.selection();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Wizard Customization',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Navigation Options',
              children: [
                _buildSwitchTile(
                  title: 'Allow Skipping Steps',
                  subtitle: 'Let users skip optional steps',
                  value: _customization.allowSkipping,
                  onChanged: (value) {
                    setState(() {
                      _customization = _customization.copyWith(allowSkipping: value);
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Allow Back Navigation',
                  subtitle: 'Let users go back to previous steps',
                  value: _customization.allowBackNavigation,
                  onChanged: (value) {
                    setState(() {
                      _customization = _customization.copyWith(allowBackNavigation: value);
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Show Skip Button',
                  subtitle: 'Display skip button for optional steps',
                  value: _customization.showSkipButton,
                  onChanged: (value) {
                    setState(() {
                      _customization = _customization.copyWith(showSkipButton: value);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Display Options',
              children: [
                _buildSwitchTile(
                  title: 'Show Progress Indicator',
                  subtitle: 'Display progress bar and percentage',
                  value: _customization.showProgress,
                  onChanged: (value) {
                    setState(() {
                      _customization = _customization.copyWith(showProgress: value);
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Show Step Numbers',
                  subtitle: 'Display step numbers in header',
                  value: _customization.showStepNumbers,
                  onChanged: (value) {
                    setState(() {
                      _customization = _customization.copyWith(showStepNumbers: value);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Confirmation Options',
              children: [
                _buildSwitchTile(
                  title: 'Show Skip Confirmation',
                  subtitle: 'Ask for confirmation before skipping steps',
                  value: _customization.showSkipConfirmation,
                  onChanged: (value) {
                    setState(() {
                      _customization = _customization.copyWith(showSkipConfirmation: value);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
          style: TextStyle(color: AppColors.textPrimaryDark),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondaryDark),
      ),
      value: value,
      onChanged: (newValue) {
        HapticFeedbackService.selection();
        onChanged(newValue);
      },
      activeColor: AppColors.primaryLight,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _customization = widget.initialCustomization;
              });
              HapticFeedbackService.selection();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.borderDefault),
              foregroundColor: AppColors.textPrimaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onCustomizationChanged?.call(_customization);
              HapticFeedbackService.success();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

extension WizardCustomizationExtension on WizardCustomization {
  WizardCustomization copyWith({
    bool? allowSkipping,
    bool? showProgress,
    bool? showStepNumbers,
    bool? allowBackNavigation,
    bool? showSkipButton,
    bool? showSkipConfirmation,
    String? skipConfirmationMessage,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return WizardCustomization(
      allowSkipping: allowSkipping ?? this.allowSkipping,
      showProgress: showProgress ?? this.showProgress,
      showStepNumbers: showStepNumbers ?? this.showStepNumbers,
      allowBackNavigation: allowBackNavigation ?? this.allowBackNavigation,
      showSkipButton: showSkipButton ?? this.showSkipButton,
      showSkipConfirmation: showSkipConfirmation ?? this.showSkipConfirmation,
      skipConfirmationMessage: skipConfirmationMessage ?? this.skipConfirmationMessage,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}
