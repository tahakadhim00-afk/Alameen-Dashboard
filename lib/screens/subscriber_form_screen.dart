import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database_helper.dart';
import '../models/subscriber.dart';
import '../utils/app_strings.dart';

class SubscriberFormScreen extends StatefulWidget {
  final Subscriber? subscriber;

  const SubscriberFormScreen({super.key, this.subscriber});

  @override
  State<SubscriberFormScreen> createState() => _SubscriberFormScreenState();
}

class _SubscriberFormScreenState extends State<SubscriberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _priceController;
  late bool _isPaid;
  late DateTime _selectedSubscriptionStartDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subscriber?.name ?? '');
    _phoneController = TextEditingController(text: widget.subscriber?.phone ?? '');
    _priceController = TextEditingController(
      text: widget.subscriber?.price.toString() ?? '0.0',
    );
    _isPaid = widget.subscriber?.isPaid ?? false;
    _selectedSubscriptionStartDate =
        widget.subscriber?.subscriptionStartDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveSubscriber() async {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text);

      if (price == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.invalidPriceFormat)),
          );
        }
        return;
      }

      final subscriber = Subscriber(
        id: widget.subscriber?.id,
        name: _nameController.text,
        phone: _phoneController.text,
        subscriptionStartDate: _selectedSubscriptionStartDate,
        price: price,
        isPaid: _isPaid,
      );

      if (widget.subscriber == null) {
        await DatabaseHelper().insertSubscriber(subscriber);
      } else {
        await DatabaseHelper().updateSubscriber(subscriber);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subscriber == null
              ? AppStrings.addSubscriber
              : AppStrings.editSubscriber,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: AppStrings.name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: AppStrings.phone),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterPhoneNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppStrings.subscriptionStartDate,
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_selectedSubscriptionStartDate),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedSubscriptionStartDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedSubscriptionStartDate = pickedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterSubscriptionStartDate;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: AppStrings.price),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterPrice;
                  }
                  if (double.tryParse(value) == null) {
                    return AppStrings.invalidPriceFormat;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(AppStrings.paidStatus),
                value: _isPaid,
                onChanged: (value) {
                  setState(() {
                    _isPaid = value;
                    if (_isPaid) {
                      _priceController.text = '0.0';
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSubscriber,
                child: Text(AppStrings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
