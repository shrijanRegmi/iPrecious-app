import 'package:flutter/material.dart';
import 'package:iprecious/models/list_models/avatars.dart';

class SelectAvatar extends StatelessWidget {
  final String index = "";
  final Function(String) onIndex;
  SelectAvatar(this.onIndex);
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 9,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index);
              },
            );
            break;
          case 1:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index + 6);
              },
            );
            break;
          case 2:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index + 12);
              },
            );
            break;
          case 3:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index + 18);
              },
            );
            break;
          case 4:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index + 24);
              },
            );
            break;
          case 5:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index + 30);
              },
            );
            break;
          case 6:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index + 36);
              },
            );
            break;
          case 7:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index + 42);
              },
            );
            break;
          case 8:
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _getAvatarGrid(index + 48);
              },
            );
            break;
          default:
            return null;
        }
      },
    );
  }

  Widget _getAvatarGrid(int index) {
    return GestureDetector(
      onTap: () {
        onIndex(avatars[index].imgPath.length > 20
            ? avatars[index].imgPath.substring(15, 17)
            : avatars[index].imgPath.substring(15, 16)); //images/avatars/1.png
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Image.asset(avatars[index].imgPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
