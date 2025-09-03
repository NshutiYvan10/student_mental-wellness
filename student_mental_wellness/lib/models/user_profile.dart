class UserProfile {
  final String uid;
  final String displayName;
  final String avatarUrl;
  final String school;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.avatarUrl,
    required this.school,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'school': school,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String,
        avatarUrl: map['avatarUrl'] as String,
        school: map['school'] as String,
      );
}



