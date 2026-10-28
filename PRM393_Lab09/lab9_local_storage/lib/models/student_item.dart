class StudentItem {
  final int id;
  final String studentCode;
  final String fullName;
  final String major;
  final double gpa;
  final String email;
  final String phone;

  const StudentItem({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.major,
    required this.gpa,
    required this.email,
    required this.phone,
  });

  factory StudentItem.fromJson(Map<String, dynamic> json) {
    return StudentItem(
      id: json['id'] as int? ?? 0,
      studentCode: json['studentCode'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      major: json['major'] as String? ?? 'General',
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0.0,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentCode': studentCode,
    'fullName': fullName,
    'major': major,
    'gpa': gpa,
    'email': email,
    'phone': phone,
  };

  StudentItem copyWith({
    int? id,
    String? studentCode,
    String? fullName,
    String? major,
    double? gpa,
    String? email,
    String? phone,
  }) {
    return StudentItem(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      fullName: fullName ?? this.fullName,
      major: major ?? this.major,
      gpa: gpa ?? this.gpa,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
