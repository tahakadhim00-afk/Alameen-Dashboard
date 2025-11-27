import 'package:flutter/material.dart';

import '../models/subscriber.dart';
import '../utils/app_strings.dart';

class SubscriberDetailScreen extends StatelessWidget {
  final Subscriber subscriber;

  const SubscriberDetailScreen({super.key, required this.subscriber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subscriber.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscriber.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    subscriber.phone,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 16.0),
                  Divider(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  ),
                  _buildDetailRow(
                    context,
                    AppStrings.subscriptionStartDate,
                    subscriber.subscriptionStartDate
                        .toLocal()
                        .toIso8601String()
                        .split('T')[0],
                    Icons.calendar_today,
                  ),
                  _buildDetailRow(
                    context,
                    AppStrings.price,
                    '${subscriber.price.toStringAsFixed(2)} IQD',
                    Icons.attach_money,
                  ),
                  _buildDetailRow(
                    context,
                    AppStrings.paidStatus,
                    subscriber.isPaid
                        ? AppStrings.paidText
                        : AppStrings.unpaidText,
                    subscriber.isPaid ? Icons.check_circle : Icons.cancel,
                    valueColor: subscriber.isPaid ? Colors.green : Colors.red,
                  ),
                  _buildDetailRow(
                    context,
                    AppStrings.daysSinceSubscription,
                    '${subscriber.daysCount} ${AppStrings.days}',
                    Icons.timelapse,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(
        subtitle,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color),
      ),
    );
  }
}
