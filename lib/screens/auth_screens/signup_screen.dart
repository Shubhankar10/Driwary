import 'package:exception/screens/auth_screens/verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../dataclass/person.dart';
import '../../firebase/firebase_manager.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});
  final FirebaseAuth auth = FirebaseManager.auth;
  final FirebaseDatabase database = FirebaseManager.database;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  String verificationIDReceived = "";
  bool codeVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 300,
                    ),
                    Text('SignUp'),
                    const SizedBox(
                      height: 30,
                    ),


                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        labelText: "Email",
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        labelText: "Password",
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(onPressed: () => signup(context), child: Text('SignUp')),
                    ElevatedButton(onPressed: () =>{Navigator.of(context).pushNamed('login')},
                      child: Text('Login'),),

                  //For Phone
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        labelText: "Phone",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                        controller: codeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          labelText: "Code",
                        ),
                      ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(onPressed: (){
                        verifyNumber(context);
                    } ,
                      child: Text('Verify Number'),
                    ),
                    ElevatedButton(onPressed: (){
                        verifyCode(context);
                        },
                      child: Text('Verify Code'),
                    ),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  signup(BuildContext context) async {
    print("Sign-Up");

    NavigatorState state = Navigator.of(context);
    try{

    // Make User from the inbuilt func of Firebase
    final credentials = await auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    // Make object of dataclass and push on DB
    Person person = Person();
    Map<String, dynamic> personJson = {};
    personJson['name'] = 'Name';
    personJson['uid'] = credentials.user!.uid;
    personJson['email'] = emailController.text;
    personJson['phone'] = phoneController.text;

    person.fromJson(personJson);
    print("Person Object Created");
    //Push on DB
    await database.ref('Users/${person.uid}').set(person.toJson());
    print("Pushed in DB");

    //Goto Home
    state.pushNamedAndRemoveUntil('home', (Route route) => false);
    print("Redirected to HomePage");

    }
    on FirebaseAuthException catch (e) {
      print('Error Found');
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
          msg: "The password provided is too weak.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
          msg: "An account already exists for that email.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Invalid details",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
        msg: 'Something is Wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }

  verifyNumber(BuildContext context) {
    NavigatorState state = Navigator.of(context);
    auth.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value) =>{
            print("You are Logged in.")
          });
        },
        verificationFailed: (FirebaseAuthException e){
          print("Verification Failed");
          print(e.message);
        },
        codeSent: (String verifictionID, int? resendToken){
          print("Code Sent");
          verificationIDReceived = verifictionID;
          // codeVisible = true;
          // print("Redirect to OTP Verification Page");
          // state.pushNamedAndRemoveUntil('/verifyOtp', (Route route) => false);
        },
        codeAutoRetrievalTimeout: (String verificationID){
        }
    );

  }

  verifyCode(BuildContext context) async{

    NavigatorState state = Navigator.of(context);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationIDReceived,
        smsCode: codeController.text,
    );
    await auth.signInWithCredential(credential).then((value) {
      state.pushNamedAndRemoveUntil('home', (Route route) => false);
      print("Logged in ");
    });
  }
}
