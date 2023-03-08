class Token{
   String? tokenUnique;


  Token.fromJson(Map<String, dynamic> json) {
    tokenUnique = json["token"];
  }
}