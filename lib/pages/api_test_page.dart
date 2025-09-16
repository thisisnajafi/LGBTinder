import 'package:flutter/material.dart';
import '../utils/api_test.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({Key? key}) : super(key: key);

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  bool _isRunningTests = false;
  Map<String, bool> _testResults = {};
  String _testLog = '';

  void _runTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults = {};
      _testLog = 'Starting API tests...\n';
    });

    try {
      final results = await ApiTest.runAllTests();
      setState(() {
        _testResults = results;
        _testLog += '\nTests completed!';
        _isRunningTests = false;
      });
    } catch (e) {
      setState(() {
        _testLog += '\nError running tests: $e';
        _isRunningTests = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Connectivity Tests',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isRunningTests ? null : _runTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isRunningTests
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Running Tests...'),
                      ],
                    )
                  : const Text('Run API Tests'),
            ),
            
            const SizedBox(height: 24),
            
            if (_testResults.isNotEmpty) ...[
              Text(
                'Test Results',
                style: AppTypography.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              ..._testResults.entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.navbarBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      entry.value ? Icons.check_circle : Icons.error,
                      color: entry.value ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      entry.value ? 'PASS' : 'FAIL',
                      style: AppTypography.body1.copyWith(
                        color: entry.value ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.navbarBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Status',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _testResults.values.every((result) => result)
                          ? '✅ All tests passed! API connectivity is working.'
                          : '❌ Some tests failed. Check API configuration.',
                      style: AppTypography.body2.copyWith(
                        color: _testResults.values.every((result) => result)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            Text(
              'Test Log',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.navbarBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testLog.isEmpty ? 'No tests run yet.' : _testLog,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white70,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
