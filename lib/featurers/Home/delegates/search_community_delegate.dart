import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/featurers/Community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityelegate extends SearchDelegate{
  final WidgetRef ref;
  SearchCommunityelegate(this.ref);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () {
        query ="";
      }, icon: Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
   return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
   return ref.watch(searchCommunityProvider(query)).when(
      data: (communities) =>ListView.builder(
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community=communities[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(community.avatar),
            ),
            title: Text('r/${community.name}'),
            onTap: () => navigateToCommunity(context, community.name),
          );
        } ,) ,
        error:(error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => Loader(),);
  }
  void navigateToCommunity(BuildContext context,String communityName){
    Routemaster.of(context).push('/r/${communityName}');
  }
}