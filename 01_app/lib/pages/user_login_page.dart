import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';

class UserLoginPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Enter your username',
          ),
          onChanged: (value) {
            appState.verify(value);
          },
        ),
        // ElevatedButton(
        //   onPressed: appState.verify(), 
        //   child: Text("Verify")
        //   )
      ],
    );
  }
}