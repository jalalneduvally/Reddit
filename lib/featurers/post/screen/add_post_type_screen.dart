import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/featurers/Community/controller/community_controller.dart';
import 'package:reddit/featurers/post/controller/post_controller.dart';
import 'dart:io';
import '../../../Models/community_model.dart';
import '../../../core/providers/utills.dart';
import '../../../theme/pallete.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key,required this.type});

  @override
  ConsumerState createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {

  File?bannerFile;
  final titleController=TextEditingController();
  final descriptionController=TextEditingController();
  final linkController=TextEditingController();
  List<Community> communities=[];
  Community? selectedCommunity;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }
  void selectBannerImage() async {
    final res= await PickImage();
    if(res !=null){
      setState(() {
        bannerFile=File(res.files.first.path!);
      });
    }
  }
  void sharePost(){
    if(widget.type=="image" && bannerFile !=null && titleController.text.isNotEmpty){
      ref.read(postControllerProvider.notifier).
      shareImagePost(context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity ??communities [0],
          file: bannerFile
      );
    }else if(widget.type=="text" && titleController.text.isNotEmpty){
      ref.read(postControllerProvider.notifier).
      shareTextPost(context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity ??communities [0],
              description: descriptionController.text.trim()
      );
    }else if(widget.type=="link" && titleController.text.isNotEmpty && linkController.text.isNotEmpty){
      ref.read(postControllerProvider.notifier).
      shareLinkPost(context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity ??communities [0],
          link: linkController.text.trim()
      );
    }else{
      showSnackBar(context, "Please Enter valid fields");
    }
  }

  @override
  Widget build(BuildContext context) {

    final isTypeImage =widget.type == "image";
    final isTypeText =widget.type == "text";
    final isTypeLink =widget.type == "link";
    final currentTheme=ref.watch(themeNotifierProvider);
    final isLoading=ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("post ${widget.type}"),
          actions: [
            TextButton(
                onPressed: sharePost,
                child: const Text("Share"))
          ]
      ),
      body: isLoading?
       const Loader(): Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              maxLength: 30,
              decoration: const InputDecoration(
                hintText: "Enter Title Here",
                filled: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18)
              ),
            ),
            const SizedBox(height: 10,),
            if(isTypeImage)
            GestureDetector(
              onTap: selectBannerImage,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                dashPattern: const [10,4],
                strokeCap: StrokeCap.round,
                color: currentTheme.textTheme.bodyText2!.color!,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child:bannerFile!=null?
                  Image.file(bannerFile!):
                  const Center(child: Icon(Icons.camera_alt_outlined,size: 40,),),
                ),),
            ),
            if(isTypeText)
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                    hintText: "Enter Description here",
                    filled: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                ),
                maxLines: 5,
              ),
            if(isTypeLink)
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  hintText: "Enter Description here",
                  filled: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            const SizedBox(height: 20,),
            const Align(
              alignment: Alignment.topLeft,
                child: Text("Select Community")),
            ref.watch(userCommunitiesProvider).when(
                data: (data) {
                  communities =data;
                  if(data.isEmpty){
                    return SizedBox();
                  }
                  return DropdownButton(
                    value: selectedCommunity ?? data[0],
                    items: data.map((e) =>
                      DropdownMenuItem(
                        value: e,
                          child: Text(e.name))).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCommunity =value;
                        });
                      },);
                },
                error: (error, stackTrace) => ErrorText(error: error.toString()),
                loading: () => Loader(),)
          ],
        ),
      ),
    );
  }
}