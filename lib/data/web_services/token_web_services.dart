import 'package:agora_video/constants/connection.dart';
import 'package:dio/dio.dart';

class TokenWebServices {
  late Dio dio;

  TokenWebServices() {
    BaseOptions baseOptions = BaseOptions(
        receiveTimeout: 10 * 1000,
        baseUrl: Connection.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 10 * 1000);
    dio = Dio(baseOptions);
  }
  Future<dynamic> getToken(String channelName) async {
    Response response = await dio.get(
      "/access_token",
      queryParameters: {"channelName":channelName},
    );
//print(response.data);
    return response.data;
  }
}
