package com.example.rudio

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES

import android.Manifest
import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.media.MediaPlayer
import android.os.Build
import android.support.v7.app.AppCompatActivity
import android.os.Environment
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.widget.Toast
import java.io.IOException

import java.util.List;
import java.util.ArrayList;
import java.io.File
import java.util.Date
import java.util.Locale
import java.text.SimpleDateFormat

class MainActivity: FlutterActivity() {
  private val CHANNEL = "samples.flutter.dev/recordChannel"
  //private val CHANNEL_2 = "samples.flutter.dev/recordingsChannel"
  private var dateTime : String? = null
  private val rudioDirectory = File(Environment.getExternalStorageDirectory(),"RudioRecordings")

  private var output: String? = null
  private var argFromFlutter: String? = null
  
  private var mediaRecorder: MediaRecorder? = null
  private var mediaPlayer: MediaPlayer? = null
  private var state: Boolean = false
  private var playerStarted: Boolean = false
  private var recordingStopped: Boolean = false

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    
    giveMePermission()
    if(!rudioDirectory.exists())
    	rudioDirectory.mkdirs()
    //val outputFile = File(wallpaperDirectory, filename)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "startRecording")
        startRecording()
      else if(call.method == "stopRecording")
      	stopRecording()
      else if(call.method == "pauseRecording")
      	pauseRecording()
      else if(call.method == "playRecorded"){
      	argFromFlutter = call.argument<String?>("text") //fileIndex
      	playRecorded(argFromFlutter!!.toInt())
      } 
      else if(call.method == "stopPlayingRecorded")
      	stopPlayingRecorded()
      else if(call.method == "getNames"){
      	var temp = getNames()
        result.success(temp)
      }
      else
      	result.notImplemented()
    }

  }
  
  private fun giveMePermission(){
  
  	if(ContextCompat.checkSelfPermission(this,
    				Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
    				Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED){
    		val permissions = arrayOf(android.Manifest.permission.RECORD_AUDIO, android.Manifest.permission.WRITE_EXTERNAL_STORAGE, android.Manifest.permission.READ_EXTERNAL_STORAGE)
    		ActivityCompat.requestPermissions(this, permissions,0)
    	} 
  }
  
  private fun startRecording(){
    	if(ContextCompat.checkSelfPermission(this,
    				Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
    				Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED){
    		val permissions = arrayOf(android.Manifest.permission.RECORD_AUDIO, android.Manifest.permission.WRITE_EXTERNAL_STORAGE, android.Manifest.permission.READ_EXTERNAL_STORAGE)
    		ActivityCompat.requestPermissions(this, permissions,0)
    	} else {
    		try {
    			mediaRecorder = MediaRecorder()
          dateTime = SimpleDateFormat("dd-MM-yyyy hh-mm-ss aa",Locale.getDefault()).format(Date())
    			output = rudioDirectory.absolutePath + "/recording" + dateTime + ".mp3"

    			mediaRecorder?.setAudioSource(MediaRecorder.AudioSource.MIC)
    			mediaRecorder?.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
    			mediaRecorder?.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
    			mediaRecorder?.setOutputFile(output)
  				mediaRecorder?.prepare()
  				mediaRecorder?.start()
  				state = true
  				Toast.makeText(this, "Recording started!", Toast.LENGTH_SHORT).show()
  			} catch (e: IllegalStateException) {
  				e.printStackTrace()
  			} catch (e: IOException) {
  				e.printStackTrace()
  			}
    	}
  }

    @SuppressLint("RestrictedApi", "SetTextI18n")
    @TargetApi(Build.VERSION_CODES.N)
    private fun pauseRecording() {
        if(state) {
            if(!recordingStopped){
                mediaRecorder?.pause()
                recordingStopped = true
                Toast.makeText(this,"Paused Recording!", Toast.LENGTH_SHORT).show()
            }else{
                resumeRecording()
            }
        }
    }

    @SuppressLint("RestrictedApi", "SetTextI18n")
    @TargetApi(Build.VERSION_CODES.N)
    private fun resumeRecording() {
        mediaRecorder?.resume()
        recordingStopped = false
        Toast.makeText(this,"Recording Resumed!", Toast.LENGTH_SHORT).show()
    }

    private fun stopRecording(){
        if(state){
            mediaRecorder?.stop()
            mediaRecorder?.release()
            state = false
            Toast.makeText(this,"Recording Stopped!", Toast.LENGTH_SHORT).show()
        }else{
            Toast.makeText(this, "You are not recording right now!", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun playRecorded(fileIndex: Int){
    	val filenamePath : String? = giveMePathForIndex(fileIndex) 
    	
    	if(!playerStarted){
    		if(filenamePath != null){
    			mediaPlayer = MediaPlayer()
    			mediaPlayer?.setDataSource(filenamePath)
    			mediaPlayer?.prepare()
    			mediaPlayer?.start()
    			playerStarted = true
    			Toast.makeText(this,"Player Started", Toast.LENGTH_SHORT).show()
    		} else {
    			Toast.makeText(this,"cannot get file", Toast.LENGTH_SHORT).show()
    		}
    	} else {
    		Toast.makeText(this,"Something is already is Playing", Toast.LENGTH_SHORT).show()
    		stopPlayingRecorded()
    		playRecorded(fileIndex)
    	}
    }
    
    private fun stopPlayingRecorded(){
    	if(playerStarted){
    		mediaPlayer?.stop()
            mediaPlayer?.release()
            playerStarted = false
            Toast.makeText(this,"Player Stopped", Toast.LENGTH_SHORT).show()
    	} else {
    		Toast.makeText(this,"Nothing to Stop", Toast.LENGTH_SHORT).show()
    	}
    }

    private fun getNames() : ArrayList<String?>{
      val files = rudioDirectory.listFiles()
      val fileNames : ArrayList<String?> = ArrayList()
      for(file in files){
        fileNames.add(file.getName())
      }
      return fileNames
    }
    
    private fun giveMePathForIndex(fileIndex : Int) : String? {
    	var filepath : String? = null
    	val fileNames : ArrayList<String?> = getNames()
    	
    	if(!fileNames.isEmpty()){
    		filepath = rudioDirectory.absolutePath + "/" + fileNames.get(fileIndex)
    		return filepath
    	}
    	
    	return null
    }
}
