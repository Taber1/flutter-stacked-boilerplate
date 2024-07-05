import 'package:my_first_app/models/post_model.dart';
import 'package:my_first_app/repository/post_repository.dart';
import 'package:my_first_app/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class PostsViewModel extends BaseViewModel {
  final _postRepository = PostRepository();
  List<PostModel> listPosts = <PostModel>[];

  onInit() async {
    await fetchPosts();
    rebuildUi();
  }

  fetchPosts() async {
    listPosts = await _postRepository.fetchPosts();
  }

  addPosts({Map<String, dynamic>? body}) async {
    await _postRepository.addPosts(body: body);
    showToast(msg: "Post added successfully");
  }
}
