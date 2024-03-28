import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/Models/comment_model.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  const CommentCard({super.key,required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(comment.profilePic),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("u/${comment.username}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),),
                      Text(comment.text)
                    ],
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: () {},
                  icon: Icon(Icons.reply)),
              Text("Reply")
            ],
          )
        ],
      ),
    );
  }
}
