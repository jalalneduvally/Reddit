import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/Models/community_model.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/featurers/Community/controller/community_controller.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/providers/utills.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key,required this.name});

  @override
  ConsumerState createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File?bannerFile;
  File?profileFile;
  void selectBannerImage() async {
    final res= await PickImage();
    if(res !=null){
      setState(() {
        bannerFile=File(res.files.first.path!);
      });
    }
  }
  void selectProfileImage() async {
    final res= await PickImage();
    if(res !=null){
      setState(() {
        profileFile=File(res.files.first.path!);
      });
    }
  }
  void save(Community community){
    ref.read(communityControllerProvider.notifier).editCommunity
      (profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        community: community);
  }
  @override
  Widget build(BuildContext context) {
    final isLoading=ref.watch(communityControllerProvider);
    final currentTheme=ref.watch(themeNotifierProvider);

    return ref.watch(getCommunityBynameProvider(widget.name)).when(
        data: (community) => Scaffold(
          backgroundColor: currentTheme.backgroundColor,
          appBar: AppBar(
            // backgroundColor: Pallete.darkModeAppTheme.backgroundColor,
            title: const Text('Edit Community'),
            actions: [
              TextButton(onPressed: () =>save(community) , child:  const Text('Save'))
            ],
          ),
          body:isLoading?const Loader(): Padding(
            padding:  const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: [10,4],
                          strokeCap: StrokeCap.round,
                          color: currentTheme.textTheme.bodyText2!.color!,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child:bannerFile!=null?Image.file(bannerFile!): community.banner.isEmpty || community.banner ==Constants.bannerDefault?
                            const Center(child: Icon(Icons.camera_alt_outlined,size: 40,),) :Image.network(community.banner),
                          ),),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 30,
                        child: GestureDetector(
                          onTap: selectProfileImage,
                          child:profileFile !=null? CircleAvatar(
                            backgroundImage: FileImage(profileFile!),
                            radius: 32,
                        ): CircleAvatar(
                          backgroundImage: NetworkImage(community.avatar),
                          radius: 32,
                        ),
                        )
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        error: (error, stackTrace) {
          if(kDebugMode){
              print(error);
              print(stackTrace);
            }
            return ErrorText(error: error.toString());
        },
        loading: () => Loader(),);

  }
}
