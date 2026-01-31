/// User credit balance and transactions
class CreditBalance {
  final int balance;
  final List<CreditTransaction> transactions;
  final DateTime lastUpdated;

  CreditBalance({
    required this.balance,
    required this.transactions,
    required this.lastUpdated,
  });

  /// Create from JSON
  factory CreditBalance.fromJson(Map<String, dynamic> json) {
    return CreditBalance(
      balance: json['balance'] as int? ?? 0,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => CreditTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  /// Check if user has enough credits for an operation
  bool hasEnough(int amount) => balance >= amount;

  /// Get formatted balance display
  String get formattedBalance => balance.toString();
}

/// Credit transaction record
class CreditTransaction {
  final String id;
  final int amount;
  final CreditTransactionType type;
  final String? description;
  final String? referenceId;
  final DateTime createdAt;

  CreditTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    this.referenceId,
    required this.createdAt,
  });

  /// Create from JSON
  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'] as String,
      amount: json['amount'] as int,
      type: _parseType(json['type'] as String?),
      description: json['description'] as String?,
      referenceId: json['reference_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Check if this is a credit (positive)
  bool get isCredit => amount > 0;

  /// Check if this is a debit (negative)
  bool get isDebit => amount < 0;

  /// Get display amount (always positive with +/- prefix)
  String get displayAmount => isCredit ? '+$amount' : '$amount';

  static CreditTransactionType _parseType(String? value) {
    switch (value?.toLowerCase()) {
      case 'purchase':
        return CreditTransactionType.purchase;
      case 'bonus':
        return CreditTransactionType.bonus;
      case 'refund':
        return CreditTransactionType.refund;
      case 'ai_generation':
        return CreditTransactionType.aiGeneration;
      case 'subscription':
        return CreditTransactionType.subscription;
      case 'usage':
      default:
        return CreditTransactionType.usage;
    }
  }
}

/// Credit transaction type
enum CreditTransactionType {
  purchase,      // User bought credits
  bonus,         // Free bonus credits
  refund,        // Refund from failed operation
  usage,         // General usage
  aiGeneration,  // AI generation cost
  subscription,  // Subscription credits
}

/// Extension for transaction type display
extension CreditTransactionTypeExtension on CreditTransactionType {
  String get displayName {
    switch (this) {
      case CreditTransactionType.purchase:
        return 'Satın Alma';
      case CreditTransactionType.bonus:
        return 'Bonus';
      case CreditTransactionType.refund:
        return 'İade';
      case CreditTransactionType.usage:
        return 'Kullanım';
      case CreditTransactionType.aiGeneration:
        return 'AI Üretim';
      case CreditTransactionType.subscription:
        return 'Abonelik';
    }
  }

  String get icon {
    switch (this) {
      case CreditTransactionType.purchase:
        return '💳';
      case CreditTransactionType.bonus:
        return '🎁';
      case CreditTransactionType.refund:
        return '↩️';
      case CreditTransactionType.usage:
        return '⚡';
      case CreditTransactionType.aiGeneration:
        return '✨';
      case CreditTransactionType.subscription:
        return '👑';
    }
  }
}

/// Credit package for purchase
class CreditPackage {
  final String id;
  final String name;
  final int credits;
  final double priceUsd;
  final int? bonusCredits;
  final bool isPopular;

  CreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceUsd,
    this.bonusCredits,
    this.isPopular = false,
  });

  /// Total credits including bonus
  int get totalCredits => credits + (bonusCredits ?? 0);

  /// Price per credit
  double get pricePerCredit => priceUsd / totalCredits;

  /// Formatted price display
  String get formattedPrice => '\$${priceUsd.toStringAsFixed(2)}';
}

/// Predefined credit packages
class CreditPackages {
  static final List<CreditPackage> packages = [
    CreditPackage(
      id: 'starter',
      name: 'Başlangıç',
      credits: 50,
      priceUsd: 4.99,
    ),
    CreditPackage(
      id: 'popular',
      name: 'Popüler',
      credits: 150,
      priceUsd: 9.99,
      bonusCredits: 20,
      isPopular: true,
    ),
    CreditPackage(
      id: 'pro',
      name: 'Pro',
      credits: 500,
      priceUsd: 29.99,
      bonusCredits: 100,
    ),
    CreditPackage(
      id: 'unlimited',
      name: 'Sınırsız',
      credits: 2000,
      priceUsd: 99.99,
      bonusCredits: 500,
    ),
  ];
}
