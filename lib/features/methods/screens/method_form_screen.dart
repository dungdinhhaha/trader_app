import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/api/supabase_api.dart';
import '../../../core/models/trade_method_model.dart';
import 'package:uuid/uuid.dart';

class MethodFormScreen extends StatefulWidget {
  final TradeMethod? method; // Null for create, non-null for edit

  const MethodFormScreen({Key? key, this.method}) : super(key: key);

  @override
  State<MethodFormScreen> createState() => _MethodFormScreenState();
}

class _MethodFormScreenState extends State<MethodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ruleController = TextEditingController();
  final _indicatorController = TextEditingController();
  final _timeframeController = TextEditingController();

  List<String> _rules = [];
  List<String> _indicators = [];
  List<String> _timeframes = [];

  bool _isLoading = false;

  bool get _isEditMode => widget.method != null;

  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditMode) {
      // Fill form with existing method data
      _nameController.text = widget.method!.name;
      _descriptionController.text = widget.method!.description;
      _rules = List.from(widget.method!.rules);
      _indicators = List.from(widget.method!.indicators);
      _timeframes = List.from(widget.method!.timeframes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ruleController.dispose();
    _indicatorController.dispose();
    _timeframeController.dispose();
    super.dispose();
  }

  Future<void> _saveMethod() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rules.isEmpty) {
      _showErrorDialog('Please add at least one trading rule');
      return;
    }

    if (_indicators.isEmpty) {
      _showErrorDialog('Please add at least one indicator');
      return;
    }

    if (_timeframes.isEmpty) {
      _showErrorDialog('Please add at least one timeframe');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In production, we would use the SupabaseApi to save the method
      final api = SupabaseApi.instance;

      // Create a new method object
      final method =
          _isEditMode
              ? widget.method!.copyWith(
                name: _nameController.text,
                description: _descriptionController.text,
                rules: _rules,
                indicators: _indicators,
                timeframes: _timeframes,
                updatedAt: DateTime.now(),
              )
              : TradeMethod(
                id: uuid.v4(),
                userId: SupabaseApi.instance.currentUser?.id ?? 'unknown_user',
                name: _nameController.text,
                description: _descriptionController.text,
                rules: _rules,
                indicators: _indicators,
                timeframes: _timeframes,
                createdAt: DateTime.now(),
              );

      // In production, uncomment these lines
      if (_isEditMode) {
        await api.updateTradeMethod(method);
      } else {
        await api.createTradeMethod(method);
      }

      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, method);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving method: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addRule() {
    final rule = _ruleController.text.trim();
    if (rule.isEmpty) return;

    setState(() {
      _rules.add(rule);
      _ruleController.clear();
    });
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  void _addIndicator() {
    final indicator = _indicatorController.text.trim();
    if (indicator.isEmpty) return;

    setState(() {
      _indicators.add(indicator);
      _indicatorController.clear();
    });
  }

  void _removeIndicator(int index) {
    setState(() {
      _indicators.removeAt(index);
    });
  }

  void _addTimeframe() {
    final timeframe = _timeframeController.text.trim();
    if (timeframe.isEmpty) return;

    setState(() {
      _timeframes.add(timeframe);
      _timeframeController.clear();
    });
  }

  void _removeTimeframe(int index) {
    setState(() {
      _timeframes.removeAt(index);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Method' : 'Create Method'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveMethod,
            tooltip: 'Save Method',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Method Name',
              hintText: 'Enter a name for your trading method',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a method name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Description field
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your trading method',
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Rules section
          const Text(
            'Trading Rules',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildRuleInputSection(),
          const SizedBox(height: 8),
          _buildRulesList(),

          const SizedBox(height: 24),

          // Indicators section
          const Text(
            'Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildIndicatorInputSection(),
          const SizedBox(height: 8),
          _buildTagsList(_indicators, _removeIndicator, AppTheme.primaryColor),

          const SizedBox(height: 24),

          // Timeframes section
          const Text(
            'Timeframes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildTimeframeInputSection(),
          const SizedBox(height: 8),
          _buildTagsList(_timeframes, _removeTimeframe, AppTheme.infoColor),

          const SizedBox(height: 32),

          // Save button
          ElevatedButton(
            onPressed: _isLoading ? null : _saveMethod,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isEditMode ? 'Update Method' : 'Create Method',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleInputSection() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _ruleController,
            decoration: const InputDecoration(
              hintText: 'Add a trading rule',
              prefixIcon: Icon(Icons.rule),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          color: AppTheme.primaryColor,
          onPressed: _addRule,
          tooltip: 'Add Rule',
        ),
      ],
    );
  }

  Widget _buildIndicatorInputSection() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _indicatorController,
            decoration: const InputDecoration(
              hintText: 'Add an indicator (e.g., RSI, MACD)',
              prefixIcon: Icon(Icons.bar_chart),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          color: AppTheme.primaryColor,
          onPressed: _addIndicator,
          tooltip: 'Add Indicator',
        ),
      ],
    );
  }

  Widget _buildTimeframeInputSection() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _timeframeController,
            decoration: const InputDecoration(
              hintText: 'Add a timeframe (e.g., 1h, 4h, Daily)',
              prefixIcon: Icon(Icons.access_time),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          color: AppTheme.primaryColor,
          onPressed: _addTimeframe,
          tooltip: 'Add Timeframe',
        ),
      ],
    );
  }

  Widget _buildRulesList() {
    return _rules.isEmpty
        ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No rules added yet',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        )
        : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rules.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: AppTheme.surfaceColor,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(_rules[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.errorColor,
                  onPressed: () => _removeRule(index),
                  tooltip: 'Remove Rule',
                ),
              ),
            );
          },
        );
  }

  Widget _buildTagsList(
    List<String> items,
    Function(int) onRemove,
    Color color,
  ) {
    return items.isEmpty
        ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No items added yet',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        )
        : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            items.length,
            (index) => Chip(
              label: Text(items[index]),
              backgroundColor: color.withOpacity(0.2),
              labelStyle: TextStyle(color: color),
              deleteIcon: Icon(Icons.close, size: 16, color: color),
              onDeleted: () => onRemove(index),
            ),
          ),
        );
  }
}
