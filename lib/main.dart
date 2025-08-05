// main.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women Empowerment App',
      theme: ThemeData(primarySwatch: Colors.pink),
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}

// Welcome Page
class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Text(
                "Welcome to Women Empowerment App ✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                child: Text("Login", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage())),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text("Sign Up", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/5.png',
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signInWithGoogle(BuildContext context) async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗ Google Sign-In works only on Android/iOS")),
      );
      return;
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Google Sign-In successful")),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Google Sign-In Failed: $e")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: Text("Login"), backgroundColor: Colors.pink),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.login, color: Colors.white),
              label: Text("Login", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingPage()));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Login Failed: $e")),
                  );
                }
              },
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.g_mobiledata, color: Colors.white),
              label: Text("Sign in with Google 🚀", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 5,
              ),
              onPressed: () => signInWithGoogle(context),
            ),
            TextButton(
              child: Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.purple)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage())),
            ),
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/6.png',
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}


class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text("Sign Up"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Sign Up", style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (passwordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Passwords do not match")),
                    );
                    return;
                  }
                  try {
                    final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(userCred.user!.uid)
                        .set({
                      "name": nameController.text.trim(),
                      "email": emailController.text.trim(),
                      "phone": phoneController.text.trim(),
                    });
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingPage()));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Signup Failed: $e")),
                    );
                  }
                },
              ),
              TextButton(
                child: Text("Already have an account? Login"),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/images/1.png',
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class LandingPage extends StatelessWidget {
  final List<String> paragraphs = [
    "👩‍🎓 Women empowerment is the process of increasing the capacity of women to make choices and to transform those choices into desired actions and outcomes. It’s about giving women the right to be educated, to work, to vote, and to live free from violence and discrimination. Empowered women are capable of contributing to the economic and social development of their communities in meaningful ways.",
    "🌍 Across the globe, empowering women has proven to be one of the most effective ways to promote health, peace, and prosperity. When women are given equal access to education and employment, societies experience improved growth rates and reduced poverty levels. A strong and confident woman raises empowered children and contributes to the betterment of the future generation.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🌸 Women Empowerment"),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("👤 Profile Details"),
                  content: Text("Email: ${user?.email}\nUID: ${user?.uid}"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    )
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Cancel")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Logout")),
                  ],
                ),
              );
              if (confirm) {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => WelcomePage()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.pinkAccent),
              child: Center(
                child: Text("📚 Navigation",
                    style: TextStyle(fontSize: 22, color: Colors.white)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.pink),
              title: Text("About Us"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.deepPurple),
              title: Text("Schemes"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => SchemesPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.green),
              title: Text("ChatGPT"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ChatBotPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.report_problem, color: Colors.redAccent),
              title: Text("Problems"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ProblemPage()));
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.pink[50],
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Image.asset(
                'assets/images/13.png',
                height: 200,
                width: 400,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12),
            Card(
              color: Colors.purple[50], // ✅ Unified background color
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  paragraphs[0],
                  style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4),
                ),
              ),
            ),
            Center(
              child: Image.asset(
                'assets/images/10.png',
                height: 250,
              ),
            ),
            SizedBox(height: 12),
            Card(
              color: Colors.purple[50], // ✅ Same background as the first
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  paragraphs[1],
                  style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class SchemesPage extends StatelessWidget {
  final Map<String, String> schemes = {
    "👧 Beti Bachao Beti Padhao":
    "This scheme was launched to ensure survival, protection, and education of the girl child. It addresses issues like declining child sex ratio and empowers girls through education.",
    "💰 Sukanya Samriddhi Yojana":
    "A savings scheme for the girl child with high interest rates and tax benefits. It supports financial planning for her education and marriage.",
    "🏠 Working Women Hostel":
    "Provides safe and affordable accommodation for working women with day care facilities for their children, aiming to empower them economically.",
    "🛡 One Stop Centre":
    "Supports women affected by violence with medical, legal, psychological, and police support under one roof.",
    "📖 Ujjawala Scheme":
    "Aims at preventing trafficking of women and children for commercial sexual exploitation, and providing rehabilitation to the victims.",
    "🧕 Mahila Shakti Kendra":
    "Empowers rural women through community participation and offers skill development, employment, health and education services.",
    "💼 Stand Up India Scheme":
    "Facilitates bank loans between ₹10 lakh and ₹1 crore for women entrepreneurs to start their own businesses.",
    "👩‍⚕ Pradhan Mantri Matru Vandana Yojana":
    "A maternity benefit scheme for pregnant and lactating women to improve health by providing partial wage compensation and promoting safe delivery.",
    "🎓 National Scheme of Incentive to Girls for Secondary Education":
    "Promotes enrollment of girls belonging to SC/ST communities in secondary schools by providing financial incentives.",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📋 Government Schemes"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        color: Colors.pink[50],
        padding: EdgeInsets.all(16),
        child: ListView(
          children: schemes.entries.map((entry) {
            return Card(
              color: Colors.purple[50],
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                    ),
                    SizedBox(height: 8),
                    Text(
                      entry.value,
                      style: TextStyle(fontSize: 15.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}



class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final controller = TextEditingController();
  final messages = <Map<String, String>>[];

  String getResponse(String input) {
    input = input.toLowerCase();

    if (input.contains("hi") || input.contains("hello")) {
      return """Hi! 👋 How can I assist you today?

You can ask about:
• education  
• employment  
• safety  
• mental health  
• finance  
• legal  
• self defense  
• entrepreneur  
• helpline""";

    } else if (input.contains("education")) {
      return "🎓 Education empowers women to achieve independence and growth.";
    } else if (input.contains("employment")) {
      return "💼 Employment is essential for financial independence and dignity.";
    } else if (input.contains("safety")) {
      return "🛡 Your safety matters! Dial 181 for immediate women's helpline support.";
    } else if (input.contains("mental health")) {
      return "🧠 Mental health is important. Talk to someone or reach out to a therapist.";
    } else if (input.contains("finance")) {
      return "💰 Financial literacy is power! Explore saving schemes like Sukanya Samriddhi Yojana.";
    } else if (input.contains("legal")) {
      return "⚖ Women in India have rights like protection under the Domestic Violence Act, 2005.";
    } else if (input.contains("self defense")) {
      return "🥋 Self-defense training boosts confidence and safety awareness.";
    } else if (input.contains("entrepreneur")) {
      return "👩‍💼 Women entrepreneurship is growing! Look into Mudra Yojana and Stand-Up India.";
    } else if (input.contains("helpline")) {
      return "📞 National Helpline Numbers: Women: 181 | Police: 100 | Childline: 1098";
    } else if (input.contains("bye")) {
      return "Bye 👋. Thank you for visiting. Stay empowered! 💪";
    } else {
      return "🤔 I didn't understand. Try asking about education, safety, legal rights, or mental health.";
    }
  }

  void send(String msg) {
    setState(() {
      messages.insert(0, {"user": msg});
      messages.insert(0, {"bot": getResponse(msg)});
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ChatGPT Assistant"), backgroundColor: Colors.pink),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final sender = msg.keys.first;
                  return Align(
                    alignment: sender == "user"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: sender == "user"
                            ? Colors.pink[100]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.shade100,
                          width: 1,
                        ),
                      ),
                      child: Text(msg[sender]!),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: controller,
                      onSubmitted: send,
                      decoration: InputDecoration(
                        hintText: "Ask about education, legal rights, etc.",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.purple),
                  onPressed: () => send(controller.text),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}





class ProblemPage extends StatefulWidget {
  @override
  _ProblemPageState createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage> {
  final TextEditingController _problemController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = "";

  // Submit problem to Firestore
  void _submitProblem() async {
    final String message = _problemController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (message.isEmpty) {
      setState(() {
        _statusMessage = "❗ Please enter a problem before submitting.";
      });
      return;
    }

    if (user == null) {
      setState(() {
        _statusMessage = "❗ Please log in to submit a problem.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "";
    });

    try {
      await FirebaseFirestore.instance.collection('problems').add({
        'email': user.email ?? 'unknown',
        'message': message,
        'timestamp': Timestamp.now(),
      });

      setState(() {
        _isLoading = false;
        _problemController.clear();
        _statusMessage = "✅ Problem submitted successfully!";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "❌ Failed to send problem. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📨 Report a Problem"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please describe any problem or concern you are facing 👇",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _problemController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "📝 Describe your problem here",
                labelStyle: TextStyle(color: Colors.purple),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.purple))
                : ElevatedButton.icon(
              onPressed: _submitProblem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              icon: Icon(Icons.send),
              label: Text("Submit"),
            ),
            SizedBox(height: 20),
            if (_statusMessage.isNotEmpty)
              Center(
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains("success")
                        ? Colors.green
                        : Colors.red,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/images/12.png',
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Text("🖼️ Image not found");
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.pink[50],
    );
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }
}
