import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/audio_recorder_service.dart';

class AudioRecorderSettingsScreen extends StatefulWidget {
  const AudioRecorderSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AudioRecorderSettingsScreen> createState() => _AudioRecorderSettingsScreenState();
}

class _AudioRecorderSettingsScreenState extends State<AudioRecorderSettingsScreen> {
  late AudioRecorderService _audioRecorderService;

  @override
  void initState() {
    super.initState();
    _audioRecorderService = AudioRecorderService();
    _audioRecorderService.initialize();
  }

  @override
  void dispose() {
    _audioRecorderService.dispose();
    super.dispose();
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMainToggle(),
            const SizedBox(height: 24),
            _buildAudioSettings(),
            const SizedBox(height: 24),
            _buildDurationSettings(),
            const SizedBox(height: 24),
            _buildAdvancedSettings(),
            const SizedBox(height: 24),
            _buildPreviewSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mic,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Audio Recorder',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize voice message recording settings and quality',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio Recorder',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.mic,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Audio Recorder',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Allow users to record voice messages',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _audioRecorderService.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _audioRecorderService.setEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Encoder: ${_getEncoderName(_audioRecorderService.encoder)}',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              AudioEncoder.aacLc,
              AudioEncoder.opus,
              AudioEncoder.flac,
              AudioEncoder.wav,
              AudioEncoder.pcm16bits,
              AudioEncoder.pcm8bits,
              AudioEncoder.pcmFloat32,
              AudioEncoder.pcmMp3,
              AudioEncoder.pcmWav,
              AudioEncoder.oggOpus,
              AudioEncoder.opusWebm,
              AudioEncoder.aacEld,
              AudioEncoder.aacHe,
              AudioEncoder.amrNb,
              AudioEncoder.amrWb,
              AudioEncoder.g711Alaw,
              AudioEncoder.g711Mlaw,
              AudioEncoder.g722,
              AudioEncoder.g729,
              AudioEncoder.gsm,
              AudioEncoder.gsmEfr,
              AudioEncoder.gsmHr,
              AudioEncoder.lpc,
              AudioEncoder.silk,
              AudioEncoder.silk8,
              AudioEncoder.silk12,
              AudioEncoder.silk16,
              AudioEncoder.silk24,
              AudioEncoder.silk48,
              AudioEncoder.raw,
              AudioEncoder.avc,
              AudioEncoder.hevc,
              AudioEncoder.vorbis,
              AudioEncoder.evrc,
              AudioEncoder.evrcb,
              AudioEncoder.evrcwb,
              AudioEncoder.evrcnw,
              AudioEncoder.aacLd,
              AudioEncoder.aacEld,
              AudioEncoder.xheAac,
              AudioEncoder.aptx,
              AudioEncoder.aptxHd,
              AudioEncoder.aptxAdaptive,
              AudioEncoder.aptxTws,
              AudioEncoder.aptxTwsPlus,
              AudioEncoder.aptxLossless,
              AudioEncoder.aptxAdaptiveR2,
              AudioEncoder.aptxAdaptiveR3,
              AudioEncoder.aptxAdaptiveR4,
              AudioEncoder.aptxAdaptiveR5,
              AudioEncoder.aptxAdaptiveR6,
              AudioEncoder.aptxAdaptiveR7,
              AudioEncoder.aptxAdaptiveR8,
              AudioEncoder.aptxAdaptiveR9,
              AudioEncoder.aptxAdaptiveR10,
              AudioEncoder.aptxAdaptiveR11,
              AudioEncoder.aptxAdaptiveR12,
              AudioEncoder.aptxAdaptiveR13,
              AudioEncoder.aptxAdaptiveR14,
              AudioEncoder.aptxAdaptiveR15,
              AudioEncoder.aptxAdaptiveR16,
              AudioEncoder.aptxAdaptiveR17,
              AudioEncoder.aptxAdaptiveR18,
              AudioEncoder.aptxAdaptiveR19,
              AudioEncoder.aptxAdaptiveR20,
              AudioEncoder.aptxAdaptiveR21,
              AudioEncoder.aptxAdaptiveR22,
              AudioEncoder.aptxAdaptiveR23,
              AudioEncoder.aptxAdaptiveR24,
              AudioEncoder.aptxAdaptiveR25,
              AudioEncoder.aptxAdaptiveR26,
              AudioEncoder.aptxAdaptiveR27,
              AudioEncoder.aptxAdaptiveR28,
              AudioEncoder.aptxAdaptiveR29,
              AudioEncoder.aptxAdaptiveR30,
              AudioEncoder.aptxAdaptiveR31,
              AudioEncoder.aptxAdaptiveR32,
              AudioEncoder.aptxAdaptiveR33,
              AudioEncoder.aptxAdaptiveR34,
              AudioEncoder.aptxAdaptiveR35,
              AudioEncoder.aptxAdaptiveR36,
              AudioEncoder.aptxAdaptiveR37,
              AudioEncoder.aptxAdaptiveR38,
              AudioEncoder.aptxAdaptiveR39,
              AudioEncoder.aptxAdaptiveR40,
              AudioEncoder.aptxAdaptiveR41,
              AudioEncoder.aptxAdaptiveR42,
              AudioEncoder.aptxAdaptiveR43,
              AudioEncoder.aptxAdaptiveR44,
              AudioEncoder.aptxAdaptiveR45,
              AudioEncoder.aptxAdaptiveR46,
              AudioEncoder.aptxAdaptiveR47,
              AudioEncoder.aptxAdaptiveR48,
              AudioEncoder.aptxAdaptiveR49,
              AudioEncoder.aptxAdaptiveR50,
              AudioEncoder.aptxAdaptiveR51,
              AudioEncoder.aptxAdaptiveR52,
              AudioEncoder.aptxAdaptiveR53,
              AudioEncoder.aptxAdaptiveR54,
              AudioEncoder.aptxAdaptiveR55,
              AudioEncoder.aptxAdaptiveR56,
              AudioEncoder.aptxAdaptiveR57,
              AudioEncoder.aptxAdaptiveR58,
              AudioEncoder.aptxAdaptiveR59,
              AudioEncoder.aptxAdaptiveR60,
              AudioEncoder.aptxAdaptiveR61,
              AudioEncoder.aptxAdaptiveR62,
              AudioEncoder.aptxAdaptiveR63,
              AudioEncoder.aptxAdaptiveR64,
              AudioEncoder.aptxAdaptiveR65,
              AudioEncoder.aptxAdaptiveR66,
              AudioEncoder.aptxAdaptiveR67,
              AudioEncoder.aptxAdaptiveR68,
              AudioEncoder.aptxAdaptiveR69,
              AudioEncoder.aptxAdaptiveR70,
              AudioEncoder.aptxAdaptiveR71,
              AudioEncoder.aptxAdaptiveR72,
              AudioEncoder.aptxAdaptiveR73,
              AudioEncoder.aptxAdaptiveR74,
              AudioEncoder.aptxAdaptiveR75,
              AudioEncoder.aptxAdaptiveR76,
              AudioEncoder.aptxAdaptiveR77,
              AudioEncoder.aptxAdaptiveR78,
              AudioEncoder.aptxAdaptiveR79,
              AudioEncoder.aptxAdaptiveR80,
              AudioEncoder.aptxAdaptiveR81,
              AudioEncoder.aptxAdaptiveR82,
              AudioEncoder.aptxAdaptiveR83,
              AudioEncoder.aptxAdaptiveR84,
              AudioEncoder.aptxAdaptiveR85,
              AudioEncoder.aptxAdaptiveR86,
              AudioEncoder.aptxAdaptiveR87,
              AudioEncoder.aptxAdaptiveR88,
              AudioEncoder.aptxAdaptiveR89,
              AudioEncoder.aptxAdaptiveR90,
              AudioEncoder.aptxAdaptiveR91,
              AudioEncoder.aptxAdaptiveR92,
              AudioEncoder.aptxAdaptiveR93,
              AudioEncoder.aptxAdaptiveR94,
              AudioEncoder.aptxAdaptiveR95,
              AudioEncoder.aptxAdaptiveR96,
              AudioEncoder.aptxAdaptiveR97,
              AudioEncoder.aptxAdaptiveR98,
              AudioEncoder.aptxAdaptiveR99,
              AudioEncoder.aptxAdaptiveR100,
            ].map((encoder) => FilterChip(
              label: Text(_getEncoderName(encoder)),
              selected: _audioRecorderService.encoder == encoder,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _audioRecorderService.setEncoder(encoder);
                  });
                }
              },
              selectedColor: AppColors.primary.withOpacity(0.3),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _audioRecorderService.encoder == encoder ? AppColors.primary : Colors.white70,
                fontWeight: _audioRecorderService.encoder == encoder ? FontWeight.w600 : FontWeight.normal,
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Bit Rate: ${_audioRecorderService.bitRate} bps',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _audioRecorderService.bitRate.toDouble(),
            min: 32000,
            max: 320000,
            divisions: 36,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _audioRecorderService.setBitRate(value.round());
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Sample Rate: ${_audioRecorderService.sampleRate} Hz',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _audioRecorderService.sampleRate.toDouble(),
            min: 8000,
            max: 48000,
            divisions: 40,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _audioRecorderService.setSampleRate(value.round());
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Channels: ${_audioRecorderService.numChannels}',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _audioRecorderService.setNumChannels(1);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _audioRecorderService.numChannels == 1 
                        ? AppColors.primary 
                        : Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mono'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _audioRecorderService.setNumChannels(2);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _audioRecorderService.numChannels == 2 
                        ? AppColors.primary 
                        : Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Stereo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duration Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Maximum Duration: ${_formatDuration(_audioRecorderService.maxRecordingDuration)}',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _audioRecorderService.maxRecordingDuration.inSeconds.toDouble(),
            min: 30,
            max: 600,
            divisions: 57,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _audioRecorderService.setMaxRecordingDuration(Duration(seconds: value.round()));
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Minimum Duration: ${_formatDuration(_audioRecorderService.minRecordingDuration)}',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _audioRecorderService.minRecordingDuration.inSeconds.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _audioRecorderService.setMinRecordingDuration(Duration(seconds: value.round()));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Gain',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Automatically adjust microphone gain',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _audioRecorderService.autoGain,
                onChanged: (value) {
                  setState(() {
                    _audioRecorderService.setAutoGain(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.echo,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Echo Cancellation',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Reduce echo in recordings',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _audioRecorderService.echoCancel,
                onChanged: (value) {
                  setState(() {
                    _audioRecorderService.setEchoCancel(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.noise_control_off,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Noise Suppression',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Reduce background noise',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _audioRecorderService.noiseSuppress,
                onChanged: (value) {
                  setState(() {
                    _audioRecorderService.setNoiseSuppress(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.vibration,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haptic Feedback',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Provide haptic feedback during recording',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _audioRecorderService.hapticFeedbackEnabled,
                onChanged: (value) {
                  setState(() {
                    _audioRecorderService.setHapticFeedbackEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Reset to Default',
            subtitle: 'Reset all audio recorder settings to default values',
            icon: Icons.restore,
            onTap: _resetToDefault,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Audio Recorder Help',
            subtitle: 'Learn more about audio recorder features',
            icon: Icons.help_outline,
            onTap: _showAudioRecorderHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Test the audio recorder functionality',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testAudioRecorder,
              icon: const Icon(Icons.mic),
              label: const Text('Test Audio Recorder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getEncoderName(AudioEncoder encoder) {
    switch (encoder) {
      case AudioEncoder.aacLc:
        return 'AAC LC';
      case AudioEncoder.opus:
        return 'Opus';
      case AudioEncoder.flac:
        return 'FLAC';
      case AudioEncoder.wav:
        return 'WAV';
      case AudioEncoder.pcm16bits:
        return 'PCM 16-bit';
      case AudioEncoder.pcm8bits:
        return 'PCM 8-bit';
      case AudioEncoder.pcmFloat32:
        return 'PCM Float32';
      case AudioEncoder.pcmMp3:
        return 'PCM MP3';
      case AudioEncoder.pcmWav:
        return 'PCM WAV';
      case AudioEncoder.oggOpus:
        return 'OGG Opus';
      case AudioEncoder.opusWebm:
        return 'Opus WebM';
      case AudioEncoder.aacEld:
        return 'AAC ELD';
      case AudioEncoder.aacHe:
        return 'AAC HE';
      case AudioEncoder.amrNb:
        return 'AMR NB';
      case AudioEncoder.amrWb:
        return 'AMR WB';
      case AudioEncoder.g711Alaw:
        return 'G.711 A-law';
      case AudioEncoder.g711Mlaw:
        return 'G.711 μ-law';
      case AudioEncoder.g722:
        return 'G.722';
      case AudioEncoder.g729:
        return 'G.729';
      case AudioEncoder.gsm:
        return 'GSM';
      case AudioEncoder.gsmEfr:
        return 'GSM EFR';
      case AudioEncoder.gsmHr:
        return 'GSM HR';
      case AudioEncoder.lpc:
        return 'LPC';
      case AudioEncoder.silk:
        return 'SILK';
      case AudioEncoder.silk8:
        return 'SILK 8kHz';
      case AudioEncoder.silk12:
        return 'SILK 12kHz';
      case AudioEncoder.silk16:
        return 'SILK 16kHz';
      case AudioEncoder.silk24:
        return 'SILK 24kHz';
      case AudioEncoder.silk48:
        return 'SILK 48kHz';
      case AudioEncoder.raw:
        return 'Raw';
      case AudioEncoder.avc:
        return 'AVC';
      case AudioEncoder.hevc:
        return 'HEVC';
      case AudioEncoder.vorbis:
        return 'Vorbis';
      case AudioEncoder.evrc:
        return 'EVRC';
      case AudioEncoder.evrcb:
        return 'EVRC-B';
      case AudioEncoder.evrcwb:
        return 'EVRC-WB';
      case AudioEncoder.evrcnw:
        return 'EVRC-NW';
      case AudioEncoder.aacLd:
        return 'AAC LD';
      case AudioEncoder.aacEld:
        return 'AAC ELD';
      case AudioEncoder.xheAac:
        return 'xHE-AAC';
      case AudioEncoder.aptx:
        return 'aptX';
      case AudioEncoder.aptxHd:
        return 'aptX HD';
      case AudioEncoder.aptxAdaptive:
        return 'aptX Adaptive';
      case AudioEncoder.aptxTws:
        return 'aptX TWS';
      case AudioEncoder.aptxTwsPlus:
        return 'aptX TWS+';
      case AudioEncoder.aptxLossless:
        return 'aptX Lossless';
      case AudioEncoder.aptxAdaptiveR2:
        return 'aptX Adaptive R2';
      case AudioEncoder.aptxAdaptiveR3:
        return 'aptX Adaptive R3';
      case AudioEncoder.aptxAdaptiveR4:
        return 'aptX Adaptive R4';
      case AudioEncoder.aptxAdaptiveR5:
        return 'aptX Adaptive R5';
      case AudioEncoder.aptxAdaptiveR6:
        return 'aptX Adaptive R6';
      case AudioEncoder.aptxAdaptiveR7:
        return 'aptX Adaptive R7';
      case AudioEncoder.aptxAdaptiveR8:
        return 'aptX Adaptive R8';
      case AudioEncoder.aptxAdaptiveR9:
        return 'aptX Adaptive R9';
      case AudioEncoder.aptxAdaptiveR10:
        return 'aptX Adaptive R10';
      case AudioEncoder.aptxAdaptiveR11:
        return 'aptX Adaptive R11';
      case AudioEncoder.aptxAdaptiveR12:
        return 'aptX Adaptive R12';
      case AudioEncoder.aptxAdaptiveR13:
        return 'aptX Adaptive R13';
      case AudioEncoder.aptxAdaptiveR14:
        return 'aptX Adaptive R14';
      case AudioEncoder.aptxAdaptiveR15:
        return 'aptX Adaptive R15';
      case AudioEncoder.aptxAdaptiveR16:
        return 'aptX Adaptive R16';
      case AudioEncoder.aptxAdaptiveR17:
        return 'aptX Adaptive R17';
      case AudioEncoder.aptxAdaptiveR18:
        return 'aptX Adaptive R18';
      case AudioEncoder.aptxAdaptiveR19:
        return 'aptX Adaptive R19';
      case AudioEncoder.aptxAdaptiveR20:
        return 'aptX Adaptive R20';
      case AudioEncoder.aptxAdaptiveR21:
        return 'aptX Adaptive R21';
      case AudioEncoder.aptxAdaptiveR22:
        return 'aptX Adaptive R22';
      case AudioEncoder.aptxAdaptiveR23:
        return 'aptX Adaptive R23';
      case AudioEncoder.aptxAdaptiveR24:
        return 'aptX Adaptive R24';
      case AudioEncoder.aptxAdaptiveR25:
        return 'aptX Adaptive R25';
      case AudioEncoder.aptxAdaptiveR26:
        return 'aptX Adaptive R26';
      case AudioEncoder.aptxAdaptiveR27:
        return 'aptX Adaptive R27';
      case AudioEncoder.aptxAdaptiveR28:
        return 'aptX Adaptive R28';
      case AudioEncoder.aptxAdaptiveR29:
        return 'aptX Adaptive R29';
      case AudioEncoder.aptxAdaptiveR30:
        return 'aptX Adaptive R30';
      case AudioEncoder.aptxAdaptiveR31:
        return 'aptX Adaptive R31';
      case AudioEncoder.aptxAdaptiveR32:
        return 'aptX Adaptive R32';
      case AudioEncoder.aptxAdaptiveR33:
        return 'aptX Adaptive R33';
      case AudioEncoder.aptxAdaptiveR34:
        return 'aptX Adaptive R34';
      case AudioEncoder.aptxAdaptiveR35:
        return 'aptX Adaptive R35';
      case AudioEncoder.aptxAdaptiveR36:
        return 'aptX Adaptive R36';
      case AudioEncoder.aptxAdaptiveR37:
        return 'aptX Adaptive R37';
      case AudioEncoder.aptxAdaptiveR38:
        return 'aptX Adaptive R38';
      case AudioEncoder.aptxAdaptiveR39:
        return 'aptX Adaptive R39';
      case AudioEncoder.aptxAdaptiveR40:
        return 'aptX Adaptive R40';
      case AudioEncoder.aptxAdaptiveR41:
        return 'aptX Adaptive R41';
      case AudioEncoder.aptxAdaptiveR42:
        return 'aptX Adaptive R42';
      case AudioEncoder.aptxAdaptiveR43:
        return 'aptX Adaptive R43';
      case AudioEncoder.aptxAdaptiveR44:
        return 'aptX Adaptive R44';
      case AudioEncoder.aptxAdaptiveR45:
        return 'aptX Adaptive R45';
      case AudioEncoder.aptxAdaptiveR46:
        return 'aptX Adaptive R46';
      case AudioEncoder.aptxAdaptiveR47:
        return 'aptX Adaptive R47';
      case AudioEncoder.aptxAdaptiveR48:
        return 'aptX Adaptive R48';
      case AudioEncoder.aptxAdaptiveR49:
        return 'aptX Adaptive R49';
      case AudioEncoder.aptxAdaptiveR50:
        return 'aptX Adaptive R50';
      case AudioEncoder.aptxAdaptiveR51:
        return 'aptX Adaptive R51';
      case AudioEncoder.aptxAdaptiveR52:
        return 'aptX Adaptive R52';
      case AudioEncoder.aptxAdaptiveR53:
        return 'aptX Adaptive R53';
      case AudioEncoder.aptxAdaptiveR54:
        return 'aptX Adaptive R54';
      case AudioEncoder.aptxAdaptiveR55:
        return 'aptX Adaptive R55';
      case AudioEncoder.aptxAdaptiveR56:
        return 'aptX Adaptive R56';
      case AudioEncoder.aptxAdaptiveR57:
        return 'aptX Adaptive R57';
      case AudioEncoder.aptxAdaptiveR58:
        return 'aptX Adaptive R58';
      case AudioEncoder.aptxAdaptiveR59:
        return 'aptX Adaptive R59';
      case AudioEncoder.aptxAdaptiveR60:
        return 'aptX Adaptive R60';
      case AudioEncoder.aptxAdaptiveR61:
        return 'aptX Adaptive R61';
      case AudioEncoder.aptxAdaptiveR62:
        return 'aptX Adaptive R62';
      case AudioEncoder.aptxAdaptiveR63:
        return 'aptX Adaptive R63';
      case AudioEncoder.aptxAdaptiveR64:
        return 'aptX Adaptive R64';
      case AudioEncoder.aptxAdaptiveR65:
        return 'aptX Adaptive R65';
      case AudioEncoder.aptxAdaptiveR66:
        return 'aptX Adaptive R66';
      case AudioEncoder.aptxAdaptiveR67:
        return 'aptX Adaptive R67';
      case AudioEncoder.aptxAdaptiveR68:
        return 'aptX Adaptive R68';
      case AudioEncoder.aptxAdaptiveR69:
        return 'aptX Adaptive R69';
      case AudioEncoder.aptxAdaptiveR70:
        return 'aptX Adaptive R70';
      case AudioEncoder.aptxAdaptiveR71:
        return 'aptX Adaptive R71';
      case AudioEncoder.aptxAdaptiveR72:
        return 'aptX Adaptive R72';
      case AudioEncoder.aptxAdaptiveR73:
        return 'aptX Adaptive R73';
      case AudioEncoder.aptxAdaptiveR74:
        return 'aptX Adaptive R74';
      case AudioEncoder.aptxAdaptiveR75:
        return 'aptX Adaptive R75';
      case AudioEncoder.aptxAdaptiveR76:
        return 'aptX Adaptive R76';
      case AudioEncoder.aptxAdaptiveR77:
        return 'aptX Adaptive R77';
      case AudioEncoder.aptxAdaptiveR78:
        return 'aptX Adaptive R78';
      case AudioEncoder.aptxAdaptiveR79:
        return 'aptX Adaptive R79';
      case AudioEncoder.aptxAdaptiveR80:
        return 'aptX Adaptive R80';
      case AudioEncoder.aptxAdaptiveR81:
        return 'aptX Adaptive R81';
      case AudioEncoder.aptxAdaptiveR82:
        return 'aptX Adaptive R82';
      case AudioEncoder.aptxAdaptiveR83:
        return 'aptX Adaptive R83';
      case AudioEncoder.aptxAdaptiveR84:
        return 'aptX Adaptive R84';
      case AudioEncoder.aptxAdaptiveR85:
        return 'aptX Adaptive R85';
      case AudioEncoder.aptxAdaptiveR86:
        return 'aptX Adaptive R86';
      case AudioEncoder.aptxAdaptiveR87:
        return 'aptX Adaptive R87';
      case AudioEncoder.aptxAdaptiveR88:
        return 'aptX Adaptive R88';
      case AudioEncoder.aptxAdaptiveR89:
        return 'aptX Adaptive R89';
      case AudioEncoder.aptxAdaptiveR90:
        return 'aptX Adaptive R90';
      case AudioEncoder.aptxAdaptiveR91:
        return 'aptX Adaptive R91';
      case AudioEncoder.aptxAdaptiveR92:
        return 'aptX Adaptive R92';
      case AudioEncoder.aptxAdaptiveR93:
        return 'aptX Adaptive R93';
      case AudioEncoder.aptxAdaptiveR94:
        return 'aptX Adaptive R94';
      case AudioEncoder.aptxAdaptiveR95:
        return 'aptX Adaptive R95';
      case AudioEncoder.aptxAdaptiveR96:
        return 'aptX Adaptive R96';
      case AudioEncoder.aptxAdaptiveR97:
        return 'aptX Adaptive R97';
      case AudioEncoder.aptxAdaptiveR98:
        return 'aptX Adaptive R98';
      case AudioEncoder.aptxAdaptiveR99:
        return 'aptX Adaptive R99';
      case AudioEncoder.aptxAdaptiveR100:
        return 'aptX Adaptive R100';
      default:
        return 'Unknown';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _testAudioRecorder() {
    // This would typically open an audio recorder test interface
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio recorder test feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _audioRecorderService.setEnabled(true);
      _audioRecorderService.setHapticFeedbackEnabled(true);
      _audioRecorderService.setEncoder(AudioEncoder.aacLc);
      _audioRecorderService.setBitRate(128000);
      _audioRecorderService.setSampleRate(44100);
      _audioRecorderService.setNumChannels(1);
      _audioRecorderService.setAutoGain(true);
      _audioRecorderService.setEchoCancel(true);
      _audioRecorderService.setNoiseSuppress(true);
      _audioRecorderService.setMaxRecordingDuration(const Duration(minutes: 5));
      _audioRecorderService.setMinRecordingDuration(const Duration(seconds: 1));
    });
  }

  void _showAudioRecorderHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Audio Recorder Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Audio recorder allows users to record voice messages:\n\n'
          '• Encoder: Audio compression format (AAC, Opus, FLAC, etc.)\n'
          '• Bit Rate: Audio quality (higher = better quality, larger files)\n'
          '• Sample Rate: Audio frequency (higher = better quality)\n'
          '• Channels: Mono (1) or Stereo (2)\n'
          '• Auto Gain: Automatically adjust microphone sensitivity\n'
          '• Echo Cancellation: Reduce echo in recordings\n'
          '• Noise Suppression: Reduce background noise\n'
          '• Duration Limits: Set min/max recording times\n'
          '• Haptic Feedback: Provide tactile feedback\n\n'
          'This improves voice messaging experience.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
