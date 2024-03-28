import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/Models/user_model.dart';
import 'package:reddit/core/enums/enums.dart';
import '../../../Models/post_model.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/providers/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/providers/typedef.dart';

final userProfileRepositoryProvider =Provider((ref) {
  return UserProfileRepository(firestore: ref.watch(firestoreProvider));
});

class UserProfileRepository{
  final FirebaseFirestore _firestore;
  UserProfileRepository( {required FirebaseFirestore firestore}):_firestore=firestore;

  CollectionReference get _user => _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _post => _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid edithProfile(UserModel user)async{
    try{
      return Right(_user.doc(user.uid).update(user.toMap()));
    }on FirebaseException catch(e){
      throw e.message!;
    } catch(e){
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid){
    return _post.where('uid',isEqualTo: uid).
    orderBy('createdAt',descending: true).snapshots().map(
            (event) => event.docs.map((e) =>
                Post.fromMap(e.data() as Map<String,dynamic>)).toList());
  }

  FutureVoid updateUserKarma(UserModel user)async{
    try{
      return Right(_user.doc(user.uid).update({
        "karma":user.karma
      }));
    }on FirebaseException catch(e){
      throw e.message!;
    } catch(e){
      return left(Failure(e.toString()));
    }
  }
}