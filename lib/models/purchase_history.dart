import 'package:flutter/foundation.dart';

class PurchaseHistory {
  final int id;
  final int userId;
  final String purchaseType; // 'subscription' or 'superlike_pack'
  final double amount;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final String? receiptUrl;
  final Map<String, dynamic>? purchaseDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PurchaseHistory({
    required this.id,
    required this.userId,
    required this.purchaseType,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.receiptUrl,
    this.purchaseDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      purchaseType: json['purchase_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      transactionId: json['transaction_id'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      purchaseDetails: json['purchase_details'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'purchase_type': purchaseType,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'receipt_url': receiptUrl,
      'purchase_details': purchaseDetails,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PurchaseHistory copyWith({
    int? id,
    int? userId,
    String? purchaseType,
    double? amount,
    String? status,
    String? paymentMethod,
    String? transactionId,
    String? receiptUrl,
    Map<String, dynamic>? purchaseDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      purchaseType: purchaseType ?? this.purchaseType,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      purchaseDetails: purchaseDetails ?? this.purchaseDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if purchase was successful
  bool get isSuccessful => status == 'completed' || status == 'success';

  // Check if purchase is pending
  bool get isPending => status == 'pending' || status == 'processing';

  // Check if purchase failed
  bool get isFailed => status == 'failed' || status == 'cancelled' || status == 'refunded';

  // Check if purchase is a subscription
  bool get isSubscription => purchaseType == 'subscription';

  // Check if purchase is a superlike pack
  bool get isSuperlikePack => purchaseType == 'superlike_pack';

  // Get purchase type display text
  String get purchaseTypeDisplay {
    switch (purchaseType) {
      case 'subscription':
        return 'Subscription';
      case 'superlike_pack':
        return 'Superlike Pack';
      default:
        return purchaseType;
    }
  }

  // Get status display text
  String get statusDisplay {
    switch (status) {
      case 'completed':
      case 'success':
        return 'Completed';
      case 'pending':
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  // Get payment method display text
  String get paymentMethodDisplay {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return paymentMethod;
    }
  }

  // Get formatted amount
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  // Get purchase date display
  String get purchaseDateDisplay {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()} weeks ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Get purchase details for display
  String get purchaseDetailsDisplay {
    if (purchaseDetails == null) return '';
    
    if (isSubscription) {
      final planName = purchaseDetails!['plan_name'] ?? 'Unknown Plan';
      final duration = purchaseDetails!['duration'] ?? '';
      return '$planName - $duration';
    } else if (isSuperlikePack) {
      final quantity = purchaseDetails!['quantity'] ?? 0;
      return '$quantity Superlikes';
    }
    
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseHistory &&
        other.id == id &&
        other.userId == userId &&
        other.purchaseType == purchaseType &&
        other.amount == amount &&
        other.status == status &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, purchaseType, amount, status, transactionId);
  }

  @override
  String toString() {
    return 'PurchaseHistory(id: $id, type: $purchaseTypeDisplay, amount: $formattedAmount, status: $statusDisplay)';
  }
}
