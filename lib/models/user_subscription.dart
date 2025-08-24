import 'package:flutter/foundation.dart';

class UserSubscription {
  final int id;
  final int userId;
  final int planId;
  final int subPlanId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final String? stripeSubscriptionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.subPlanId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
    this.stripeSubscriptionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      planId: json['plan_id'] as int,
      subPlanId: json['sub_plan_id'] as int,
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      autoRenew: json['auto_renew'] as bool,
      stripeSubscriptionId: json['stripe_subscription_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'sub_plan_id': subPlanId,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'auto_renew': autoRenew,
      'stripe_subscription_id': stripeSubscriptionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserSubscription copyWith({
    int? id,
    int? userId,
    int? planId,
    int? subPlanId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool? autoRenew,
    String? stripeSubscriptionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      subPlanId: subPlanId ?? this.subPlanId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      autoRenew: autoRenew ?? this.autoRenew,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if subscription is active
  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);

  // Check if subscription is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  // Check if subscription is cancelled
  bool get isCancelled => status == 'cancelled';

  // Check if subscription is pending
  bool get isPending => status == 'pending';

  // Get days remaining until expiration
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // Get subscription duration in days
  int get durationDays => endDate.difference(startDate).inDays;

  // Get subscription duration in months
  double get durationMonths => durationDays / 30.0;

  // Check if subscription expires soon (within 7 days)
  bool get expiresSoon => daysRemaining <= 7 && daysRemaining > 0;

  // Check if subscription is in grace period (expired but still active)
  bool get isInGracePeriod => isExpired && status == 'active';

  // Get subscription status display text
  String get statusDisplay {
    if (isActive) {
      if (expiresSoon) return 'Expires Soon';
      return 'Active';
    }
    if (isExpired) return 'Expired';
    if (isCancelled) return 'Cancelled';
    if (isPending) return 'Pending';
    return status;
  }

  // Get renewal date display
  String get renewalDateDisplay {
    if (autoRenew && isActive) {
      return 'Renews ${_formatDate(endDate)}';
    } else if (isActive) {
      return 'Expires ${_formatDate(endDate)}';
    }
    return 'Expired ${_formatDate(endDate)}';
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays == 0) return 'today';
    if (difference.inDays == 1) return 'tomorrow';
    if (difference.inDays < 7) return 'in ${difference.inDays} days';
    if (difference.inDays < 30) return 'in ${(difference.inDays / 7).round()} weeks';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSubscription &&
        other.id == id &&
        other.userId == userId &&
        other.planId == planId &&
        other.subPlanId == subPlanId &&
        other.status == status &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, planId, subPlanId, status, startDate, endDate);
  }

  @override
  String toString() {
    return 'UserSubscription(id: $id, planId: $planId, status: $statusDisplay, expires: ${_formatDate(endDate)})';
  }
}
