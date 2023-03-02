import 'package:agora_video/data/models/token.dart';
import 'package:agora_video/data/web_services/token_web_services.dart';

class TokenRepository{
  TokenWebServices tokenWebServices;
  TokenRepository(this.tokenWebServices);
  Future<Token> getToken(String channelName) async {
    final token = await tokenWebServices.getToken(channelName);
    // print(fiveDayData);
    return Token.fromJson(token);
  }
}