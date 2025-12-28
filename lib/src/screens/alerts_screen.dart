import 'package:flutter/material.dart';
import '../models/asset_alert.dart';
import '../services/alert_service.dart';
import '../services/storage_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late AlertService _alertService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAlertService();
  }

  Future<void> _initializeAlertService() async {
    _alertService = AlertService(StorageService());
    await _alertService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _alertService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Alerts'),
        automaticallyImplyLeading: false,
        actions: [
          if (_isInitialized) ...[
            IconButton(
              icon: Icon(_alertService.isMonitoring 
                  ? Icons.pause_circle_filled 
                  : Icons.play_circle_filled),
              onPressed: () {
                if (_alertService.isMonitoring) {
                  _alertService.stopMonitoring();
                } else {
                  _alertService.startMonitoring();
                }
                setState(() {});
              },
              tooltip: _alertService.isMonitoring 
                  ? 'Stop monitoring' 
                  : 'Start monitoring',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateAlertDialog(),
              tooltip: 'Create new alert',
            ),
          ],
        ],
      ),
      body: _isInitialized 
          ? _buildAlertsList() 
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildAlertsList() {
    return ListenableBuilder(
      listenable: _alertService,
      builder: (context, child) {
        final alerts = _alertService.alerts;
        
        if (alerts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _alertService.loadAlerts();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(alert);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Alerts Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first asset alert to get notified\nwhen prices reach your target levels',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateAlertDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AssetAlert alert) {
    final status = alert.status;
    final statusColor = switch (status) {
      AlertStatus.active => Colors.green,
      AlertStatus.triggered => Colors.orange,
      AlertStatus.disabled => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            _getAlertTypeIcon(alert.type),
            color: statusColor,
          ),
        ),
        title: Text(
          alert.assetName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.getDescription()),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(status, statusColor),
                const SizedBox(width: 8),
                if (alert.triggeredAt != null)
                  Text(
                    'Triggered: ${_formatDateTime(alert.triggeredAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAlertAction(alert, value),
          itemBuilder: (context) => [
            if (alert.isEnabled)
              const PopupMenuItem(
                value: 'disable',
                child: ListTile(
                  leading: Icon(Icons.pause),
                  title: Text('Disable'),
                  contentPadding: EdgeInsets.zero,
                ),
              )
            else
              const PopupMenuItem(
                value: 'enable',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Enable'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (alert.triggeredAt != null)
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Reset'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(AlertStatus status, Color color) {
    final statusText = switch (status) {
      AlertStatus.active => 'Active',
      AlertStatus.triggered => 'Triggered',
      AlertStatus.disabled => 'Disabled',
    };

    return Chip(
      label: Text(
        statusText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color, width: 1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  IconData _getAlertTypeIcon(AlertType type) {
    return switch (type) {
      AlertType.priceAbove => Icons.trending_up,
      AlertType.priceBelow => Icons.trending_down,
      AlertType.percentChange => Icons.percent,
      AlertType.volumeSpike => Icons.bar_chart,
      AlertType.newsAlert => Icons.article,
    };
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleAlertAction(AssetAlert alert, String action) async {
    try {
      switch (action) {
        case 'enable':
          await _alertService.enableAlert(alert.id);
          break;
        case 'disable':
          await _alertService.disableAlert(alert.id);
          break;
        case 'reset':
          await _alertService.resetAlert(alert.id);
          break;
        case 'edit':
          _showEditAlertDialog(alert);
          break;
        case 'delete':
          _showDeleteConfirmation(alert);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => _AlertDialog(
        alertService: _alertService,
        onAlertCreated: () => setState(() {}),
      ),
    );
  }

  void _showEditAlertDialog(AssetAlert alert) {
    showDialog(
      context: context,
      builder: (context) => _AlertDialog(
        alertService: _alertService,
        existingAlert: alert,
        onAlertCreated: () => setState(() {}),
      ),
    );
  }

  void _showDeleteConfirmation(AssetAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text('Are you sure you want to delete the alert for ${alert.assetName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _alertService.deleteAlert(alert.id);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting alert: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AlertDialog extends StatefulWidget {
  final AlertService alertService;
  final AssetAlert? existingAlert;
  final VoidCallback onAlertCreated;

  const _AlertDialog({
    required this.alertService,
    this.existingAlert,
    required this.onAlertCreated,
  });

  @override
  State<_AlertDialog> createState() => _AlertDialogState();
}

class _AlertDialogState extends State<_AlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _thresholdController = TextEditingController();
  
  String? _selectedAssetId;
  AlertType _selectedType = AlertType.priceAbove;
  bool _enablePushNotifications = true;
  bool _enableInAppNotifications = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingAlert != null) {
      final alert = widget.existingAlert!;
      _selectedAssetId = alert.assetId;
      _selectedType = alert.type;
      _thresholdController.text = alert.threshold.toString();
      _enablePushNotifications = alert.notifications.enablePushNotifications;
      _enableInAppNotifications = alert.notifications.enableInAppNotifications;
    }
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAlert != null;
    final availableAssets = widget.alertService.getAllAssetData();

    return AlertDialog(
      title: Text(isEditing ? 'Edit Alert' : 'Create Alert'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Asset selection
              DropdownButtonFormField<String>(
                value: _selectedAssetId,
                decoration: const InputDecoration(
                  labelText: 'Asset',
                  border: OutlineInputBorder(),
                ),
                items: availableAssets.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text('${entry.value.name} (${entry.key})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAssetId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a asset';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Alert type selection
              DropdownButtonFormField<AlertType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Alert Type',
                  border: OutlineInputBorder(),
                ),
                items: AlertType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAlertTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Threshold input
              TextFormField(
                controller: _thresholdController,
                decoration: InputDecoration(
                  labelText: _getThresholdLabel(_selectedType),
                  border: const OutlineInputBorder(),
                  suffixText: _getThresholdSuffix(_selectedType),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a threshold value';
                  }
                  final threshold = double.tryParse(value);
                  if (threshold == null) {
                    return 'Please enter a valid number';
                  }
                  if (threshold <= 0) {
                    return 'Threshold must be greater than 0';
                  }
                  if (_selectedType == AlertType.percentChange && threshold > 100) {
                    return 'Percentage must be between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Notification settings
              const Text(
                'Notification Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: const Text('Push Notifications'),
                value: _enablePushNotifications,
                onChanged: (value) {
                  setState(() {
                    _enablePushNotifications = value ?? true;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('In-App Notifications'),
                value: _enableInAppNotifications,
                onChanged: (value) {
                  setState(() {
                    _enableInAppNotifications = value ?? true;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAlert,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  String _getAlertTypeLabel(AlertType type) {
    return switch (type) {
      AlertType.priceAbove => 'Price Above',
      AlertType.priceBelow => 'Price Below',
      AlertType.percentChange => 'Percentage Change',
      AlertType.volumeSpike => 'Volume Spike',
      AlertType.newsAlert => 'News Alert',
    };
  }

  String _getThresholdLabel(AlertType type) {
    return switch (type) {
      AlertType.priceAbove => 'Price Threshold',
      AlertType.priceBelow => 'Price Threshold',
      AlertType.percentChange => 'Percentage Change',
      AlertType.volumeSpike => 'Volume Threshold',
      AlertType.newsAlert => 'Not applicable',
    };
  }

  String _getThresholdSuffix(AlertType type) {
    return switch (type) {
      AlertType.priceAbove => '€',
      AlertType.priceBelow => '€',
      AlertType.percentChange => '%',
      AlertType.volumeSpike => '',
      AlertType.newsAlert => '',
    };
  }

  Future<void> _saveAlert() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAssetId == null) return;

    try {
      final threshold = double.parse(_thresholdController.text);
      final assetData = widget.alertService.getAllAssetData()[_selectedAssetId!]!;
      
      final notifications = NotificationSettings(
        enablePushNotifications: _enablePushNotifications,
        enableInAppNotifications: _enableInAppNotifications,
      );

      if (widget.existingAlert != null) {
        // Update existing alert
        final updatedAlert = widget.existingAlert!.copyWith(
          assetId: _selectedAssetId,
          assetName: assetData.name,
          type: _selectedType,
          threshold: threshold,
          notifications: notifications,
        );
        await widget.alertService.updateAlert(updatedAlert);
      } else {
        // Create new alert
        final alert = AssetAlert(
          id: AlertService.generateAlertId(),
          assetId: _selectedAssetId!,
          assetName: assetData.name,
          type: _selectedType,
          threshold: threshold,
          createdAt: DateTime.now(),
          notifications: notifications,
        );
        await widget.alertService.createAlert(alert);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onAlertCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingAlert != null 
                ? 'Alert updated successfully' 
                : 'Alert created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}