import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormData {
  String type = "en";
  String word = "";
  bool fav = false;
}

class InputForm extends StatefulWidget {
  InputForm(this.document);
  final DocumentSnapshot document;

  @override
  MyInputFormState createState() => MyInputFormState();
}

class MyInputFormState extends State<InputForm> {
  DocumentReference mainReference =
      Firestore.instance.collection('dictionary').document();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FormData data = FormData();
  bool isDataExist = false;

  @override
  void initState() {
    if (widget.document != null) {
      data.type = widget.document['type'];
      data.word = widget.document['word'];
      data.fav = widget.document['fav'];
      mainReference = Firestore.instance
          .collection('dictionary')
          .document(widget.document.documentID);
      isDataExist = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ワード登録'),
        actions: <Widget>[
          createSaveIconButton(mainReference),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              createEnToJaRadioList(),
              createJaToEnRadioList(),
              createWordTextField()
            ],
          ),
        ),
      ),
    );
  }

  Widget createSaveIconButton(DocumentReference mainReference) {
    return IconButton(
        icon: Icon(Icons.save),
        onPressed: () {
          if (formKey.currentState.validate()) {
            formKey.currentState.save();
            mainReference.setData({
              'type': data.type,
              'word': data.word,
              'fav': data.fav,
              'created_at': new DateTime.now(),
            });
            Navigator.pop(context);
          }
        });
  }

  Widget createEnToJaRadioList() {
    return RadioListTile(
      value: "en",
      groupValue: data.type,
      title: Text("英和"),
      onChanged: (String value) {
        setType(value);
      },
    );
  }

  Widget createJaToEnRadioList() {
    return RadioListTile(
        value: "ja",
        groupValue: data.type,
        title: Text("和英"),
        onChanged: (String value) {
          setType(value);
        });
  }

  Widget createWordTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.library_books),
        hintText: 'ワード',
        labelText: 'word',
      ),
      onSaved: (String value) {
        data.word = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'ワードは必須入力項目です';
        }
        return null;
      },
      initialValue: data.word,
    );
  }

  void setType(String value) {
    setState(() {
      data.type = value;
    });
  }
}
