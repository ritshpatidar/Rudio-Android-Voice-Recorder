import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class RecordPage extends StatefulWidget{
	RecordPage({Key key}) : super(key: key);

 	@override
 	RecordPageState createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage>{
	static const platform = const MethodChannel('samples.flutter.dev/recordChannel');
	bool _isButtonDisabled = true;
	bool pauseResumePressed = false;
	String s;

	Future<void> _invokeNativeFun(int flag) async {
    	try {
      		if(flag == 1)
      			await platform.invokeMethod('startRecording');
      		else if(flag == 0)
      			await platform.invokeMethod('stopRecording');
      		else if(flag == 2)
      			await platform.invokeMethod('pauseRecording');
    	} on PlatformException catch (e) {
      		s = "Failed: '${e.message}'."; //you can show it
    	}
  	}

	Widget build(BuildContext context){
		var timerService = TimerService.of(context);
		var deviceSize = MediaQuery.of(context).size;
    //var w = deviceSize.height; //width = 360.0, height = 640
		return AnimatedBuilder(animation: timerService, builder: (context, child) { return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            	children:<Widget>[
                  Container(
                    width: deviceSize.width*.40,
                    height: deviceSize.width*.40,
                    child: Center(child: Text('${timerService.currentDuration.toString().substring(0,7)}',style:TextStyle(color:Colors.white,fontSize:30.0))),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,color: Colors.blue, //.amber.shade400,
                      // border: Border.all(
                      //   color: Colors.red,
                      //   width: 4.0,
                      // ),
                      boxShadow: [BoxShadow(
                        color: Colors.grey,
                        blurRadius: 8.0,
                      )]
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: deviceSize.height*0.25),
                    child:Row(
                      children:<Widget>[
                        Expanded(child:Container(
                          child: RawMaterialButton(
                            child: _isButtonDisabled ? Icon(Icons.fiber_manual_record, size: 70.0, color:Colors.white) :
                        								Icon(Icons.stop, size: 70.0, color:Colors.white),
                            onPressed: (){
                        	   if(!timerService.isRunning && !pauseResumePressed){
                        		    timerService.start();
                        		    _isButtonDisabled = false;
                        		    _invokeNativeFun(1);
                        	   } else{
                        		    timerService.stop();
                        		    timerService.reset();
                        		    _isButtonDisabled = true;
                        		    pauseResumePressed = false;
                        		    _invokeNativeFun(0);
                        	   }
                            },
                            constraints: BoxConstraints(maxHeight: 70.0,maxWidth: 70.0),
                            shape: new CircleBorder(),
                            elevation: 4.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,color: Colors.blue, //Colors.amber.shade400,
                            boxShadow: [BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            )]
                          ),
                          padding: EdgeInsets.all(0),
                        )),
                        Expanded(child: Container(
                          child:RawMaterialButton(
                            child: !timerService.isRunning ? Icon(Icons.play_arrow,size: 70.0,color:Colors.white) : //red
                        								Icon(Icons.pause, size: 70.0, color:Colors.white),
                            onPressed: (){
                        	   pauseResumePressed = true;
                        	   if(!_isButtonDisabled){
                        		    if(timerService.isRunning){
                        			   timerService.stop();
                        			   //_invokeNativeFun(2);
                        		    } else {
                        			   timerService.start();
                        			   //_invokeNativeFun(3);
                        		    }
                        		    _invokeNativeFun(2);
                        	   }
                            },
                            constraints: BoxConstraints(maxHeight: 70.0,maxWidth: 70.0),
                            shape: new CircleBorder(),
                            elevation: 4.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,color: Colors.blue, //.amber.shade400,
                            boxShadow: [BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            )]
                          ),
                          padding: EdgeInsets.all(0),
                        ))
                      ]
                  )),
                ],
          	);},);
	}
}

class TimerService extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;

  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  TimerService() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;

    // notify all listening widgets
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }

  static TimerService of(BuildContext context) {
    var provider = context.inheritFromWidgetOfExactType(TimerServiceProvider) as TimerServiceProvider;
    return provider.service;
  }
}

class TimerServiceProvider extends InheritedWidget {
  const TimerServiceProvider({Key key, this.service, Widget child}) : super(key: key, child: child);

  final TimerService service;

  @override
  bool updateShouldNotify(TimerServiceProvider old) => service != old.service;
}
