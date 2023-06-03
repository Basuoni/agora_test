import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:agora_test/constants.dart';
import 'package:agora_test/user_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

//const appId = 'f5407b2fcd7d421187c690e979e48383';
//const token = "006f5407b2fcd7d421187c690e979e48383IABXgB5VpoeMe8+AmocO3PYgs/hXHL82OSZ7DQ+RgYpPKAhRWHK379yDIgBFcEiTrZN3ZAQAAQA9UHZkAgA9UHZkAwA9UHZkBAA9UHZk";
//const channelId = "minaRouf";

class CallScreen extends StatefulWidget {
  const CallScreen({
    Key? key,
    required this.userModel,
    required this.channelName,
  }) : super(key: key);
  final UserModel userModel;
  final String channelName;

  @override
  State<CallScreen> createState() => _CallScreen();
}

class _CallScreen extends State<CallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  RtcEngine? _engine;
  bool _isCameraFront = true;
  bool _isMicEnabled = true;
  final now = DateTime.now();
  int userGenerateUniqueId = 0;

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
    setState(() {
      _isCameraFront = !_isCameraFront;
    });
  }

  Future<void> toggleMicrophone() async {
    await _engine?.muteLocalAudioStream(!_isMicEnabled);
    setState(() {
      _isMicEnabled = !_isMicEnabled;
    });
  }

  void generateUniqueId() {
    int uniqueId = 147;
    userGenerateUniqueId = uniqueId;
  }

  Future<String> getToken() async {

    try {
      // String token = '';
      generateUniqueId();
      // String dc = widget.userModel.isVolunteer! ? '' : '&role=publisher';
      //
      // final res = await DioHelper.getData(
      //     url:
      //         'access_token?uid=$userGenerateUniqueId&channelName=${widget.channelName}$dc');
      // log(res.data['token'] as String,name: "Anas");
      // return res.data['token'] as String;


      return '006f5407b2fcd7d421187c690e979e48383IABm3/fOWC/9HNu8HXrSyfkQV0B5rzidcMgzKlTSVHDxa4oXxW5NAH/ZIgDrcGYlfBR9ZAQAAQAM0XtkAgAM0XtkAwAM0XtkBAAM0Xtk';
    }  catch (e,s) {
      log("Kos",stackTrace: s,name: "Anas");
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    try {
      await [Permission.microphone, Permission.camera].request();

      //create the engine
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            log("local user ${connection.localUid} joined",
                name: "onJoinChannelSuccess local");
            // log(token.toString(),name: 'blind token');
            setState(() {
              _localUserJoined = true;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            log("remote user $remoteUid joined", name: "onUserJoined");
            setState(() {
              _remoteUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            debugPrint("remote user $remoteUid left channel");
            setState(() {
              _remoteUid = null;
            });
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            debugPrint(
                '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          },
        ),
      );

      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.enableVideo();
      await _engine!.startPreview();

      await _engine!.joinChannel(
        token: await getToken(), //token,
        channelId: widget.channelName, //userName,
        uid: 111, //idRandom,
        options: const ChannelMediaOptions(),
      );
    } catch (e, t) {
      log(e.toString(), stackTrace: t, name: ' NANA ');
    }
  }


  void stopCall() async {
    await _engine?.leaveChannel();

    //token = '';
    _engine = null;
    Navigator.pop(context);
    // Rest of your code...
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Center(
              child: _remoteVideo(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 150,
                child: Center(
                  child: _localUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine!,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: toggleMicrophone,
                      icon: Icon(_isMicEnabled ? Icons.mic : Icons.mic_off)),
                  const SizedBox(
                    width: 20.0,
                  ),
                  IconButton(
                      onPressed: switchCamera, icon: Icon(Icons.switch_camera)),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        color: Colors.red),
                    child: IconButton(
                      onPressed: stopCall,
                      icon: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
