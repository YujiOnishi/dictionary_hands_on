import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/drawer_menu.dart';
import './input.dart';

class Dictionary extends StatefulWidget {
  @override
  _Dictionary createState() => _Dictionary();
}

class _Dictionary extends State<Dictionary> with SingleTickerProviderStateMixin {
  TabController tabController;
  final List<Tab> tabs = <Tab>[
    Tab(text: '英和'),
    Tab(text: '和英'),
  ];

  @override
  void initState() {
    tabController = TabController(vsync: this, length: tabs.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: createAppBarText(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: () {
              onPressAddButton();
            },
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: tabs,
        ),
      ),
      drawer: DrawerMenu(),
      body: TabBarView(
        controller: tabController,
        children: tabs.map(
          (Tab tab) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[buildStreamBuilder(tab.text)],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget buildStreamBuilder(String tab) {
    String queryType = "";
    if (tab == '英和') {
      queryType = 'en';
    } else {
      queryType = 'ja';
    }
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("dictionary")
          .where('type', isEqualTo: queryType)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return createStreamBuilder(context, snapshot);
      },
    );
  }

  Widget createStreamBuilder(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return new Text('Error: ${snapshot.error}');
    }
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return createLoadingText();
      default:
        return createAlign(snapshot);
    }
  }

  Widget createLoadingText() {
    return Text("Loading...");
  }

  Widget createAlign(AsyncSnapshot<QuerySnapshot> snapshot) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: createWordCards(snapshot),
      ),
    );
  }

  Widget createAppBarText() {
    return Text("ワード一覧");
  }

  List<Widget> createWordCards(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents.map(
      (DocumentSnapshot document) {
        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              createWordTile(document),
              createButtonBar(document),
            ],
          ),
        );
      },
    ).toList();
  }

  Widget createWordTile(DocumentSnapshot document) {
    if (document['translated'] == null) {
      return Text("Looding...");
    }

    if (document['type'] == 'en') {
      return ListTile(
        leading: const Icon(Icons.book),
        title: Text(document['word']),
        subtitle: Text(
          "\n意味 ： " + document['translated']['ja'].toString(),
        ),
      );
    } else if (document['type'] == 'ja') {
      return ListTile(
        leading: const Icon(Icons.book),
        title: Text(document['word']),
        subtitle: Text(
          "\n意味 ： " + document['translated']['en'].toString(),
        ),
      );
    } else {
      return Text("Error");
    }
  }

  Widget createButtonBar(DocumentSnapshot document) {
    return ButtonBar(
      children: <Widget>[
        createDeleteButton(document),
      ],
    );
  }

  Widget createDeleteButton(DocumentSnapshot document) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {
        onPressDeleteButton(document);
      },
    );
  }

  void onPressDeleteButton(DocumentSnapshot document) {
    DocumentReference mainReference = Firestore.instance
        .collection('dictionary')
        .document(document.documentID);
    mainReference.delete();
  }

  void onPressAddButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) => InputForm()),
    );
  }
}
