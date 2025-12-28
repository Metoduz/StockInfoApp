import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class LegalInfoScreen extends StatefulWidget {
  const LegalInfoScreen({super.key});

  @override
  State<LegalInfoScreen> createState() => _LegalInfoScreenState();
}

class _LegalInfoScreenState extends State<LegalInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isExporting ? null : _exportUserData,
            tooltip: 'Export User Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Terms of Service'),
            Tab(text: 'Privacy Policy'),
            Tab(text: 'Disclaimers'),
            Tab(text: 'Contact'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTermsOfService(),
          _buildPrivacyPolicy(),
          _buildDisclaimers(),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildTermsOfService() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms of Service',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: ${DateTime.now().year}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Acceptance of Terms',
            'By downloading, installing, or using the Asset Info App ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.',
          ),
          _buildSection(
            'Description of Service',
            'Asset Info App is a personal portfolio tracking application that provides asset information, news, and analysis tools. The App is designed for informational purposes only.',
          ),
          _buildSection(
            'User Responsibilities',
            'You are responsible for:\n• Maintaining the confidentiality of your data\n• Using the App in compliance with applicable laws\n• Not using the App for any unlawful purposes\n• Ensuring the accuracy of information you input',
          ),
          _buildSection(
            'Data and Privacy',
            'Your personal data is stored locally on your device. We do not collect or transmit personal information to external servers without your explicit consent. Please refer to our Privacy Policy for detailed information.',
          ),
          _buildSection(
            'Modifications',
            'We reserve the right to modify these terms at any time. Users will be notified of significant changes through the App. Continued use after modifications constitutes acceptance of the new terms.',
          ),
          _buildSection(
            'Limitation of Liability',
            'The App is provided "as is" without warranties of any kind. We shall not be liable for any damages arising from the use or inability to use the App.',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: ${DateTime.now().year}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Information We Collect',
            'Asset Info App stores the following information locally on your device:\n• Your watchlist and asset preferences\n• User profile information (name, email)\n• Trading history and transactions\n• App settings and preferences',
          ),
          _buildSection(
            'How We Use Information',
            'The information stored locally is used to:\n• Provide personalized asset tracking\n• Maintain your preferences across app sessions\n• Calculate portfolio performance metrics\n• Display relevant news and alerts',
          ),
          _buildSection(
            'Data Storage',
            'All personal data is stored locally on your device using secure storage mechanisms. We do not transmit your personal information to external servers unless explicitly required for specific features (such as news feeds or asset data).',
          ),
          _buildSection(
            'Third-Party Services',
            'The App may use third-party services for:\n• Asset market data\n• Financial news feeds\n• Currency exchange rates\nThese services have their own privacy policies and terms of use.',
          ),
          _buildSection(
            'Data Export',
            'You can export your data at any time through the App settings. This allows you to backup your information or transfer it to another device.',
          ),
          _buildSection(
            'Contact Us',
            'If you have questions about this Privacy Policy, please contact us using the information provided in the Contact section.',
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimers() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Disclaimers',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Important Investment Warning',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'All investments involve risk and may result in loss of capital. Past performance does not guarantee future results.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Not Financial Advice',
            'Asset Info App is designed for informational and educational purposes only. The information provided through this App does not constitute financial, investment, trading, or other professional advice. You should not rely on this information as a substitute for professional financial advice.',
          ),
          _buildSection(
            'Investment Risks',
            'Investing in assets and other securities involves risks, including:\n• Loss of principal investment\n• Market volatility and fluctuations\n• Currency exchange rate risks\n• Liquidity risks\n• Company-specific risks\n• Economic and political risks',
          ),
          _buildSection(
            'Data Accuracy',
            'While we strive to provide accurate and up-to-date information, we cannot guarantee the accuracy, completeness, or timeliness of the data displayed in the App. Asset prices, news, and other information may be delayed or contain errors.',
          ),
          _buildSection(
            'No Warranty',
            'The App and all information provided are on an "as is" basis without warranties of any kind, either express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, or non-infringement.',
          ),
          _buildSection(
            'Professional Advice',
            'Before making any investment decisions, you should:\n• Consult with qualified financial advisors\n• Conduct your own research and due diligence\n• Consider your financial situation and risk tolerance\n• Review all relevant documentation and prospectuses',
          ),
          _buildSection(
            'Regulatory Compliance',
            'Users are responsible for complying with all applicable laws and regulations in their jurisdiction regarding investment activities and financial reporting.',
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Support',
            'For technical support, questions about the App, or assistance with features:',
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(width: 8),
                      Text(
                        'Email Support',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('support@assetinfoapp.com'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: 8),
                      Text(
                        'Response Time',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('We typically respond within 24-48 hours'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Legal Inquiries',
            'For legal matters, privacy concerns, or terms of service questions:',
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.gavel),
                      const SizedBox(width: 8),
                      Text(
                        'Legal Department',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('legal@assetinfoapp.com'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Business Address',
            'Asset Info App Development Team\n123 Finance Street\nTech City, TC 12345\nGermany',
          ),
          const SizedBox(height: 16),
          _buildSection(
            'App Information',
            'Version: 1.0.0\nBuild: ${DateTime.now().millisecondsSinceEpoch}\nPlatform: Flutter',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Future<void> _exportUserData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final exportData = await _storageService.exportUserDataAsJson();
      
      if (!mounted) return;
      
      // Show export dialog with options
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export User Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your data has been prepared for export. Choose an option:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Data includes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Watchlist'),
              const Text('• User profile (excluding sensitive data)'),
              const Text('• App settings'),
              const Text('• Trading history'),
              const Text('• Alerts'),
              const Text('• Legal document versions'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sensitive data like backend IDs and API URLs are excluded for privacy.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _copyToClipboard(exportData);
              },
              child: const Text('Copy to Clipboard'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showExportData(exportData);
              },
              child: const Text('View Data'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export data: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard(String data) async {
    try {
      await Clipboard.setData(ClipboardData(text: data));
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy data: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showExportData(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exported Data'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              data,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copyToClipboard(data);
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}