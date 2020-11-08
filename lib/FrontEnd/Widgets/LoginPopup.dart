import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:our_app/Core/Authentication.dart';
import 'package:our_app/Routes.dart';
import 'package:our_app/UserProfileArgs.dart';

class LoginPopup extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Authentication auth = new Authentication();
  Pattern emailPat =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  Pattern atLeastOneUppercaseLetter = r"(?=.*?[A-Z])";
  Pattern atLeastOneLowercaseLetter = r"(?=.*?[a-z])";
  Pattern atLeastOneDigit = r"(?=.*?[0-9])";

  String email;
  String password;

  String emailVerification(String s) {
    if (RegExp(emailPat).hasMatch(s)) return null;
    return "Enter Valid Email";
  }

  String passwordVerification(String s) {
    final int minPasswordLength = 8;
    RegExp upperReg = RegExp(atLeastOneUppercaseLetter);
    RegExp lowerReg = RegExp(atLeastOneLowercaseLetter);
    RegExp digitReg = RegExp(atLeastOneDigit);

    if (s.length < minPasswordLength) return "Not 8 Characters Long";
    if (!upperReg.hasMatch(s)) return "Not One Uppercase Letter";
    if (!lowerReg.hasMatch(s)) return "Not One Lowercase Letter";
    if (!digitReg.hasMatch(s)) return "Not One Digit";
    return null;
  }

  Future<void> onForgotPasswordBtnClick() async {
    formKey.currentState.save();
    if (emailVerification(email) == null) {
      await auth.resetPassword(email);
    }
  }

  Future<void> onLoginBtnClick(context) async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var authResult = await auth.loginEmailPass(email, password);
      if (authResult == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Trouble Logging In"),
            );
          },
        );
      } else {
        return Navigator.pushNamed(context, Routes.profileRoute,
            arguments: UserProfileArgs(authResult.user.uid));
      }
    }
  }

  Future<void> onRegisterBtnClick(context) async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var authResult = await auth.registerEmailPass(email, password);
      if (authResult == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Trouble Registering"),
            );
          },
        );
      } else {
        await auth.loginEmailPass(email, password);
      }
    }
  }

  //Gets widget to display email and password fields
  TextFormField getFormText(primary, isEmail) {
    TextStyle txtStyle = TextStyle(
      color: primary,
      decorationColor: primary,
    );

    String emailHint = "Email";
    IconData emailIcon = Icons.email;

    String passwordHint = "Password";
    IconData passwordIcon = Icons.lock;

    return TextFormField(
      style: txtStyle,
      obscureText: !isEmail,
      keyboardType: (isEmail)
          ? TextInputType.emailAddress
          : TextInputType.visiblePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: (isEmail) ? TextInputAction.next : TextInputAction.done,
      validator: (isEmail) ? emailVerification : passwordVerification,
      onSaved: (newValue) => (isEmail) ? email = newValue : password = newValue,
      decoration: InputDecoration(
        icon: Icon(
          (isEmail) ? emailIcon : passwordIcon,
          color: primary,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primary),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: primary),
        ),
        hintText: (isEmail) ? emailHint : passwordHint,
        hintStyle: txtStyle,
      ),
    );
  }

  //Gets button for submitting the form
  RaisedButton getFormBtn(context, txt, Function() func) {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        txt,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: func,
    );
  }

  //Styling to take entire row
  Widget horizontalExpansion(Widget i) {
    return Row(
      children: [
        Expanded(
          child: i,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).primaryColor;

    return AlertDialog(
        content: SingleChildScrollView(
      child: Wrap(children: [
        Form(
          key: formKey,
          child: Container(
            child: Column(
              children: [
                getFormText(primary, true),
                getFormText(primary, false),
                horizontalExpansion(
                  FlatButton(
                    onPressed: () async => await onForgotPasswordBtnClick(),
                    child: Text(
                      "Forgot Password?",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 10, color: primary),
                    ),
                  ),
                ),
                horizontalExpansion(
                  getFormBtn(context, "Login", () => onLoginBtnClick(context)),
                ),
                horizontalExpansion(
                  getFormBtn(
                      context, "Register", () => onRegisterBtnClick(context)),
                ),
                horizontalExpansion(Divider(color: primary)),
                horizontalExpansion(
                  getFormBtn(context, "Sign In With Google", () => null),
                ),
              ],
            ),
          ),
        )
      ]),
    ));
  }
}
