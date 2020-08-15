import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:our_app/Core/Authentication.dart';

class LoginPopup extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Authentication auth = new Authentication();
  Pattern emailPat =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  Pattern atLeastOneUppercaseLetter = r"(?=.*?[A-Z])";
  Pattern atLeastOneLowercaseLetter = r"(?=.*?[a-z])";
  Pattern atLeastOneDigit = r"(?=.*?[0-9])";

  String email;
  String password;

  String emailVerification(String s) {
    RegExp regExp = RegExp(emailPat);
    if (regExp.hasMatch(s)) {
      return null;
    }
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

  void onLoginBtnClick(context) async {
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
      }
    }
  }

  void onRegisterBtnClick(context) async {
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

  TextFormField getFormText(
      primary, hint, icon, obscure, isEmail, Function(String) func) {
    TextStyle txtStyle = TextStyle(
      color: primary,
      decorationColor: primary,
    );

    return TextFormField(
      style: txtStyle,
      obscureText: obscure,
      autovalidate: false,
      validator: func,
      onSaved: (newValue) => (isEmail) ? email = newValue : password = newValue,
      decoration: InputDecoration(
        icon: Icon(
          icon,
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
        hintText: hint,
        hintStyle: txtStyle,
      ),
    );
  }

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
      content: Wrap(children: [
        Form(
          key: formKey,
          autovalidate: true,
          child: Container(
            child: Column(
              children: [
                getFormText(primary, "Email", Icons.email, false, true,
                    (s) => emailVerification(s)),
                getFormText(primary, "Password", Icons.lock, true, false,
                    (s) => passwordVerification(s)),
                horizontalExpansion(Text(
                  "Forgot Password?",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10),
                )),
                horizontalExpansion(getFormBtn(
                    context, "Login", () => onLoginBtnClick(context))),
                horizontalExpansion(getFormBtn(
                    context, "Register", () => onRegisterBtnClick(context))),
                horizontalExpansion(Divider(
                  color: primary,
                )),
                horizontalExpansion(
                    getFormBtn(context, "Sign In With Google", () => null)),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
