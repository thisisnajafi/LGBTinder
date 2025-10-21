import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/audio_recorder_service.dart';
import '../utils/haptic_feedback_service.dart';

class AudioRecorderSettingsScreen extends StatefulWidget {
  const AudioRecorderSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AudioRecorderSettingsScreen> createState() => _AudioRecorderSettingsScreenState();
}

class _AudioRecorderSettingsScreenState extends State<AudioRecorderSettingsScreen> {
  // Audio quality settings
  int _selectedBitRate = 128000;
  int _selectedSampleRate = 44100;
  String _selectedEncoder = 'aacLc';
  
  // Recording settings
  bool _autoStopEnabled = true;
  int _maxRecordingDuration = 300; // 5 minutes
  bool _noiseReductionEnabled = true;
  bool _echoCancellationEnabled = true;
  
  // UI settings
  bool _showWaveform = true;
  bool _hapticFeedbackEnabled = true;
  bool _soundEffectsEnabled = true;
  
  // Test recording
  bool _isTestRecording = false;
  String _testRecordingPath = '';
  Duration _testRecordingDuration = Duration.zero;

  final List<int> _bitRates = [64000, 128000, 192000, 256000, 320000];
  final List<int> _sampleRates = [22050, 44100, 48000, 96000];
  final List<String> _encoders = ['aacLc', 'aacEld', 'opus', 'flac'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedBitRate = prefs.getInt('audio_bitrate') ?? 128000;
      _selectedSampleRate = prefs.getInt('audio_sample_rate') ?? 44100;
      _selectedEncoder = prefs.getString('audio_encoder') ?? 'aacLc';
      _autoStopEnabled = prefs.getBool('audio_auto_stop') ?? true;
      _maxRecordingDuration = prefs.getInt('audio_max_duration') ?? 300;
      _noiseReductionEnabled = prefs.getBool('audio_noise_reduction') ?? true;
      _echoCancellationEnabled = prefs.getBool('audio_echo_cancellation') ?? true;
      _showWaveform = prefs.getBool('audio_show_waveform') ?? true;
      _hapticFeedbackEnabled = prefs.getBool('audio_haptic_feedback') ?? true;
      _soundEffectsEnabled = prefs.getBool('audio_sound_effects') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('audio_bitrate', _selectedBitRate);
    await prefs.setInt('audio_sample_rate', _selectedSampleRate);
    await prefs.setString('audio_encoder', _selectedEncoder);
    await prefs.setBool('audio_auto_stop', _autoStopEnabled);
    await prefs.setInt('audio_max_duration', _maxRecordingDuration);
    await prefs.setBool('audio_noise_reduction', _noiseReductionEnabled);
    await prefs.setBool('audio_echo_cancellation', _echoCancellationEnabled);
    await prefs.setBool('audio_show_waveform', _showWaveform);
    await prefs.setBool('audio_haptic_feedback', _hapticFeedbackEnabled);
    await prefs.setBool('audio_sound_effects', _soundEffectsEnabled);
  }

  Future<void> _startTestRecording() async {
    if (_isTestRecording) return;
    
    setState(() {
      _isTestRecording = true;
      _testRecordingDuration = Duration.zero;
    });

    HapticFeedbackService.lightImpact();

    final success = await AudioRecorderService.startRecording();
    if (success) {
      _testRecordingPath = AudioRecorderService.recordingPath ?? '';
      
      // Start duration timer
      _startDurationTimer();
    } else {
      setState(() {
        _isTestRecording = false;
      });
      _showErrorSnackBar('Failed to start test recording');
    }
  }

  Future<void> _stopTestRecording() async {
    if (!_isTestRecording) return;
    
    final path = await AudioRecorderService.stopRecording();
    setState(() {
      _isTestRecording = false;
      _testRecordingPath = path ?? '';
    });

    HapticFeedbackService.mediumImpact();
    _showSuccessSnackBar('Test recording completed');
  }

  void _startDurationTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (_isTestRecording) {
        setState(() {
          _testRecordingDuration = Duration(seconds: _testRecordingDuration.inSeconds + 1);
        });
        _startDurationTimer();
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Audio Recorder Settings'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await _saveSettings();
              _showSuccessSnackBar('Settings saved successfully');
            },
            child: Text(
              'Save',
              style: AppTypography.bodyMediumStyle.copyWith(
                color: AppColors.primaryLight,
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Audio Quality'),
            _buildSettingsCard([
              _buildDropdownSetting(
                'Bit Rate',
                'Higher bit rate = better quality, larger file size',
                _selectedBitRate.toString(),
                _bitRates.map((rate) => '${rate ~/ 1000} kbps').toList(),
                (value) {
                  setState(() {
                    _selectedBitRate = _bitRates[value];
                  });
                },
              ),
              _buildDropdownSetting(
                'Sample Rate',
                'Higher sample rate = better audio fidelity',
                '${_selectedSampleRate} Hz',
                _sampleRates.map((rate) => '${rate} Hz').toList(),
                (value) {
                  setState(() {
                    _selectedSampleRate = _sampleRates[value];
                  });
                },
              ),
              _buildDropdownSetting(
                'Audio Encoder',
                'Audio compression format',
                _selectedEncoder,
                _encoders,
                (value) {
                  setState(() {
                    _selectedEncoder = _encoders[value];
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('Recording Settings'),
            _buildSettingsCard([
              _buildSwitchSetting(
                'Auto Stop',
                'Automatically stop recording after maximum duration',
                _autoStopEnabled,
                (value) {
                  setState(() {
                    _autoStopEnabled = value;
                  });
                },
              ),
              _buildSliderSetting(
                'Max Recording Duration',
                '${_maxRecordingDuration ~/ 60}:${(_maxRecordingDuration % 60).toString().padLeft(2, '0')}',
                60, // 1 minute
                600, // 10 minutes
                _maxRecordingDuration.toDouble(),
                (value) {
                  setState(() {
                    _maxRecordingDuration = value.round();
                  });
                },
              ),
              _buildSwitchSetting(
                'Noise Reduction',
                'Reduce background noise during recording',
                _noiseReductionEnabled,
                (value) {
                  setState(() {
                    _noiseReductionEnabled = value;
                  });
                },
              ),
              _buildSwitchSetting(
                'Echo Cancellation',
                'Remove echo and feedback during recording',
                _echoCancellationEnabled,
                (value) {
                  setState(() {
                    _echoCancellationEnabled = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('User Interface'),
            _buildSettingsCard([
              _buildSwitchSetting(
                'Show Waveform',
                'Display audio waveform during recording',
                _showWaveform,
                (value) {
                  setState(() {
                    _showWaveform = value;
                  });
                },
              ),
              _buildSwitchSetting(
                'Haptic Feedback',
                'Vibrate when starting/stopping recording',
                _hapticFeedbackEnabled,
                (value) {
                  setState(() {
                    _hapticFeedbackEnabled = value;
                  });
                },
              ),
              _buildSwitchSetting(
                'Sound Effects',
                'Play sounds for recording actions',
                _soundEffectsEnabled,
                (value) {
                  setState(() {
                    _soundEffectsEnabled = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('Test Recording'),
            _buildTestRecordingCard(),

            const SizedBox(height: 24),

            _buildSectionHeader('Storage & Performance'),
            _buildSettingsCard([
              _buildInfoTile(
                'Storage Location',
                'Temporary directory',
                Icons.folder,
              ),
              _buildInfoTile(
                'File Format',
                'M4A (AAC)',
                Icons.audio_file,
              ),
              _buildInfoTile(
                'Estimated File Size',
                '~${(_selectedBitRate / 8 * 60 / 1000).toStringAsFixed(1)} MB per minute',
                Icons.storage,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.titleMediumStyle.copyWith(
          color: AppColors.textPrimary,
          fontWeight: AppTypography.semiBold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLargeStyle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmallStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryLight,
            activeTrackColor: AppColors.primaryLight.withOpacity(0.3),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.borderLight.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    String value,
    double min,
    double max,
    double currentValue,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyLargeStyle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTypography.medium,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodyMediumStyle.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryLight,
              inactiveTrackColor: AppColors.borderLight.withOpacity(0.3),
              thumbColor: AppColors.primaryLight,
              overlayColor: AppColors.primaryLight.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: currentValue,
              min: min,
              max: max,
              divisions: ((max - min) / 30).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String subtitle,
    String currentValue,
    List<String> options,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyLargeStyle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTypography.medium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmallStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.borderLight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                isExpanded: true,
                style: AppTypography.bodyMediumStyle.copyWith(
                  color: AppColors.textPrimary,
                ),
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onChanged(options.indexOf(newValue));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestRecordingCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Recording',
                        style: AppTypography.bodyLargeStyle.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      Text(
                        'Test your audio settings with a quick recording',
                        style: AppTypography.bodySmallStyle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isTestRecording) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recording... ${_testRecordingDuration.inSeconds}s',
                          style: AppTypography.bodyMediumStyle.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: AppTypography.medium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_showWaveform)
                      _buildWaveformVisualizer(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTestRecording ? _stopTestRecording : _startTestRecording,
                    icon: Icon(
                      _isTestRecording ? Icons.stop : Icons.mic,
                      size: 20,
                    ),
                    label: Text(
                      _isTestRecording ? 'Stop Test' : 'Start Test',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTestRecording ? AppColors.errorLight : AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_testRecordingPath.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      // TODO: Play test recording
                      _showInfoSnackBar('Playback feature coming soon');
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      color: AppColors.primaryLight,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformVisualizer() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          final height = (index % 3 + 1) * 8.0;
          return Container(
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMediumStyle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmallStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
