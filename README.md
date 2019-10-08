# Rudio-Android-Voice-Recorder
Rudio is an Android App project created in Flutter. It does not work with iOS.

### Info
It uses Dart(Of Course), and Kotlin.

This project works fine on my Ubuntu 19.04, and Android Version 9.

If you are running this project on another Operating System, and it is giving path related error, then do the following:
1. Create new project flutter project named 'rudio'.
2. Copy all files in the lib folder of this project, and paste them to the lib folder of the new project you have created.
3. Also replace MainActivity.kt (Kotlin file), and AndroidManifest.xml in the new project you have created by MainActivity.kt, and AndroidManifest.xml present in this project.

### Credits
Thanks to [boformer](https://stackoverflow.com/users/2461957/boformer?tab=profile) for the [TimerService code](https://stackoverflow.com/a/53231163).

Thanks [AndroidPub](https://android.jlelse.eu/create-an-android-sound-recorder-using-kotlin-36902b3bf967) for giving info about MediaRecorder class.
