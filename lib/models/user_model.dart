// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String email;
  final String name;
  final String? profilePic;
  final String token;
  final String uid;

  UserModel(
      {required this.email,
      required this.name,
       this.profilePic,
      required this.token,
      required this.uid});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'profilePic': profilePic,
      'token': token,
      'uid': uid,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
    email: map['email'] ?? "",
      name: map['name'] ?? "",
      profilePic: map['profilePic'] ?? "",
      token: map['token']  ?? "",
      uid: map['_id'] ?? "",  
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  UserModel copyWith({
    String? email,
    String? name,
    String? profilePic,
    String? token,

    String? uid,
 } ) {

    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      token: token ?? this.token,
      uid: uid ?? this.uid,
    );
  }

  
 }
  
   
