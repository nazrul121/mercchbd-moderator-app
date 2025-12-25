import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    // Adding SafeArea ensures the text is not covered by device navigation bars
    return SafeArea(
      top: false, // We don't need padding at the top
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white, // Adding a background color helps visibility
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Designed and Developed by:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade800,fontSize: 12, fontWeight: FontWeight.w500),
            ),
            SizedBox(width:3),
            Image.asset('assets/favicon.png',height:12),
            Text('Micro Datasoft',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade800,fontSize: 12, fontWeight: FontWeight.w500,fontFamily: 'Audiowide',),
            ),
          ],
        )
        
      ),
    );
  }
}