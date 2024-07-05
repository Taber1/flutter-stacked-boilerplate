import 'package:my_first_app/models/post_model.dart';
import 'package:my_first_app/services/api_service.dart';
import '../app/app.locator.dart';

class PostRepository {
  final _apiService = locator<ApiService>();

  Future<List<PostModel>> fetchPosts() async {
    List<dynamic> response = await _apiService.get('posts', showLoader: true);
    return response.map<PostModel>((json) => PostModel.fromJson(json)).toList();
  }

  Future<PostModel> addPosts({Map<String, dynamic>? body}) async {
    Map<String, dynamic> response = await _apiService.post(
      'posts',
      body: body,
      showLoader: true,
    );
    return PostModel.fromJson(response);
  }
}
