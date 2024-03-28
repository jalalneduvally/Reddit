import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/Models/user_model.dart';
import 'package:reddit/core/enums/enums.dart';
import 'package:reddit/featurers/auth/controller/auth_controller.dart';
import 'package:reddit/featurers/user_profile/repository/user_profile_repository.dart';
import 'package:routemaster/routemaster.dart';
import 'dart:io';
import '../../../Models/post_model.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/providers/utills.dart';

final userProfileControllerProvider= StateNotifierProvider<UserProfileController,bool>((ref) {
  final userProfileRepository=ref.watch(userProfileRepositoryProvider);
  final storageRepository=ref.watch(storageRepositoryProvider);
  return UserProfileController(
      userProfileRepository: userProfileRepository,
      ref: ref,
      storageRepository: storageRepository);
});

final getuserPostProvider = StreamProvider.family((ref,String uid){
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

class UserProfileController extends StateNotifier<bool>{
  final UserProfileRepository _userProfileRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository}) :
        _userProfileRepository=userProfileRepository,
        _storageRepository=storageRepository,
        _ref=ref,
        super(false);
  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
  })async{
    state=true;
    UserModel user=_ref.read(userProvider)!;
    if (profileFile!=null){
      final res=await _storageRepository.storeFile(
          path: 'users/profile',
          id: user.uid,
          file: profileFile);
      res.fold(
              (l) => showSnackBar(context,l.message),
              (r) => user=user.copyWith(profilePic: r));
    }
    if (bannerFile!=null){
      final res=await _storageRepository.storeFile(
          path: 'users/banner',
          id: user.uid,
          file: bannerFile);
      res.fold(
              (l) => showSnackBar(context,l.message),
              (r) => user=user.copyWith(banner: r));
    }
    user =user.copyWith(name: name);
    final res=await _userProfileRepository.edithProfile(user);
    state=false;
    res.fold(
            (l) => showSnackBar(context,l.message),
            (r) {
              _ref.read(userProvider.notifier).update((state) => user);
              Routemaster.of(context).pop();
            }
    );
  }
  Stream<List<Post>> getUserPosts(String uid){
    return _userProfileRepository.getUserPosts(uid);
  }

  Future<void> updateUserKarma(UserKarma karma) async {
    UserModel user =_ref.read(userProvider)!;
    user =user.copyWith(karma:user.karma + karma.karma);

    final res=await _userProfileRepository.updateUserKarma(user);
    res.fold((l) => null, (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
  }