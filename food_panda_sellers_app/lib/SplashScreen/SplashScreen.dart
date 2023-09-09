import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_panda_app/authentication/auth_screen.dart';
import 'package:food_panda_app/global/global.dart';
import 'package:food_panda_app/mainscreens/home_screen.dart';


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{
  startTimer()
  {

    Timer(const Duration(milliseconds:8), () async {
      //if seller is loggedin already
      if(firebaseAuth.currentUser != null)
        {
          Navigator.push(context,MaterialPageRoute(builder:(c)=> const HomeScreen()));
        }
      //if seller is NOT loggidin
      else {
        Navigator.push(context,MaterialPageRoute(builder:(c)=> const AuthScreen()));

      }
  });
  }

@override
  void initState() {

    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color:Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("images/splash.jpg"),
              ),
              const SizedBox(height: 10,),
              const Padding(
                  padding:  EdgeInsets.all(10.0),
                child: Text(
                  "sell Food online",
                  textAlign: TextAlign.center,
                  style:TextStyle(
                    color: Colors.black54,
                    fontSize: 40,
                    fontFamily:"Signatra",
                    letterSpacing:3,
)                )
              ),
            ]
          )

        )
      ),
    );
  }
}
