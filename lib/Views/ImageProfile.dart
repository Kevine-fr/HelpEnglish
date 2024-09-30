import 'package:flutter/material.dart' show BoxFit, BuildContext, CircleAvatar, Colors, Container, EdgeInsets, Icon, IconButton, Icons, Image, MainAxisAlignment, MediaQuery, Navigator, Row, Scaffold, Stack, State, StatefulWidget, Widget;

class ImageProfil extends StatefulWidget {
  final String profileImage;
  const ImageProfil({super.key, required this.profileImage});

  @override
  State<ImageProfil> createState() => _ImageProfilState();
}

bool like = false;

class _ImageProfilState extends State<ImageProfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Image.network(
            widget.profileImage,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          padding: MediaQuery.of(context).padding +
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                    )),
              ),
              CircleAvatar(
                backgroundColor: like ? Colors.black : Colors.white24,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        like = !like;
                      });
                    },
                    icon: Icon(
                      like ? Icons.favorite : Icons.favorite_outline,
                      color: like ? Colors.red : Colors.black,
                    )),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
