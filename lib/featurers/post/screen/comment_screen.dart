import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/featurers/post/controller/post_controller.dart';
import 'package:reddit/featurers/post/widget/comment_card.dart';

import '../../../Models/post_model.dart';
import '../../auth/controller/auth_controller.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key,required this.postId});

  @override
  ConsumerState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {

  final commentController=TextEditingController();
  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }
  void addComment(Post post){
    ref.read(postControllerProvider.notifier).addComment(
        context: context,
        text: commentController.text.trim(),
        post: post);
    setState(() {
      commentController.text="";
    });
  }

  @override
  Widget build(BuildContext context) {

    final user=ref.watch(userProvider)!;
    final isGuest= !user.isAuthenticated;

    return Scaffold(
      body: ref.watch(getPostByIdProvider(widget.postId)).
      when(data: (data) {
        return Column(
          children: [
            PostCard(post: data),
            const SizedBox(height: 10,),
            if(!isGuest)
            TextField(
              onSubmitted: (value) => addComment(data),
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'what are your thoughts?',
                filled: true,
                border: InputBorder.none
              ),
            ),
            ref.watch(getPostCommentsProvider(widget.postId))
                .when(data: (data) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                        itemBuilder: (context, index) {
                        final comment=data[index];
                        return CommentCard(comment: comment);
                        },
                    ),
                  );
            },
                error: (error, stackTrace) => ErrorText(error: error.toString()),
                loading: () => const Loader(),)
          ],
        );
      },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),),
    );
  }
}
