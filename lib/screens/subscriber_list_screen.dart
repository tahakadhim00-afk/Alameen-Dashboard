import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database_helper.dart';
import '../models/subscriber.dart';
import '../utils/app_strings.dart';
import 'settings_screen.dart';
import 'subscriber_detail_screen.dart';
import 'subscriber_form_screen.dart';

class SubscriberListScreen extends StatefulWidget {
  const SubscriberListScreen({super.key});

  @override
  State<SubscriberListScreen> createState() => _SubscriberListScreenState();
}

class _SubscriberListScreenState extends State<SubscriberListScreen> {
  late Future<List<Subscriber>> _subscribers;
  final _searchController = TextEditingController();
  double _totalSubscriptions = 0.0;
  int _totalSubscribersCount = 0;
  int _paidSubscribersCount = 0;
  int _unpaidSubscribersCount = 0;
  bool? _selectedPaidStatus;
  bool _sortPaidFirst = false;

  @override
  void initState() {
    super.initState();
    _subscribers = _fetchAndCalculateSubscribers();
    _searchController.addListener(_filterSubscribers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Subscriber>> _fetchAndCalculateSubscribers({
    String? query,
    bool? isPaid,
  }) async {
    final allSubscribers = await DatabaseHelper().getSubscribers();
    double total = 0.0;
    int paidCount = 0;
    int unpaidCount = 0;

    for (final subscriber in allSubscribers) {
      total += subscriber.price;
      if (subscriber.isPaid) {
        paidCount++;
      } else {
        unpaidCount++;
      }
    }

    if (mounted) {
      setState(() {
        _totalSubscriptions = total;
        _totalSubscribersCount = allSubscribers.length;
        _paidSubscribersCount = paidCount;
        _unpaidSubscribersCount = unpaidCount;
      });
    }

    List<Subscriber> filteredSubscribers = allSubscribers;

    if (isPaid != null) {
      filteredSubscribers =
          filteredSubscribers.where((s) => s.isPaid == isPaid).toList();
    }

    if (query != null && query.isNotEmpty) {
      filteredSubscribers = filteredSubscribers
          .where((s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.phone.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (_sortPaidFirst) {
      filteredSubscribers.sort((a, b) {
        if (!a.isPaid && b.isPaid) {
          return -1;
        } else if (a.isPaid && !b.isPaid) {
          return 1;
        } else {
          return 0;
        }
      });
    }

    return filteredSubscribers;
  }

  Future<void> _refreshSubscriberList() async {
    setState(() {
      _subscribers = _fetchAndCalculateSubscribers(
        query: _searchController.text,
        isPaid: _selectedPaidStatus,
      );
    });
  }

  void _filterSubscribers() {
    setState(() {
      _subscribers = _fetchAndCalculateSubscribers(
        query: _searchController.text,
        isPaid: _selectedPaidStatus,
      );
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool? isPaid, {
    bool isFilter = true,
  }) {
    final cardContent = Container(
      width: 180,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: (isFilter && _selectedPaidStatus == isPaid)
            ? color.withOpacity(0.3)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15.0),
        border: (isFilter && _selectedPaidStatus == isPaid)
            ? Border.all(color: color, width: 2.0)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );

    if (isFilter) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedPaidStatus = isPaid;
            _refreshSubscriberList();
          });
        },
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(_sortPaidFirst ? Icons.sort_by_alpha : Icons.sort),
            onPressed: () {
              setState(() {
                _sortPaidFirst = !_sortPaidFirst;
                _refreshSubscriberList();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: AppStrings.searchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatCard(
                  AppStrings.totalSubscribers,
                  '$_totalSubscribersCount',
                  Icons.people,
                  Colors.blue,
                  null,
                  isFilter: true,
                ),
                _buildStatCard(
                  AppStrings.paid,
                  '$_paidSubscribersCount',
                  Icons.payments,
                  Colors.green,
                  true,
                  isFilter: true,
                ),
                _buildStatCard(
                  AppStrings.unpaid,
                  '$_unpaidSubscribersCount',
                  Icons.payment_outlined,
                  Colors.orange,
                  false,
                  isFilter: true,
                ),
                _buildStatCard(
                  AppStrings.totalPrice,
                  _totalSubscriptions.toStringAsFixed(2),
                  Icons.attach_money,
                  Colors.red,
                  null,
                  isFilter: false,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Subscriber>>(
              future: _subscribers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info,
                          size: 200,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noSubscribersFound,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final subscriber = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SubscriberDetailScreen(subscriber: subscriber),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: subscriber.isPaid
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  child: Icon(
                                    subscriber.isPaid ? Icons.check : Icons.close,
                                    color: subscriber.isPaid ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subscriber.name,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        subscriber.phone,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.phone, color: Colors.blueAccent),
                                      onPressed: () => _makePhoneCall(subscriber.phone),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SubscriberFormScreen(subscriber: subscriber),
                                          ),
                                        );
                                        _refreshSubscriberList();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(AppStrings.confirmDeletion),
                                              content: Text(AppStrings.deleteConfirmationMessage),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(false),
                                                  child: Text(AppStrings.cancel),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(true),
                                                  child: Text(AppStrings.delete),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmed == true) {
                                          await DatabaseHelper().deleteSubscriber(subscriber.id!);
                                          _refreshSubscriberList();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriberFormScreen(),
            ),
          );
          _refreshSubscriberList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
