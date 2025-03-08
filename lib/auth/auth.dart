import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tick_tick/auth/validators.dart';

import '../model/user_model.dart';
import '../pages/home_page.dart';
import '../theme/theme_manager.dart';
import 'database_helper.dart';

class Login extends StatefulWidget{
  const Login({super.key});


  @override
  State<StatefulWidget> createState() => _LoginState();

}

class _LoginState extends State<Login>{

  final formKey = GlobalKey<FormState>();
  bool isLoginTrue = false;
  bool isPasswordVisible = false;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final db = DatabaseHelper();

  login()async{

    if(formKey.currentState!.validate()){
      String? asyncValidationResult = await Validators.validateUserNameForLogin(username.text);
      if (asyncValidationResult != null) {
        // Show error message, e.g., using a SnackBar or setState to display the error.
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(asyncValidationResult,style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating, // Make it float
              margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              duration: Duration(seconds: 1),
            )
        );
        return;
      }
      String? passValidationResult = await Validators.validatePasswordForLogin(
          username.text,
          password.text,
      );
      if (passValidationResult != null) {
        // Show error message, e.g., using a SnackBar or setState to display the error.
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(passValidationResult,style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating, // Make it float
              margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              duration: Duration(seconds: 1),
            )
        );
        return;
      }
    }


    var res = await db.authenticate(Users(usrName: username.text, password: password.text));
    if(res == true){
      Users? loggedInUser = await db.getUser(username.text);
      if(loggedInUser != null){
        //If result is correct then go to home page
        if(!mounted)return;
        Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage(usrId: loggedInUser.usrId!,)));
      }
      }
     else{
      //Otherwise show the error message
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final backgroundColor = currentTheme.scaffoldBackgroundColor;

   return Scaffold(
     backgroundColor: backgroundColor,
     appBar: null,
     body: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Form(
           key: formKey,
           child: Column(
             children: [
               SizedBox(height: 100,),
               Image.asset('assets/images/signin.png',
                 height: 250,
                 width: 250,
                 fit: BoxFit.cover,
               ),
               SizedBox(height: 20,),
               Text('Welcome Back to Tick Tick',style: currentTheme.textTheme.titleLarge,),
               Text("Organize your day, according to your tasks",style: currentTheme.textTheme.headlineSmall,),
               SizedBox(height: 20,),
               TextFormField(
                 validator: Validators.validateUserName,
                 controller: username,
                 decoration: InputDecoration(
                   filled: true,
                   fillColor: Theme.of(context).brightness == Brightness.dark
                       ? Color(0xFF2B2B2B) // Dark theme fill color
                       : Colors.pink.shade50, // Light theme fill color
                   hintText: 'Username',
                   prefixIcon: Icon(
                     Icons.person,
                     color: Theme.of(context).brightness == Brightness.dark
                         ? Colors.grey.shade400 // Dark theme icon color
                         : Colors.grey.shade800, // Light theme icon color
                   ),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide.none,
                   ),
                 ),
                 style: TextStyle(
                   color: Theme.of(context).brightness == Brightness.dark
                       ? Colors.white // Dark theme text color
                       : Colors.black, // Light theme text color
                 ),
               ),
               SizedBox(height: 10,),
               TextFormField(
                 validator: Validators.validatePassword,
                 controller: password,
                 obscureText: !isPasswordVisible,
                 obscuringCharacter: '*',
                 decoration: InputDecoration(
                   filled: true,
                   fillColor: Theme.of(context).brightness == Brightness.dark
                       ? Color(0xFF2B2B2B) // Dark theme fill color
                       : Colors.pink.shade50, // Light theme fill color
                   hintText: 'Password',
                   prefixIcon: Icon(Icons.lock,
                   color: Theme.of(context).brightness == Brightness.dark
                       ? Colors.grey.shade400 // Dark theme icon color
                       : Colors.grey.shade800, // Light theme icon color
                      ),
                   suffixIcon: IconButton(
                     icon: Icon(isPasswordVisible ? Icons.visibility : Icons
                         .visibility_off,),
                     onPressed: () {
                       setState(() {
                         isPasswordVisible = !isPasswordVisible;
                       });
                     },),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide.none,
                   ),
                 ),
                 style: TextStyle(
                   color: Theme.of(context).brightness == Brightness.dark
                       ? Colors.white // Dark theme text color
                       : Colors.black, // Light theme text color
                 ),
               ),
               SizedBox(height: 20,),
               ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(14),
                   ),
                   minimumSize: Size(double.infinity, 56),
                 ),
                 onPressed: () {
                   if(formKey.currentState!.validate()){
                     login();
                   }
                 },
                 child: Text('Login'),
               ),
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text("Don't have an account?"),
                   TextButton(
                     onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                     },
                     child: Text('Sign Up'),
                   ),
                 ],
               ),
             ],
           ),
         ),
       ),
     ),
   );
  }
}

class Signup extends StatefulWidget{
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() => _SignupState();

}

class _SignupState extends State<Signup> {
bool isPasswordVisible = false;
bool isConfirmPasswordVisible = false;
final formKey = GlobalKey<FormState>();
final TextEditingController fullName = TextEditingController();
final TextEditingController username = TextEditingController();
final TextEditingController password = TextEditingController();
final TextEditingController confirmPassword = TextEditingController();


final db = DatabaseHelper();
signUp()async{

  if(formKey.currentState!.validate()){
    String? asyncValidationResult = await Validators.validateUserNameForSignUp(username.text);
    if (asyncValidationResult != null) {
      // Show error message, e.g., using a SnackBar or setState to display the error.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(asyncValidationResult))
      );
      return;
    }
  }

  var res = await db.createUser(
      Users(
          fullName: fullName.text,
          usrName: username.text,
          password: password.text,
      )
  );
  if(res>0){
    if(!mounted)return;
    Navigator.push(context, MaterialPageRoute(builder: (context)=> const Login()));
  }
}


  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final backgroundColor = currentTheme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 100,),
                Image.asset('assets/images/signup.png',
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20,),
                Text('Join Tick Tick Today',style:currentTheme.textTheme.titleLarge,),
                Text('Your journey to productivity starts here!',style: currentTheme.textTheme.headlineSmall),
                SizedBox(height: 20,),
                TextFormField(
                  validator: Validators.validateName,
                  controller: fullName,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2B2B2B) // Dark theme fill color
                          : Colors.pink.shade50, // Light theme fill color
                      hintText: 'Full Name',
                      prefixIcon: Icon(Icons.person_2,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400 // Dark theme icon color
                            : Colors.grey.shade800, // Light theme icon color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      )
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Dark theme text color
                        : Colors.black, // Light theme text color
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  validator: Validators.validateUserName,
                  controller: username,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2B2B2B) // Dark theme fill color
                          : Colors.pink.shade50, // Light theme fill color
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.person,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400 // Dark theme icon color
                          : Colors.grey.shade800, // Light theme icon color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      )
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Dark theme text color
                        : Colors.black, // Light theme text color
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  validator: Validators.validatePassword,
                  controller: password,
                  obscureText: !isPasswordVisible,
                  obscuringCharacter: '*',
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF2B2B2B) // Dark theme fill color
                        : Colors.pink.shade50, // Light theme fill color
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400 // Dark theme icon color
                        : Colors.grey.shade800, // Light theme icon color,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility : Icons
                          .visibility_off,),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Dark theme text color
                        : Colors.black, // Light theme text color
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  validator: (value) => Validators.validateConfirmPassword(value, password.text),
                  obscureText: !isConfirmPasswordVisible,
                  obscuringCharacter: '*',
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF2B2B2B) // Dark theme fill color
                        : Colors.pink.shade50, // Light theme fill color
                    hintText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400 // Dark theme icon color
                          : Colors.grey.shade800, // Light theme icon color,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons
                          .visibility_off,),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Dark theme text color
                        : Colors.black, // Light theme text color
                  ),
                ),
                SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () {
                    if(formKey.currentState!.validate()){
                      signUp();
                    }
                  },
                  child: Text('Sign Up',style: TextStyle(color: currentTheme.brightness == Brightness.dark ?Colors.white :Colors.white,),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: Text('Login',),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}