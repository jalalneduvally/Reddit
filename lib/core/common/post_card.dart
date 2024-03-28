import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/featurers/Community/controller/community_controller.dart';
import 'package:reddit/featurers/auth/controller/auth_controller.dart';
import 'package:reddit/featurers/post/controller/post_controller.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../Models/post_model.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key,required this.post});
  
  void deletePost(WidgetRef ref,BuildContext context)async{
    ref.read(postControllerProvider.notifier).deletePost(post,context);
  }
  void upVotePost(WidgetRef ref)async{
    ref.read(postControllerProvider.notifier).upVote(post);
  }
  void downVotePost(WidgetRef ref)async{
    ref.read(postControllerProvider.notifier).downVote(post);
  }

  void awardPost(WidgetRef ref,String award,BuildContext context)async{
    ref.read(postControllerProvider.notifier).awardPost(award: award,context: context,post: post);
  }
  
  void navigateToUser(BuildContext context){
    Routemaster.of(context).push("/u/${post.uid}");
  }
  void navigateToCommunity(BuildContext context){
    Routemaster.of(context).push("/r/${post.communityName}");
  }

  void navigateToComment(BuildContext context){
    Routemaster.of(context).push("/post/${post.id}/comments");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage =post.type == "image";
    final isTypeText =post.type == "text";
    final isTypeLink =post.type == "link";
    final user=ref.watch(userProvider)!;
    final isGuest= !user.isAuthenticated;
    final currentTheme=ref.watch(themeNotifierProvider);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.drawerTheme.backgroundColor
          ),
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ).copyWith(right: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => navigateToCommunity(context),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(post.communityProfilePic),
                                      radius: 16,
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("r/${post.communityName}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                      ),),
                                      GestureDetector(
                                        onTap: () => navigateToUser(context),
                                        child: Text("u/${post.username}",
                                          style: TextStyle(
                                              fontSize: 12,
                                          ),),
                                      ),
                                    ],
                                  ),),
                                ],
                              ),
                              if(post.uid==user.uid)
                                IconButton(
                                    onPressed: ()=>deletePost(ref,context),
                                    icon: Icon(Icons.delete,color: Pallete.redColor,))
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top:10.0),
                            child: Text(post.title,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold
                              ),),
                          ),
                          if(isTypeImage)
                            SizedBox(
                              height: MediaQuery.of(context).size.height*0.35,
                              width: double.infinity,
                              child: Image.network(post.link!,fit: BoxFit.cover,),
                            ),
                          if(isTypeLink)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              child:AnyLinkPreview(
                                displayDirection: UIDirection.uiDirectionHorizontal,
                                  link: post.link!),
                            ),
                          if(isTypeText)
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(post.description!,
                              style: TextStyle(
                                color: Colors.grey
                              ),),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(onPressed: isGuest?(){}: ()=> upVotePost(ref),
                                      icon: Icon(Constants.up,
                                        size: 30,
                                      color: post.upvotes.contains(user.uid)?Pallete.redColor:null,)
                                  ),
                                  Text('${post.upvotes.length - post.downvotes.length==0?'Vote':post.upvotes.length - post.downvotes.length}',
                                  style: TextStyle(
                                    fontSize: 17
                                  ),),
                                  IconButton(onPressed:isGuest?(){}: ()=>downVotePost(ref),
                                      icon: Icon(Constants.down,
                                        size: 30,
                                        color: post.downvotes.contains(user.uid)?Pallete.blueColor:null,)
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(onPressed: ()=>navigateToComment(context),
                                      icon: Icon(Icons.comment,)
                                  ),
                                  Text('${post.commentCount == 0?'Comment':post.commentCount}',
                                    style: TextStyle(
                                        fontSize: 17
                                    ),),
                                ],
                              ),
                              ref.watch(getCommunityBynameProvider(post.communityName)).
                              when(data: (data) {
                                if(data.mods.contains(user.uid)){
                                  return IconButton(onPressed: ()=>deletePost(ref, context),
                                      icon: Icon(Icons.admin_panel_settings,)
                                  );
                                }
                                return SizedBox();
                              } ,
                                  error: (error, stackTrace) => ErrorText(error: error.toString()),
                                  loading: () => Loader(),),

                              IconButton(
                                  onPressed:isGuest?(){}:
                                      () {
                                showDialog(context: context,
                                  builder: (context) => Dialog(
                                   child: Padding(
                                     padding: EdgeInsets.all(20),
                                     child: GridView.builder(
                                       shrinkWrap: true,
                                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                             crossAxisCount: 4),
                                         itemCount: user.awards.length,
                                         itemBuilder: (context, index) {
                                           final award =user.awards[index];
                                           return GestureDetector(
                                             onTap: () => awardPost(ref, award, context),
                                             child: Padding(
                                               padding: const EdgeInsets.all(8.0),
                                               child: Image.asset(Constants.awards[award]!),
                                             ),
                                           );
                                         },),
                                   ),
                                  ),);
                              },
                                  icon: const Icon(Icons.card_giftcard_outlined))
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 10,),
      ],
    );
  }
}
