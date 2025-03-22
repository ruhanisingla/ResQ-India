import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; // Import Home Page

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";
  bool otpSent = false;
  bool isLoading = false;
  bool isPhoneAuth = false; // Toggle Email/Phone Authentication
  bool isSignup = false; // Toggle Login/Signup Mode

  // 🔹 Send OTP for Phone Signup/Login
  void sendOTP() async {
    setState(() => isLoading = true);
    await auth.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        navigateToHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);
        showError(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
          otpSent = true;
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 🔹 Verify OTP for Phone
  void verifyOTP() async {
    setState(() => isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );
      await auth.signInWithCredential(credential);
      navigateToHome();
    } catch (e) {
      setState(() => isLoading = false);
      showError("Invalid OTP! Try again.");
    }
  }

  // 🔹 Email Signup
  void signUpWithEmail() async {
    setState(() => isLoading = true);
    try {
      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      navigateToHome();
    } catch (e) {
      setState(() => isLoading = false);
      showError("Signup Failed: ${e.toString()}");
    }
  }

  // 🔹 Email Login
  void loginWithEmail() async {
    setState(() => isLoading = true);
    try {
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      navigateToHome();
    } catch (e) {
      setState(() => isLoading = false);
      showError("Invalid Email or Password.");
    }
  }

  // 🔹 Navigate to Home Page
  void navigateToHome() {
    setState(() => isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  // 🔹 Show Error Messages
  void showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? "Something went wrong!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPhoneAuth
                  ? (otpSent ? "Enter OTP" : "Enter Phone Number")
                  : (isSignup ? "Signup with Email" : "Login with Email"),
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // 🔹 Email & Password Fields (for Signup/Login)
            if (!isPhoneAuth) ...[
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            // 🔹 Phone Number Field
            if (isPhoneAuth && !otpSent)
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixText: "+91 ",
                  border: OutlineInputBorder(),
                ),
              ),

            // 🔹 OTP Field
            if (isPhoneAuth && otpSent)
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                ),
              ),

            SizedBox(height: 20),

            // 🔹 Submit Button
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      if (isPhoneAuth) {
                        otpSent ? verifyOTP() : sendOTP();
                      } else {
                        isSignup ? signUpWithEmail() : loginWithEmail();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Text(isPhoneAuth
                        ? (otpSent ? "Verify OTP" : "Send OTP")
                        : (isSignup ? "Signup" : "Login")),
                  ),

            SizedBox(height: 10),

            // 🔹 Toggle Between Email & Phone Authentication
            TextButton(
              onPressed: () {
                setState(() {
                  isPhoneAuth = !isPhoneAuth;
                  otpSent = false;
                });
              },
              child: Text(isPhoneAuth ? "Use Email instead" : "Use Phone instead"),
            ),

            // 🔹 Toggle Between Login & Signup
            TextButton(
              onPressed: () {
                setState(() {
                  isSignup = !isSignup;
                });
              },
              child: Text(isSignup ? "Already have an account? Login" : "New here? Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
