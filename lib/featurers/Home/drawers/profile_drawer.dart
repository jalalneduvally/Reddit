import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/featurers/auth/controller/auth_controller.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});
  void logOut(WidgetRef ref){
    ref.read(authControllerProvider.notifier).logout();
  }

  void navigateToUserprofile(BuildContext context,String uid){
    Routemaster.of(context).push('/u/$uid');
  }
  void toggleTheme(WidgetRef ref){
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user=ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
            SizedBox(height: 10,),
            Text('u/${user.name}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500
              ),),
            SizedBox(height: 10,),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("My Profile"),
              onTap: ()=>navigateToUserprofile(context, user.uid),
            ),
            ListTile(
              leading: Icon(Icons.logout,color: Pallete.redColor,),
              title: Text("Log Out"),
              onTap: ()  => logOut(ref),
            ),
            Switch.adaptive(
              value: ref.watch(themeNotifierProvider.notifier).mode== ThemeMode.dark,
              onChanged: (value) =>toggleTheme(ref),
            )
          ],
        ),
      ),
    );
  }
}
