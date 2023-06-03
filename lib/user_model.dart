class UserModel {
  String? name;
  String? email;
  String? password;
  String? phone;
  String? uId;
  bool? isVolunteer;
  String? image;
   String? cover;
  String? gender;
  String? country;
  String? registration;

  UserModel({
    this.name,
    this.email,
    this.password,
    this.phone,
    this.uId,
    this.isVolunteer,
    this.image,
    this.cover,
    this.gender,
    this.country,
    this.registration,
  });

  UserModel.fromJson(Map<String, dynamic>? json) {
    name = json!['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    uId = json['uId'];
    isVolunteer = json['isVolunteer'];
    image = json['image'];
    cover = json['cover'];
    gender = json['gender'];
    country = json['country'];
    registration = json['registration'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'uId': uId,
      'isVolunteer': isVolunteer,
      'image': image,
      'cover': cover,
      'gender': gender,
      'country': country,
      'registration': registration,
    };
  }
}
