import 'package:flutter/material.dart';
import 'package:my_first_app/models/post_model.dart';
import 'package:my_first_app/ui/common/app_colors.dart';
import 'package:my_first_app/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'posts_viewmodel.dart';

class PostsView extends StackedView<PostsViewModel> {
  const PostsView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(PostsViewModel viewModel) async {
    await viewModel.onInit();
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    PostsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "Posts",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await viewModel.addPosts(
              body: {
                'title': 'foo',
                'body': 'bar',
                'userId': 1,
              },
            );
          },
          child: const Icon(
            Icons.add,
            color: AppColors.kcBlackColor,
          ),
        ),
        body: viewModel.listPosts.isNotEmpty
            ? ListView.builder(
                itemCount: viewModel.listPosts.length,
                itemBuilder: (context, index) {
                  PostModel post = viewModel.listPosts[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          verticalSpaceSmall,
                          Text(post.body!),
                        ],
                      ),
                    ),
                  );
                },
              )
            : verticalSpaceSmall);
  }

  @override
  PostsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PostsViewModel();
}
