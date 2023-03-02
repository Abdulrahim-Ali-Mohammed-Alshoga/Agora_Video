import 'package:agora_video/bussness_logc/cubit/call_cubit/call_state.dart';
import 'package:agora_video/data/models/token.dart';
import 'package:agora_video/data/repository/token_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TokenCubit extends Cubit<TokenState>{
  TokenCubit({required this.tokenRepository}):super(TokenInitialState());
  TokenRepository tokenRepository;
  late Token token;
  getToken(String channelName) async {


    try {
      token =
      await tokenRepository.getToken(channelName);

      emit(TokenSuccess());
    }
       catch (e) {
      print(e);
      // print(e);
    }
  }
}