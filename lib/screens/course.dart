import 'package:classroom_management/screens/AddAssignment.dart';
import 'package:classroom_management/screens/HomeAnnouncementsPage.dart';
import 'package:classroom_management/screens/MakeAnnouncements.dart';
import 'package:classroom_management/screens/assignments.dart';
import 'package:classroom_management/screens/chat_screen.dart';
import 'package:classroom_management/widgets/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Course extends StatefulWidget {
  String courseId;
  String title = "NA";
  String description = "NA";
  Course(this.courseId, {this.title, this.description});
  @override
  _CourseState createState() => _CourseState(
      courseId: this.courseId,
      title: this.title,
      description: this.description);
}

class _CourseState extends State<Course> {
  String courseId;
  String title = "NA";
  String description = "NA";
  bool isLoading=true;
  bool isProf=false;
  _CourseState({this.courseId, this.title, this.description});
  findIfProfessor() async{
    User user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot documentSnapshot=await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      isProf=documentSnapshot.data()['isProf'];
      isLoading=false;
    });

  }
  @override
  void initState() {
    findIfProfessor();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      Column(
        children: [Announcements(courseId), if(isProf)MakeAnnouncements(courseId)],
      ),
      Assignments(
        courseId: courseId,
        title: title,
        description: description,
      ),
      ChatScreen(
        courseId: courseId,
      ),
    ];
    final _kTabs = <Tab>[
      const Tab(icon: Icon(Icons.announcement), text: 'Announcements'),
      const Tab(icon: Icon(Icons.assignment), text: 'Assignments'),
      const Tab(icon: Icon(Icons.message), text: 'Class Chat'),
    ];
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(this.title),
          backgroundColor: Theme.of(context).accentColor,
          actions: <Widget>[
            if(isProf)
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddAssignment(courseId: widget.courseId,)));
              },
              child: Text("Add Assignment",style: TextStyle(
                  fontSize: 22
              ),),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
            if(isProf)
            FlatButton(
              textColor: Colors.white,
              onPressed: () {},
              child: Text("Students",style: TextStyle(
                fontSize: 22
              ),),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
          // If `TabController controller` is not provided, then a
          // DefaultTabController ancestor must be provided instead.
          // Another way is to use a self-defined controller, c.f. "Bottom tab
          // bar" example.
          bottom: TabBar(
            tabs: _kTabs,
          ),
        ),
        body: isLoading?Center(child: CircularProgressIndicator()):TabBarView(
          children: _kTabPages,
        ),
        floatingActionButton: isProf?FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddAssignment(courseId: widget.courseId,)));
          },
          icon: Icon(Icons.add),
          label: Text("Add Assignment"),
        ): Container() ,
      ),
    );
  }
}
