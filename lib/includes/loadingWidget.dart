import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: Colors.orange,
              backgroundColor: Colors.black54,
            ),
            SizedBox(height: 15,),
            Text('Content loading...')
          ],
        )
    );
  }
}
