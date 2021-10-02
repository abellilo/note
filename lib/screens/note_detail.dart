import 'package:flutter/material.dart';
import 'package:notekeeper/models/note.dart';
import 'dart:async';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appTitleBar;
  final Note note;

  NoteDetail(this. note,this.appTitleBar);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appTitleBar);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  var _prioritesSelected = 'Low';

  DatabaseHelper helper = DatabaseHelper();

  String appTitleBar;
  Note note;

  TextEditingController titleCon = TextEditingController();
  TextEditingController decription = TextEditingController();

  NoteDetailState(this.note, this.appTitleBar);

  @override
  Widget build(BuildContext context) {
    TextStyle tStyle = Theme.of(context).textTheme.title;

    titleCon.text=note.title;
    decription.text=note.description;

    return WillPopScope(
        onWillPop: () {
          moveTolastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appTitleBar),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                moveTolastScreen();
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                //First Element
                ListTile(
                  title: Row(children: <Widget>[
                    DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      style: tStyle,
                      value:getPriorityAsString(note.priority),
                      onChanged: (String valueSelected) {
                        setState(() {
                          debugPrint('User selected $valueSelected');
                          updatePriorityAsInt(valueSelected);
                        });
                      },
                    )
                  ]),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleCon,
                    style: tStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: tStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: decription,
                    style: tStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: tStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Save Button Clicked');
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Delete Button Clicked');
                              _delete();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void moveTolastScreen() {
    Navigator.pop(context,true);
  }

  // Convert the String priority in the form to integer before saving it to Database
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority=1;
        break;
      case 'Low':
        note.priority=2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in Dropdown
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority = _priorities[0]; //High
        break;
      case 2:
        priority = _priorities[1]; //Low
        break;
    }
    return priority;
  }
  // Update the title of the Note Object
  void updateTitle(){
    note.title=titleCon.text;
  }
  // Update the description of the Note Object
  void updateDescription(){
    note.description = decription.text;
  }

  void _delete() async{
    // Case 1: If user is trying to delete the NEW NOTE i.e he has come to
    // the detail page by pressing the FAB of NoteList page.
    if(note.id==null){
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }
    // Case 2: User is trying to delete the old note that already has a valid ID
    int result = await helper.deleteNote(note.id);
    if(result !=0){
      _showAlertDialog('Status','Note Deleted Successfully');
    }else{
      _showAlertDialog('Status','Error Occured while Deleting Note');
    }
  }

  void _save() async{
    moveTolastScreen();

    note.date= DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id != null){ // case 1: Update operation
        result = await helper.updateNote(note);
    }
    else{ // case 2: Insert operation
      result = await helper.insertNote(note);
    }

    if(result != 0){ //Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    }
    else {  //  failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }
  void _showAlertDialog(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
      builder: (_)=>alertDialog
    );
  }
  void _drop(String a) {
    setState(() {
      this._prioritesSelected = a;
    });
  }
}
