// Base class for reference data items
abstract class ReferenceItem {
  final int id;
  final String title;
  final String? img;

  ReferenceItem({
    required this.id,
    required this.title,
    this.img,
  });
  
  // Alias for title to match the expected interface
  String get name => title;

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Subclasses must implement fromJson');
  }

  Map<String, dynamic> toJson();

  @override
  String toString() => title;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReferenceItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Relationship Goal model (alias for RelationGoal)
class RelationshipGoal extends ReferenceItem {
  final String? subtitle;

  RelationshipGoal({
    required super.id,
    required super.title,
    super.img,
    this.subtitle,
  });

  factory RelationshipGoal.fromJson(Map<String, dynamic> json) {
    return RelationshipGoal(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
      subtitle: json['subtitle'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
      'subtitle': subtitle,
    };
  }
}

// Job/Profession model
class Job extends ReferenceItem {
  Job({
    required super.id,
    required super.title,
    super.img,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
    };
  }
}

// Education model
class Education extends ReferenceItem {
  Education({
    required super.id,
    required super.title,
    super.img,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
    };
  }
}

// Music Genre model
class MusicGenre extends ReferenceItem {
  MusicGenre({
    required super.id,
    required super.title,
    super.img,
  });

  factory MusicGenre.fromJson(Map<String, dynamic> json) {
    return MusicGenre(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
    };
  }
}

// Language model
class Language extends ReferenceItem {
  Language({
    required super.id,
    required super.title,
    super.img,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
    };
  }
}

// Interest/Hobby model
class Interest extends ReferenceItem {
  Interest({
    required super.id,
    required super.title,
    super.img,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
    };
  }
}

// Gender model
class Gender extends ReferenceItem {
  Gender({
    required super.id,
    required super.title,
    super.img,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
    };
  }
}

// Preferred Gender model
class PreferredGender extends ReferenceItem {
  PreferredGender({
    required super.id,
    required super.title,
    super.img,
  });

  factory PreferredGender.fromJson(Map<String, dynamic> json) {
    return PreferredGender(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
    };
  }
}

// Sexual Orientation model
class SexualOrientation extends ReferenceItem {
  final String? description;

  SexualOrientation({
    required super.id,
    required super.title,
    super.img,
    this.description,
  });

  factory SexualOrientation.fromJson(Map<String, dynamic> json) {
    return SexualOrientation(
      id: json['id'],
      title: json['label'] ?? json['title'] ?? '',
      img: json['img'],
      description: json['description'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': title,
      'img': img,
      'description': description,
    };
  }
}

// Relationship Goal model
class RelationGoal extends ReferenceItem {
  final String? subtitle;

  RelationGoal({
    required super.id,
    required super.title,
    super.img,
    this.subtitle,
  });

  factory RelationGoal.fromJson(Map<String, dynamic> json) {
    return RelationGoal(
      id: json['id'],
      title: json['title'] ?? '',
      img: json['img'],
      subtitle: json['subtitle'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img': img,
      'subtitle': subtitle,
    };
  }
}
