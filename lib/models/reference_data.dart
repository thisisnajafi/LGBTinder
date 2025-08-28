// Reference data models for dropdown options and selections

class Education {
  final int id;
  final String name;
  final String? description;

  const Education({
    required this.id,
    required this.name,
    this.description,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Education && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

class Gender {
  final int id;
  final String name;
  final String? description;

  const Gender({
    required this.id,
    required this.name,
    this.description,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gender && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

class Interest {
  final int id;
  final String name;
  final String? description;
  final String? category;

  const Interest({
    required this.id,
    required this.name,
    this.description,
    this.category,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Interest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

class Job {
  final int id;
  final String name;
  final String? description;
  final String? category;

  const Job({
    required this.id,
    required this.name,
    this.description,
    this.category,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Job && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

class Language {
  final int id;
  final String name;
  final String? code;
  final String? nativeName;

  const Language({
    required this.id,
    required this.name,
    this.code,
    this.nativeName,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      nativeName: json['native_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'native_name': nativeName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Language && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

class MusicGenre {
  final int id;
  final String name;
  final String? description;

  const MusicGenre({
    required this.id,
    required this.name,
    this.description,
  });

  factory MusicGenre.fromJson(Map<String, dynamic> json) {
    return MusicGenre(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicGenre && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

class PreferredGender {
  final int id;
  final String name;
  final String? description;

  const PreferredGender({
    required this.id,
    required this.name,
    this.description,
  });

  factory PreferredGender.fromJson(Map<String, dynamic> json) {
    return PreferredGender(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PreferredGender && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

class RelationGoal {
  final int id;
  final String name;
  final String? description;

  const RelationGoal({
    required this.id,
    required this.name,
    this.description,
  });

  factory RelationGoal.fromJson(Map<String, dynamic> json) {
    return RelationGoal(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelationGoal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}