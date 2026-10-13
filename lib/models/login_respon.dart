class LoginRespon {
  bool success;
  String message;
  String token;
  LoginRespon({
    required this.success,
    required this.message,
    required this.token,
  });
  factory LoginRespon.formJson(Map<String,dynamic > json)
  {
    return LoginRespon(
      success: json["success"], 
      message: json ["message"], 
      token: json ["token"],
      ); 
  }
}