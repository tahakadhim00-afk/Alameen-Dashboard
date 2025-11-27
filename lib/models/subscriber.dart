class Subscriber {
  final int? id;
  final String name;
  final String phone;
  final DateTime subscriptionStartDate;
  final double price;
  final bool isPaid;

  const Subscriber({
    this.id,
    required this.name,
    required this.phone,
    required this.subscriptionStartDate,
    required this.price,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'subscriptionStartDate': subscriptionStartDate.toIso8601String(),
        'price': price,
        'isPaid': isPaid ? 1 : 0,
      };

  factory Subscriber.fromMap(Map<String, dynamic> map) => Subscriber(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: map['phone'] as String,
        subscriptionStartDate:
            DateTime.tryParse(map['subscriptionStartDate'] as String) ??
                DateTime.now(),
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        isPaid: map['isPaid'] == 1,
      );

  int get daysCount => DateTime.now().difference(subscriptionStartDate).inDays;
}
