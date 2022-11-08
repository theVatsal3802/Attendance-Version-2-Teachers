import 'package:flutter/material.dart';

import '../widgets/images.dart';
import '../utils/vertical_space_helper.dart';
import '../widgets/custom_textfield.dart';
import '../services/auth_functions.dart';
import './verify_email_screen.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = "/auth";
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  bool _isLoading = false;

  void callFunction() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    bool valid = _formkey.currentState!.validate();
    if (!valid) {
      return;
    }
    _formkey.currentState!.save();
    await AuthFunctions()
        .submitForm(
      _nameController.text.trim(),
      _emailController.text.trim().toLowerCase(),
      _passwordController.text.trim(),
      context,
      isLogin,
    )
        .then(
      (value) {
        setState(() {
          _isLoading = false;
        });
        if (value) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            VerifyEmailScreen.routeName,
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SizedBox(
        height: height,
        width: width,
        child: ListView(
          children: [
            VerticalSpaceHelper(height: height / 10),
            const Logo(),
            VerticalSpaceHelper(height: height / 15),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  if (!isLogin)
                    CustomTextfield(
                      icon: Icons.person,
                      child: TextFormField(
                        autocorrect: true,
                        controller: _nameController,
                        enableSuggestions: true,
                        key: const ValueKey("name"),
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          return AuthFunctions().nameValidator(value!.trim());
                        },
                      ),
                    ),
                  const VerticalSpaceHelper(height: 20),
                  CustomTextfield(
                    icon: Icons.email,
                    child: TextFormField(
                      controller: _emailController,
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.emailAddress,
                      key: const ValueKey("email"),
                      textCapitalization: TextCapitalization.none,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      validator: (value) {
                        return AuthFunctions()
                            .emailValidator(value!.trim().toLowerCase());
                      },
                    ),
                  ),
                  const VerticalSpaceHelper(height: 20),
                  CustomTextfield(
                    icon: Icons.security,
                    child: TextFormField(
                      obscureText: true,
                      autocorrect: false,
                      controller: _passwordController,
                      enableSuggestions: false,
                      key: const ValueKey("password"),
                      textCapitalization: TextCapitalization.none,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      validator: (value) {
                        return AuthFunctions().passwordValidator(value!.trim());
                      },
                    ),
                  ),
                  const VerticalSpaceHelper(height: 25),
                  if (!_isLoading)
                    ElevatedButton(
                      onPressed: callFunction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                      child: Text(
                        isLogin ? "Login" : "Signup",
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headline6!
                                .fontSize),
                      ),
                    ),
                  if (_isLoading)
                    CircularProgressIndicator.adaptive(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  const VerticalSpaceHelper(height: 30),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    style: TextButton.styleFrom(),
                    child: Column(
                      children: [
                        Text(
                          isLogin
                              ? "Don't have an Account?"
                              : "Already have an account",
                          textScaleFactor: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const VerticalSpaceHelper(height: 4),
                        Text(
                          isLogin ? "SignUp Now" : "Login Instead",
                          textScaleFactor: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            VerticalSpaceHelper(height: height / 10),
          ],
        ),
      ),
    );
  }
}
