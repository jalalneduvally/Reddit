import 'package:flutter/material.dart';
import 'package:reddit/featurers/Community/screens/add_mods_screen.dart';
import 'package:reddit/featurers/Community/screens/community_screen.dart';
import 'package:reddit/featurers/Community/screens/create_community_screen.dart';
import 'package:reddit/featurers/Community/screens/edit_community_screen.dart';
import 'package:reddit/featurers/Community/screens/mod_tools_screen.dart';
import 'package:reddit/featurers/Home/screen/home_screen.dart';
import 'package:reddit/featurers/auth/screen/login_screen.dart';
import 'package:reddit/featurers/post/screen/add_post_type_screen.dart';
import 'package:reddit/featurers/post/screen/comment_screen.dart';
import 'package:reddit/featurers/user_profile/screens/edit_profile_screen.dart';
import 'package:reddit/featurers/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRouter =RouteMap(routes:{
  '/':(_) => MaterialPage(child: LoginScreen()),
},);
final loggedInRouter =RouteMap(routes:{
  '/':(_) => MaterialPage(child: HomeScreen()),
  '/create-community':(_) => MaterialPage(child: CreateCommunityScreen()),
  '/r/:name':(route) => MaterialPage(child: CommunityScreen(
      name: route.pathParameters['name']!)),
  '/mod-tools/:name':(routerData) => MaterialPage(child: ModToolsScreen(
    name: routerData.pathParameters['name']!,)),
  '/edit-community/:name':(routerData) => MaterialPage(child: EditCommunityScreen(
    name: routerData.pathParameters['name']!,)),
  '/add-mods/:name':(routerData) => MaterialPage(child: AddModsScreen(
    name: routerData.pathParameters['name']!,)),
  '/u/:uid':(routerData) => MaterialPage(child: UserProfileScreen(
    uid: routerData.pathParameters['uid']!,)),
  '/edit-profile/:uid':(routerData) => MaterialPage(child: EditProfileScreen(
    uid: routerData.pathParameters['uid']!,)),
  '/add-post/:type':(routerData) => MaterialPage(child: AddPostTypeScreen(
    type: routerData.pathParameters['type']!,)),
  '/post/:postId/comments':(router) => MaterialPage(child: CommentsScreen(
    postId: router.pathParameters['postId']!,)),
},);