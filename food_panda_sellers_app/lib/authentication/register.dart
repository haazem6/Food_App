
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_panda_app/mainscreens/home_screen.dart';
import 'package:food_panda_app/widgets/custom_text_field.dart';
import 'package:food_panda_app/widgets/error_daialog.dart';
import 'package:food_panda_app/widgets/loading_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_panda_app/global/global.dart';
import '../global/global.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final GlobalKey<FormState> _formKey=GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker=ImagePicker();
  Position? position;
  List<Placemark>? placeMarks;
  String sellerImageUrl="";
  String completeAddress="";

  Future<void> _getImage() async
  {
    imageXFile=await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }
  getCurrentLocation() async
  {
  Position newPosition= await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  position= newPosition;
  placeMarks= await placemarkFromCoordinates(
    position!.latitude,
    position!.longitude,
  );
  Placemark pMark =placeMarks![0];
  completeAddress ='${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
  locationController.text=completeAddress;

}
Future <void> formValidation() async
{
  if(imageXFile == null) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Please select an image.",
          );
        }
    );
  }
  else {
    if(passwordController.text == confirmPasswordController.text)
      {

        if(confirmPasswordController.text.isNotEmpty && emailController.text.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty && locationController.text.isNotEmpty)
          {
            showDialog(
              context: context,
              builder: (c)
                {
                  return LoadingDialog(
                    message: "registering Account",
                  );
                }

            );
            String fileName =DateTime.now().millisecondsSinceEpoch.toString();
            fStorage.Reference reference= fStorage.FirebaseStorage.instance.ref().child("sellers").child(fileName);
            fStorage.UploadTask uploadtask =reference.putFile(File(imageXFile!.path));
            fStorage.TaskSnapshot taskSnupShot= await uploadtask.whenComplete(() {});
            await taskSnupShot.ref.getDownloadURL().then((url) {
              sellerImageUrl=url;

              //save info to firestore
              authenticateSellerAndSignUp();

            });
            //start upload image
          }
        else
          {
            showDialog(
                context: context,
                builder: (c) {
                  return ErrorDialog(
                    message: "please write the required info for Registration.",
                  );
                }
            );
          }
      }
    else
      {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Password not match.",
              );
            }
        );
      }
  }

}

void authenticateSellerAndSignUp() async
{
  User? currentUser;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
  ).then((auth){
    currentUser=auth.user;
  }).catchError((error){
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: error.message.toString(),
          );
        }
    );
  });






  if(currentUser != null)
    {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homePage
        Route newRoute =MaterialPageRoute(builder:(c) =>HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
}


  Future saveDataToFirestore(User currentUser) async
  {
    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set({
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": nameController.text.trim(),
      "sellerAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children:[
            const SizedBox(height: 10,),
            InkWell(
              onTap:()
                {
                  _getImage();
                },
                child:CircleAvatar(
                  radius: MediaQuery.of(context).size.width*0.20,
                  backgroundColor: Colors.white,
                  backgroundImage: imageXFile==null ? null : FileImage(File(imageXFile!.path)),
                  child: imageXFile==null
                      ?
                  Icon(
                    Icons.add_photo_alternate,
                    size: MediaQuery.of(context).size.width *0.20,
                    color: Colors.grey,
                  ): null,
                )
            ),
            const SizedBox(height: 10,),
            Form(
              key:_formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data:Icons.person,
                    controller: nameController,
                    hintText: "Name",
                    isObsecre:false,
                  ),
                  CustomTextField(
                    data:Icons.person,
                    controller: emailController,
                    hintText: "Email",
                    isObsecre:false,
                  ),
                  CustomTextField(
                    data:Icons.lock,
                    controller: passwordController,
                    hintText: "Password",
                    isObsecre:true,
                  ),
                  CustomTextField(
                    data:Icons.lock,
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    isObsecre:true,
                  ),
                  CustomTextField(
                    data:Icons.phone,
                    controller: phoneController,
                    hintText: "Phone",
                    isObsecre:false,
                  ),
                  CustomTextField(
                    data:Icons.my_location,
                    controller: locationController,
                    hintText: "Cafe/Restaurant Address",
                    isObsecre:false,
                  ),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child:ElevatedButton.icon(
                      label: Text(
                        "Get my Current Location",
                        style:TextStyle(color:Colors.white),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color:Colors.white,
                      ),
                      onPressed: ()
                      {
                        getCurrentLocation();
                      },
                      style:ElevatedButton.styleFrom(
                        shape:new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              child: const Text(
                "Sign Up",
                style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold,),
              ),
              style:ElevatedButton.styleFrom(
                primary: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 50,vertical: 10),
              ),
              onPressed:()
              {
                formValidation();
              },
            ),
            const SizedBox(height: 30,)
          ],
        ),
      ),

    );
  }
}
