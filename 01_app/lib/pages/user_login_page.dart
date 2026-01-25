import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';

class UserLoginPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    return Scaffold(body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(padding: EdgeInsetsGeometry.all(8.0),
        child: 
          TextField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your username',
            ),
            onSubmitted: (value) {
              if(appState.verify(value)){
                appState.changeIndex(0);
              }else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content:Text("Invalid username, please try again"), duration: Duration(milliseconds:1200), behavior: SnackBarBehavior.floating,));
              }
            },
          ),)
      ],
    ));
  }
}