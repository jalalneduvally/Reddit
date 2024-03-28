import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/Models/community_model.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/featurers/Community/controller/community_controller.dart';
import 'package:reddit/featurers/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/post_card.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key,required this.name});

  void navigateToModTools(BuildContext context){
    Routemaster.of(context).push('/mod-tools/$name');
  }
  void joinCommunity(WidgetRef ref,Community community,BuildContext context){
    ref.read(communityControllerProvider.notifier).joinCommunity(community, context);
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user=ref.watch(userProvider)!;
    final isGuest= !user.isAuthenticated;

    return Scaffold(
      body: ref.watch(getCommunityBynameProvider(name)).when(
        data: (community) =>NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(child: Image.network(community.banner,fit: BoxFit.cover,))
                    ],
                  ),
                ),
                SliverPadding(padding: EdgeInsets.all(16),
                sliver: SliverList(
                    delegate: SliverChildListDelegate(
                        [
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                              radius: 35,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('r/${community.name}',style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold
                              ),),
                              if(!isGuest)
                              community.mods.contains(user.uid)?
                              OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 25)
                                ),
                                  onPressed: () {
                                    navigateToModTools(context);
                                  },
                                  child: Text("Mod Tools")):OutlinedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 25)
                                  ),
                                  onPressed: () =>joinCommunity(ref, community, context),
                                  child: Text(community.members.contains(user.uid)?'joined':"join"))
                            ],
                          ),
                          Padding(
                            padding : EdgeInsets.only(top: 10 ),
                            child: Text("${community.members.length} members"),
                          )
                          ]
                    )),)
              ];
            } , body:ref.watch(getCommunityPostProvider(name)).
        when(data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final post =data[index];
              return PostCard(post: post);
            },);
        } ,
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader(),)
        ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => Loader(),),
        );
  }
}
