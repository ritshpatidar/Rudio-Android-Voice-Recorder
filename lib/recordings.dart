import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class RecordingsPage extends StatefulWidget{
  RecordingsPage({Key key}) : super(key: key);

  @override
  RecordingsPageState createState() => RecordingsPageState();
}

class RecordingsPageState extends State<RecordingsPage>{
  static const platform = const MethodChannel('samples.flutter.dev/recordChannel');
  List<dynamic> fileNames = <dynamic>[];
  int fileIndex = -1;

  void setFileIndex(int fileindex){
  	fileIndex = fileindex;
  }

  Future<void> _invokeNativeFun(int flag) async {
    String s; 
      try {
          if(flag == 0){
            fileNames = await platform.invokeMethod('getNames');
            fileNames = fileNames.reversed.toList();
          }
          else if (flag == 1)
          	await platform.invokeMethod('playRecorded', {"text":"$fileIndex"});
          else if (flag == 2)
          	await platform.invokeMethod('stopPlayingRecorded');
      } on PlatformException catch (e) {
          s = "Failed: '${e.message}'."; //you can show it
      }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _invokeNativeFun(0),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return ListView.builder(
            itemCount: fileNames.length,
            itemBuilder: (BuildContext context, int index) => buildBody(context, index, fileNames.length),
          );      //Center(child:Text("$fileNames"));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  Widget buildBody(BuildContext context, int index, int len){
      var deviceSize = MediaQuery.of(context).size;
      //for(int i = 0; i<len; i++){
      	return SizedBox(
        	height : deviceSize.width*0.20,
        	width : deviceSize.width,
        	child: Card(
          	child: Row(children: <Widget>[
            	Expanded(child: Text(fileNames[index],style:TextStyle(fontSize:20.0))),
            	Expanded(child: MyListItem(myindex: index, invoker: _invokeNativeFun, file_index_setter: setFileIndex))
          	]),
          	),
      	);
      //}
  }
}

class MyListItem extends StatefulWidget {
  int myindex;
  Function invoker;
  Function file_index_setter;

  MyListItem({this.myindex, this.invoker, this.file_index_setter});

  @override
  _MyListItemState createState() => _MyListItemState();
}

class _MyListItemState extends State<MyListItem> {
  bool isPlaying = false;
  static bool isAnotherPlaying = false;

  @override
  Widget build(BuildContext context) {
  	return IconButton(
      icon: !isPlaying ? Icon(Icons.play_arrow, size: 50.0, color: Colors.blue) : 
      						Icon(Icons.stop, size: 50.0, color: Colors.blue) ,
      onPressed: (){
        	if(!isPlaying && !isAnotherPlaying){            			
        		widget.file_index_setter(widget.myindex);
        		widget.invoker(1);
        		isAnotherPlaying = true;
        		setState((){
        			isPlaying = true;
        		});
        	} else if(isPlaying) {
            	widget.file_index_setter(-1);
           		widget.invoker(2);
           		isAnotherPlaying = false;
        		setState((){
        		  	isPlaying = false;
        		});
        	} else if(isAnotherPlaying && !isPlaying) {
        		print("Ruk jaa madarchod, Purana toh band kr le"); //please stop previously played recording
        	}
      }
    );
  }
}
