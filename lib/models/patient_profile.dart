class PatientProfile {
  const PatientProfile({
    required this.name,
    required this.email,
    required this.phone,
    this.img,
    this.address,
    this.lastModified,
  });

  factory PatientProfile.fromResponse(Object? json) {
    if (json is! Map<String, dynamic> || json['success'] != true) {
      throw const FormatException('Patient profile response is invalid.');
    }

    final data = json['data'];
    final profileData = data is Map<String, dynamic> ? data['patient'] ?? data : data;
    final profile = switch (profileData) {
      List values when values.isNotEmpty => values.first,
      Map<String, dynamic> value => value,
      _ => null,
    };
    if (profile == null) {
      throw const FormatException('Patient profile data is missing.');
    }
    if (profile is! Map<String, dynamic>) {
      throw const FormatException('Patient profile data is invalid.');
    }

    return PatientProfile(
      name: _requiredString(profile, 'name'),
      email: _requiredString(profile, 'email'),
      phone: _requiredString(profile, 'phone'),
      img: _optionalString(profile, 'img'),
      address: _optionalString(profile, 'address'),
      lastModified: _optionalString(profile, 'last_modified'),
    );
  }

  final String name;
  final String email;
  final String phone;
  final String? img;
  final String? address;
  final String? lastModified;

  PatientProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? img,
    String? lastModified,
  }) {
    return PatientProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      img: img ?? this.img,
      address: address ?? this.address,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Patient profile $key is invalid.');
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('Patient profile $key is invalid.');
  }
  return value;
}
