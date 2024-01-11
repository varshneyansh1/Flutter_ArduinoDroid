import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pr1/screens/auth/auth_page.dart';
import 'package:my_pr1/screens/myhome_page.dart';

class NavBar extends StatefulWidget {
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late final User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    // Redirect to login or home page after sign out
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => AuthPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: currentUser.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print("Snapshot data: ${snapshot}");

          // Check if there are any documents returned
          if (snapshot.data!.docs.isNotEmpty) {
            final userData =
                snapshot.data!.docs[0].data() as Map<String, dynamic>;

            // Check if userData is not null and contains the key 'first name'
            if (userData != null && userData.containsKey('first name')) {
              return Drawer(
                child: ListView(
                  // Remove padding
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(
                        userData['first name'] + " " + userData['last name'],
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 22),
                      ),
                      accountEmail: Text(
                        currentUser.email!,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      currentAccountPicture: CircleAvatar(
                        child: ClipOval(
                          child: Icon(Icons.person),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Home'),
                      onTap: () {
                        // Handle home tap

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => myHomePage(),
                        ));
                      },
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Logout'),
                      leading: Icon(Icons.exit_to_app),
                      onTap: signUserOut,
                    ),
                  ],
                ),
              );
            } else {
              // Handle the case where 'first name' is not present in userData

              return Center(
                child: Text('User data is missing or incomplete: $userData'),
              );
            }
          } else {
            // Handle the case where no documents are found for the given email
            return               Drawer(
                child: ListView(
                  // Remove padding
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(
                        "Hi",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 22),
                      ),
                      accountEmail: Text(
                        currentUser.email!,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      currentAccountPicture: CircleAvatar(
                        child: ClipOval(
                          child: Icon(Icons.person),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Home'),
                      onTap: () {
                        // Handle home tap

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => myHomePage(),
                        ));
                      },
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Logout'),
                      leading: Icon(Icons.exit_to_app),
                      onTap: signUserOut,
                    ),
                  ],
                ),
              );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
