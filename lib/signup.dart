import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selamkapisi/service/auth.dart';
import 'package:selamkapisi/service/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _termsAccepted = false;

  registration() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red[400],
        content: Text(
          "Devam etmek için sözleşmeleri kabul etmelisiniz.",
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ));
      return;
    }

    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Önce emailin kullanılıp kullanılmadığını kontrol etmek için doğrudan kayıt işlemi yapıyoruz
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: mailcontroller.text, password: passwordcontroller.text);

        // Kayıt başarılı olduysa devam et
        await userCredential.user!.sendEmailVerification();

        Map<String, dynamic> userInfoMap = {
          "name": namecontroller.text,
          "email": mailcontroller.text,
          "id": userCredential.user!.uid,
          "imgUrl": "https://image-cdn.artland.com/eyJidWNrZXQiOiJhcnRsYW5kLXVwbG9hZHMiLCJrZXkiOiJ1c2Vycy9jam9oMHg4ZG4xdjYzMDg4MDJmdXhiNW00L3Byb2ZpbGVJbWFnZS02OTEwNDUxOS1mMmExLTRkZTktODIxMC1hMDEwODMyODQ3MzMuanBnIiwiZWRpdHMiOnsianBlZyI6eyJxdWFsaXR5Ijo4MH0sInJvdGF0ZSI6bnVsbCwicmVzaXplIjp7IndpZHRoIjoxMjAwLCJoZWlnaHQiOjEyMDAsImZpdCI6Imluc2lkZSJ9fX0=",
        };

        Map<String, dynamic> usersDataMap = {
          "charityAmount": 0,
          "displayName": namecontroller.text,
          "email": mailcontroller.text,
          "photoUrl": "",
          "prayerCount": 0,
          "quranPages": 0,
          "socialPoints": 0,
          "totalScore": 0,
        };

        await DatabaseMethods().addUser(userCredential.user!.uid, userInfoMap);
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(usersDataMap);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.amber[800],
            content: Text(
              "Kayıt başarılı! Lütfen emailinizi doğrulayın.",
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            )));

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LogIn()));

      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = "Kayıt sırasında bir hata oluştu";
        if (e.code == 'weak-password') {
          errorMessage = "Şifre en az 6 karakter olmalı";
        } else if (e.code == "email-already-in-use") {
          // Email zaten kullanımda, Google ile bağlantılı olup olmadığını kontrol et
          errorMessage = "Bu email zaten kullanılıyor";

          // Kullanıcıya Google ile giriş yapmayı öner
          if (context.mounted) {
            bool? useGoogle = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Email Zaten Kayıtlı'),
                  content: Text('Bu email adresi zaten kayıtlı. Google ile giriş yapmak ister misiniz?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Hayır'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text('Evet'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );

            if (useGoogle == true) {
              await AuthMethods().signInWithGoogle(context);
              return;
            }
          }
        } else if (e.code == "invalid-email") {
          errorMessage = "Geçersiz email formatı";
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.amber[800],
            content: Text(
              errorMessage,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.amber[800],
            content: Text(
              "Hata: ${e.toString()}",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
      }
    }
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'URL açılamıyor: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 30.0),
              Container(
                constraints: BoxConstraints(maxHeight: 140),
                child: Image.asset(
                  "assets/images/selam_kapisi_logo.png",
                  fit: BoxFit.contain,
                  color: Colors.amber,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Hesap Oluşturun",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),

              Form(
                key: _formkey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withAlpha((255 * 0.1).round()),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen isminizi girin';
                          }
                          return null;
                        },
                        controller: namecontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 18.0, horizontal: 20.0),
                          hintText: "İsim",
                          hintStyle: TextStyle(
                              color: Colors.grey[500], fontSize: 16.0),
                          prefixIcon: Icon(Icons.person, color: Colors.amber),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber..withAlpha((255 * 0.1).round()),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen email adresinizi girin';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Geçerli bir email adresi girin';
                          }
                          return null;
                        },
                        controller: mailcontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 18.0, horizontal: 20.0),
                          hintText: "Email",
                          hintStyle: TextStyle(
                              color: Colors.grey[500], fontSize: 16.0),
                          prefixIcon: Icon(Icons.email, color: Colors.amber),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withAlpha((255 * 0.1).round()),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: passwordcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi girin';
                          }
                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalı';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 18.0, horizontal: 20.0),
                          hintText: "Şifre",
                          hintStyle: TextStyle(
                              color: Colors.grey[500], fontSize: 16.0),
                          prefixIcon: Icon(Icons.lock, color: Colors.amber),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          activeColor: Colors.amber,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: "Kullanım Koşulları",
                              style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _launchURL("https://github.com/yusufitmis/selam_kapisi/blob/main/terms-of-service.md");
                                },
                              children: [
                                TextSpan(
                                  text: " ve ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none),
                                ),
                                TextSpan(
                                  text: "Gizlilik Sözleşmesini",
                                  style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchURL("https://github.com/yusufitmis/selam_kapisi/blob/main/privacy-policy.md");
                                    },
                                ),
                                TextSpan(
                                  text: " okudum ve kabul ediyorum.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: _isLoading ? null : registration,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber[700]!, Colors.amber[900]!],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withAlpha((255 * 0.3).round()),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation(Colors.black),
                          )
                              : Text(
                            "Kayıt Ol",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey[800],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "veya",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey[800],
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                "Diğer Kayıt Yöntemleri",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      AuthMethods().signInWithGoogle(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withAlpha((255 * 0.2).round()),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/google_logo.png",
                        height: 30,
                        width: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 15.0),
                  GestureDetector(
                    onTap: () {
                      AuthMethods().signInWithApple();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withAlpha((255 * 0.2).round()),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/ios.png",
                        height: 30,
                        width: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Zaten hesabınız var mı? ",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LogIn()));
                    },
                    child: Text(
                      "Giriş Yap",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}