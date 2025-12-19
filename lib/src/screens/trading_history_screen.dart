import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/app_state_provider.dart';
import '../services/storage_service.dart';

class TradingHistoryScreen extends StatefulWidget {
  const TradingHistoryScreen({super.key});

  @override
  State<TradingHistoryScreen> createState() => _TradingHistoryScreenState();
}

class _TradingHistoryScreenState extends State<TradingHistoryScreen> {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  PerformanceMetrics? _performanceMetrics;
  bool _isLoading = true;
  
  // Filter state
  TransactionType? _selectedTypeFilter;
  DateTimeRange? _selectedDateRange;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    try {
      final storageService = StorageService();
      final transactions = await storageService.loadTransactions();
      
      // Get current stock prices for performance calculation
      if (!mounted) return;
      final appState = context.read<AppStateProvider>();
      final currentPrices = <String, double>{};
      for (final stock in appState.watchlist) {
        currentPrices[stock.id] = stock.currentValue;
      }
      
      final performanceMetrics = PerformanceMetrics.fromTransactions(
        transactions,
        currentPrices,
      );
      
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _filteredTransactions = transactions;
          _performanceMetrics = performanceMetrics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        return transaction.matchesFilter(
          stockSymbol: _searchController.text.isEmpty ? null : _searchController.text,
          startDate: _selectedDateRange?.start,
          endDate: _selectedDateRange?.end,
          transactionType: _selectedTypeFilter,
        );
      }).toList();
      
      // Sort by date (newest first)
      _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _showAddTransactionDialog() async {
    final result = await showDialog<Transaction>(
      context: context,
      builder: (context) => const _AddTransactionDialog(),
    );
    
    if (result != null) {
      await _addTransaction(result);
    }
  }

  Future<void> _addTransaction(Transaction transaction) async {
    try {
      final storageService = StorageService();
      final updatedTransactions = [..._transactions, transaction];
      await storageService.saveTransactions(updatedTransactions);
      
      setState(() {
        _transactions = updatedTransactions;
      });
      
      _applyFilters();
      await _loadTransactions(); // Reload to recalculate performance metrics
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding transaction: $e')),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedTypeFilter = null;
      _selectedDateRange = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTransactionDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Performance metrics card
                if (_performanceMetrics != null) _buildPerformanceCard(),
                
                // Search and filter bar
                _buildSearchAndFilterBar(),
                
                // Transaction list
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionList(),
                ),
              ],
            ),
    );
  }

  Widget _buildPerformanceCard() {
    final metrics = _performanceMetrics!;
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Performance',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Total Invested',
                    '€${metrics.totalInvested.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Current Value',
                    '€${metrics.totalValue.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Profit/Loss',
                    '€${metrics.totalProfitLoss.toStringAsFixed(2)}',
                    color: metrics.totalProfitLoss >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Return',
                    '${metrics.totalPercentageReturn.toStringAsFixed(2)}%',
                    color: metrics.totalPercentageReturn >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Total Fees',
                    '€${metrics.totalFees.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Transactions',
                    '${metrics.totalTransactions}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by stock symbol...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 8),
            _buildActiveFiltersChips(),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedTypeFilter != null || _selectedDateRange != null;
  }

  Widget _buildActiveFiltersChips() {
    return Wrap(
      spacing: 8,
      children: [
        if (_selectedTypeFilter != null)
          Chip(
            label: Text(_selectedTypeFilter!.name.toUpperCase()),
            onDeleted: () {
              setState(() => _selectedTypeFilter = null);
              _applyFilters();
            },
          ),
        if (_selectedDateRange != null)
          Chip(
            label: Text(
              '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
            ),
            onDeleted: () {
              setState(() => _selectedDateRange = null);
              _applyFilters();
            },
          ),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear All'),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final theme = Theme.of(context);
    final isPositive = transaction.type == TransactionType.buy || 
                      transaction.type == TransactionType.dividend;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPositive ? Colors.green : Colors.red,
          child: Icon(
            _getTransactionIcon(transaction.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.stockName,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction.type.name.toUpperCase()} • ${transaction.quantity} shares'),
            Text('${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(transaction.notes!, style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€${transaction.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '€${transaction.totalValue.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icons.add;
      case TransactionType.sell:
        return Icons.remove;
      case TransactionType.dividend:
        return Icons.payments;
      case TransactionType.split:
        return Icons.call_split;
      case TransactionType.merger:
        return Icons.merge;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to start tracking your portfolio performance',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTransactionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TransactionType>(
              value: _selectedTypeFilter,
              decoration: const InputDecoration(labelText: 'Transaction Type'),
              items: TransactionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedTypeFilter = value),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date Range'),
              subtitle: _selectedDateRange != null
                  ? Text(
                      '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                    )
                  : const Text('All dates'),
              trailing: const Icon(Icons.date_range),
              onTap: _selectDateRange,
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
              _applyFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _AddTransactionDialog extends StatefulWidget {
  const _AddTransactionDialog();

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _stockIdController = TextEditingController();
  final _stockNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _brokerageController = TextEditingController();
  final _feesController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.buy;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _stockIdController.dispose();
    _stockNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _brokerageController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockIdController,
                decoration: const InputDecoration(labelText: 'Stock ID/Symbol'),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockNameController,
                decoration: const InputDecoration(labelText: 'Stock Name'),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per Share'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feesController,
                decoration: const InputDecoration(labelText: 'Fees (optional)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty == true && double.tryParse(value!) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brokerageController,
                decoration: const InputDecoration(labelText: 'Brokerage (optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.date_range),
                onTap: _selectDate,
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
        TextButton(
          onPressed: _saveTransaction,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      final fees = _feesController.text.isNotEmpty 
          ? double.parse(_feesController.text) 
          : null;
      
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stockId: _stockIdController.text,
        stockName: _stockNameController.text,
        type: _selectedType,
        quantity: quantity,
        price: price,
        totalValue: quantity * price,
        date: _selectedDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        brokerage: _brokerageController.text.isNotEmpty ? _brokerageController.text : null,
        fees: fees,
      );
      
      Navigator.of(context).pop(transaction);
    }
  }
}