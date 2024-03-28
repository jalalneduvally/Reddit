import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/featurers/Community/controller/community_controller.dart';
import 'package:reddit/featurers/post/controller/post_controller.dart';

import '../auth/controller/auth_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final user=ref.watch(userProvider)!;
    final isGuest= !user.isAuthenticated;
    if(!isGuest) {
      return ref.watch(userCommunitiesProvider).when(
        data: (communities) =>
            ref.watch(userPostsProvider(communities)).
            when(data: (data) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final post = data[index];
                  return PostCard(post: post);
                },);
            },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => Loader(),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => Loader(),);

    }
    return ref.watch(userCommunitiesProvider).when(
      data: (communities) => ref.watch(guestPostsProvider).
      when(data: (data) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final post =data[index];
            return PostCard(post: post);
          },);
      },
        error: (error, stackTrace) =>ErrorText(error: error.toString()) ,
        loading: () => Loader(),
      ) ,
      error: (error, stackTrace) =>ErrorText(error: error.toString()) ,
      loading: () => Loader(),);
  }
}
