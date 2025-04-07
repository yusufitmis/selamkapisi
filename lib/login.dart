import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:selamkapisi/service/auth.dart';
import 'package:selamkapisi/signup.dart';
import 'package:selamkapisi/forgot_password.dart';
import 'package:selamkapisi/home.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _isLoading = false;
  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).unfocus();
    });
  }

  userLogin() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        email = mailcontroller.text;
        password = passwordcontroller.text;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: mailcontroller.text,
            password: passwordcontroller.text);

        if (!userCredential.user!.emailVerified) {
          await userCredential.user!.sendEmailVerification();
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Email Doğrulama Gerekli"),
                content: Text(
                    "Lütfen emailinizi doğrulayın. Yeni bir doğrulama linki gönderildi."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Tamam"),
                  ),
                ],
              ),
            );
          }
          return;
        }

        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          String errorMessage = "Giriş yapılırken bir hata oluştu e-posta veya şifre hatalı diğer giriş yöntemlerini deneyin";
          if (e.code == 'user-not-found') {
            errorMessage = "Bu email ile kayıtlı kullanıcı bulunamadı";
          } else if (e.code == 'wrong-password') {
            errorMessage = "Yanlış şifre girdiniz";
          } else if (e.code == 'invalid-email') {
            errorMessage = "Geçersiz email formatı";
          } else if (e.code == 'user-disabled') {
            errorMessage = "Bu hesap devre dışı bırakılmış";
          } else if (e.code == 'too-many-requests') {
            errorMessage = "Çok fazla deneme yaptınız, lütfen daha sonra tekrar deneyin";
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Giriş Hatası"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Tamam"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Hata"),
              content: Text("Bir hata oluştu: ${e.toString()}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Tamam"),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40, // SafeArea padding
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Section
                        Container(
                          constraints: const BoxConstraints(maxHeight: 140),
                          child: Image.asset(
                            "assets/images/selam_kapisi_logo.png",
                            fit: BoxFit.contain,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          "Merhaba, Ey Dost!",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Form Section
                        Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              // Email Field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withAlpha(25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen email adresinizi girin';
                                    }
                                    return null;
                                  },
                                  controller: mailcontroller,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 18.0, horizontal: 20.0),
                                    hintText: "Email",
                                    hintStyle: TextStyle(
                                        color: Colors.grey[500], fontSize: 16.0),
                                    prefixIcon: Icon(Icons.email,
                                        color: Colors.amber),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15.0),

                              // Password Field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withAlpha(25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: passwordcontroller,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen şifrenizi girin';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 18.0, horizontal: 20.0),
                                    hintText: "Şifre",
                                    hintStyle: TextStyle(
                                        color: Colors.grey[500], fontSize: 16.0),
                                    prefixIcon: Icon(Icons.lock,
                                        color: Colors.amber),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15.0),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ForgotPassword()));
                                  },
                                  child: Text(
                                    "Şifremi Unuttum?",
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),

                              // Login Button
                              GestureDetector(
                                onTap: () {
                                  if (_formkey.currentState!.validate()) {
                                    userLogin();
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.amber[700]!, Colors.amber[900]!],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withAlpha(75),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(Colors.black),
                                    )
                                        : Text(
                                      "Giriş Yap",
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
                        const SizedBox(height: 20.0),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[800],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                        const SizedBox(height: 15.0),

                        // Social Login Title
                        Text(
                          "Diğer Giriş Yöntemleri",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 15.0),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google Button
                            GestureDetector(
                              onTap: () {
                                AuthMethods().signInWithGoogle(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withAlpha(50),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
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
                            const SizedBox(width: 20.0),

                            // Apple Button
                            GestureDetector(
                              onTap: () {
                                AuthMethods().signInWithApple();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withAlpha(50),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
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

                        // Spacer to push sign up link to bottom
                        const Spacer(),

                        // Sign Up Link
                        Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                                ? MediaQuery.of(context).viewInsets.bottom + 10
                                : 30.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Hesabınız yok mu? ",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => SignUp()));
                                },
                                child: Text(
                                  "Kayıt Ol",
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}