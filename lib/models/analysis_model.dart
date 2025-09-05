class AnalysisModel {
  final String id;
  final String userId;
  final AnalysisType type;
  final AnalysisStatus status;
  final Map<String, dynamic>? result;
  final double price;
  final String? chartImageUrl;
  final Map<String, dynamic> metadata;
  final DateTime? processingStartedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AnalysisModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.result,
    required this.price,
    this.chartImageUrl,
    required this.metadata,
    this.processingStartedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnalysisModel.fromMap(Map<String, dynamic> map) {
    return AnalysisModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: AnalysisType.fromString(map['type'] as String),
      status: AnalysisStatus.fromString(map['status'] as String),
      result: map['result'] as Map<String, dynamic>?,
      price: (map['price'] as num).toDouble(),
      chartImageUrl: map['chart_image_url'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      processingStartedAt: map['processing_started_at'] != null
          ? DateTime.parse(map['processing_started_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'status': status.name,
      'result': result,
      'price': price,
      'chart_image_url': chartImageUrl,
      'metadata': metadata,
      'processing_started_at': processingStartedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AnalysisModel copyWith({
    String? id,
    String? userId,
    AnalysisType? type,
    AnalysisStatus? status,
    Map<String, dynamic>? result,
    double? price,
    String? chartImageUrl,
    Map<String, dynamic>? metadata,
    DateTime? processingStartedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      result: result ?? this.result,
      price: price ?? this.price,
      chartImageUrl: chartImageUrl ?? this.chartImageUrl,
      metadata: metadata ?? this.metadata,
      processingStartedAt: processingStartedAt ?? this.processingStartedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isCompleted => status == AnalysisStatus.completed;
  bool get isProcessing => status == AnalysisStatus.processing;
  bool get isPending => status == AnalysisStatus.pending;
  bool get isFailed => status == AnalysisStatus.failed;

  Duration? get processingDuration {
    if (processingStartedAt == null || completedAt == null) return null;
    return completedAt!.difference(processingStartedAt!);
  }

  // Get formatted price
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  // Get result summary
  String get resultSummary {
    if (result == null || !isCompleted) return 'No results available';

    final prediction = result!['prediction'] as String? ?? 'Unknown';
    final confidence = result!['confidence'] as double? ?? 0.0;
    final targetPrice = result!['target_price'] as double? ?? 0.0;

    return 'Prediction: $prediction (${(confidence * 100).toStringAsFixed(1)}% confidence)\nTarget: \$${targetPrice.toStringAsFixed(2)}';
  }
}

enum AnalysisType {
  quick,
  detailed,
  comprehensive;

  static AnalysisType fromString(String value) {
    return AnalysisType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => AnalysisType.quick,
    );
  }

  String get displayName {
    switch (this) {
      case AnalysisType.quick:
        return 'Quick Analysis';
      case AnalysisType.detailed:
        return 'Detailed Analysis';
      case AnalysisType.comprehensive:
        return 'Comprehensive Analysis';
    }
  }

  String get description {
    switch (this) {
      case AnalysisType.quick:
        return 'Basic technical analysis with key indicators';
      case AnalysisType.detailed:
        return 'Advanced analysis with multiple timeframes';
      case AnalysisType.comprehensive:
        return 'Complete market analysis with AI predictions';
    }
  }

  double get price {
    switch (this) {
      case AnalysisType.quick:
        return 9.99;
      case AnalysisType.detailed:
        return 19.99;
      case AnalysisType.comprehensive:
        return 29.99;
    }
  }
}

enum AnalysisStatus {
  pending,
  processing,
  completed,
  failed;

  static AnalysisStatus fromString(String value) {
    return AnalysisStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AnalysisStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case AnalysisStatus.pending:
        return 'Pending';
      case AnalysisStatus.processing:
        return 'Processing';
      case AnalysisStatus.completed:
        return 'Completed';
      case AnalysisStatus.failed:
        return 'Failed';
    }
  }
}
