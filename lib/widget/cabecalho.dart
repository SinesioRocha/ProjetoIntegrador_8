import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cabecalho extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  Cabecalho({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFFFFFFF),
      centerTitle: true,
      title: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF27156B),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/logo.png',
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF27156B),
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Color(0xFF27156B)),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
