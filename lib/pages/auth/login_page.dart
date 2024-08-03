import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:xwatch/controllers/auth_controller.dart';
import 'package:xwatch/pages/navigations/navigation_pro_page.dart';
import 'package:xwatch/services/background_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final userIDController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(            
            color: Colors.blueGrey.shade100,
            height: 100.h,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    // height: 150.0,
                    child: Text("X-Watch",style: TextStyle(color: Colors.indigo,fontSize: 24.sp,fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 64.sp),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    elevation: 10.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 3, 0, 3),
                      child: TextField(
                        controller: userIDController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(-5.0, 15.0, 10.0, 15.0),
                          hintText: "User ID",
                          border: InputBorder.none,
                          icon: Icon(Icons.account_circle_rounded),
                        ),
                      ),
                    )
                  ),
                  SizedBox(height: 24.sp),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    elevation: 10.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 3, 0, 3),
                      // child: TextFormField(
                      //   decoration: InputDecoration(pr),
                      // ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !_obscureText,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility_sharp), onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },),
                          contentPadding: const EdgeInsets.fromLTRB(-5.0, 15.0, 10.0, 15.0),
                          hintText: "Password",
                          border: InputBorder.none,
                          icon: const Icon(Icons.lock_outline)
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.sp,),
                  Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.blue,
                    child: TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        AuthController auth = AuthController();
                        Map<String, dynamic> param = {
                          "username": userIDController.text,
                          "password": passwordController.text
                        };
                        Map<String, dynamic> res = await auth.login(param); 
                        // debugPrint("===> res: ${res}");
                        if (res['status'] == 200) {
                          String encodeAuth = json.encode(res["data"]);
                          await prefs.setString('auth', encodeAuth).then((value) async {
                            WidgetsFlutterBinding.ensureInitialized();
                            await BackgroundService.instance.initializeService();

                            Navigator.pushAndRemoveUntil(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProvidedStylesExample(menuScreenContext: context,),
                              ),
                              (route) => false);
                          });

                          
                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade400,
                              content: Text(res['message'], style: TextStyle(color: Colors.white, fontSize: 14.sp),),
                              behavior: SnackBarBehavior.floating,
                              dismissDirection: DismissDirection.horizontal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 24.sp,
                                left: 12.sp,
                                right: 12.sp
                              ),
                              // margin: EdgeInsets.only(
                              //   bottom: MediaQuery.of(context).size.height - 100,
                              //   right: 20,
                              //   left: 20,
                              // ),
                            ),
                          );
                        }
                        
                      },
                      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 24.sp, vertical: 12.sp)), fixedSize: MaterialStateProperty.all(Size.fromWidth(96.sp))),
                      child: Text("Login", textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white,fontSize: 14.sp),),
                    ),
                  ),
                  SizedBox(height: 14.sp,),
                  // TextButton(onPressed: () async {
                  //   BackgroundService.instance.stop();
                  // }, child: Text("stop"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}