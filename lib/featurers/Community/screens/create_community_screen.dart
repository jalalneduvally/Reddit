import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/featurers/Community/controller/community_controller.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController=TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    communityNameController.dispose();
  }
  void createCommunity(){
    ref.read(communityControllerProvider.notifier).
    createCommunity(
        communityNameController.text.trim(),
        context
    );
  }
  @override
  Widget build(BuildContext context) {
    final isLoading=ref.watch(communityControllerProvider);
    return isLoading?
    const Loader():
    Scaffold(
      appBar: AppBar(
        title: const Text("Create a Community"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
                child: Text("community_name")),
            const SizedBox(height: 10,),
            TextField(
              controller: communityNameController,
              decoration: const InputDecoration(
                hintText: "r/community_name",
                filled: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18),
              ),
              maxLength: 21,
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(20)
                )
              ),
                onPressed: () =>createCommunity(), child: Text("Create Community",
            style: TextStyle(
              fontSize: 17
            ),)),
          ],
        ),
      ),
    );
  }
}
