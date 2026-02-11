Launching lib\main.dart on SM F731N in debug mode...
√ Built build\app\outputs\flutter-apk\app-debug.apk
D/FlutterJNI( 7876): Beginning load of flutter...
D/FlutterJNI( 7876): flutter (null) was loaded normally!
I/flutter ( 7876): [IMPORTANT:flutter/shell/platform/android/android_context_vk_impeller.cc(62)] Using the Impeller rendering backend (Vulkan).
D/FlutterGeolocator( 7876): Attaching Geolocator to activity
D/FlutterGeolocator( 7876): Creating service.
D/FlutterGeolocator( 7876): Binding to location service.
D/FlutterGeolocator( 7876): Geolocator foreground service connected
D/FlutterGeolocator( 7876): Initializing Geolocator services
D/FlutterGeolocator( 7876): Flutter engine connected. Connected engine count 1
Connecting to VM Service at ws://127.0.0.1:61478/oMt8tZtvRyM=/ws
Connected to the VM Service.
I/flutter ( 7876): foreground step 1
I/flutter ( 7876): foreground step 2
I/InsetsSourceConsumer( 7876): applyRequestedVisibilityToControl: visible=true, type=statusBars, host=com.example.flight_steps/com.example.flight_steps.MainActivity
I/InsetsSourceConsumer( 7876): applyRequestedVisibilityToControl: visible=true, type=navigationBars, host=com.example.flight_steps/com.example.flight_steps.MainActivity
I/BLASTBufferQueue_Java( 7876): update, w= 1080 h= 2640 mName = VRI[MainActivity]@2ff39e4 mNativeObject= 0xb400007679d91000 sc.mNativeObject= 0xb400007613567fc0 format= -3 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3574 android.view.ViewRootImpl.relayoutWindow:11685 android.view.ViewRootImpl.performTraversals:4804 android.view.ViewRootImpl.doTraversal:3924 android.view.ViewRootImpl$TraversalRunnable.run:12903 android.view.Choreographer$CallbackRecord.run:1901
I/VRI[MainActivity]@2ff39e4( 7876): Relayout returned: old=(0,0,1080,2640) new=(0,0,1080,2640) relayoutAsync=false req=(1080,2640)0 dur=2 res=0x1 s={true 0xb400007625629e00} ch=false seqId=0
I/VRI[MainActivity]@2ff39e4( 7876): updateBoundsLayer: t=android.view.SurfaceControl$Transaction@2088461 sc=Surface(name=Bounds for - com.example.flight_steps/com.example.flight_steps.MainActivity@0)/@0x9fc1b86 frame=1
D/VRI[MainActivity]@2ff39e4( 7876): reportNextDraw android.view.ViewRootImpl.performTraversals:5443 android.view.ViewRootImpl.doTraversal:3924 android.view.ViewRootImpl$TraversalRunnable.run:12903 android.view.Choreographer$CallbackRecord.run:1901 android.view.Choreographer$CallbackRecord.run:1910
I/flutter ( 7876): foreground step 3
I/BLASTBufferQueue( 7876): [e220525 SurfaceView[com.example.flight_steps/com.example.flight_steps.MainActivity]@0#1](f:0,a:0,s:0) onFrameAvailable the first frame is available
I/SurfaceComposerClient( 7876): apply transaction with the first frame. layerId: 74779, bufferData(ID: 33827162423308, frameNumber: 1)
I/SurfaceView( 7876): 237110565 finishedDrawing
I/Choreographer( 7876): Skipped 73 frames! The application may be doing too much work on its main thread.
D/VRI[MainActivity]@2ff39e4( 7876): Setup new sync=wmsSync-VRI[MainActivity]@2ff39e4#1
I/VRI[MainActivity]@2ff39e4( 7876): Creating new active sync group VRI[MainActivity]@2ff39e4#2
D/VRI[MainActivity]@2ff39e4( 7876): Draw frame after cancel
D/VRI[MainActivity]@2ff39e4( 7876): registerCallbacksForSync syncBuffer=false
D/SurfaceView( 7876): 237110565 updateSurfacePosition RenderWorker, frameNr = 1, position = [0, 0, 1080, 2514] surfaceSize = 1080x2514
I/SV[237110565 MainActivity](7876): uSP: rtp = Rect(0, 0 - 1080, 2514) rtsw = 1080 rtsh = 2514
I/SV[237110565 MainActivity](7876): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SV[237110565 MainActivity](7876): aOrMT: VRI[MainActivity]@2ff39e4 t = android.view.SurfaceControl$Transaction@ed86be0 fN = 1 android.view.SurfaceView.-$$Nest$mapplyOrMergeTransaction:0 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1932 android.graphics.RenderNode$CompositePositionUpdateListener.positionChanged:401
I/VRI[MainActivity]@2ff39e4( 7876): mWNT: t=0xb4000076255b0380 mBlastBufferQueue=0xb400007679d91000 fn= 1 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SurfaceView.applyOrMergeTransaction:1863 android.view.SurfaceView.-$$Nest$mapplyOrMergeTransaction:0 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1932 
D/VRI[MainActivity]@2ff39e4( 7876): Received frameDrawingCallback syncResult=0 frameNum=1.
I/VRI[MainActivity]@2ff39e4( 7876): mWNT: t=0xb400007570a0a800 mBlastBufferQueue=0xb400007679d91000 fn= 1 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$12.onFrameDraw:15441 android.view.ThreadedRenderer$1.onFrameDraw:718 <bottom of call stack> 
I/VRI[MainActivity]@2ff39e4( 7876): Setting up sync and frameCommitCallback
I/BLASTBufferQueue( 7876): [VRI[MainActivity]@2ff39e4#0](f:0,a:0,s:0) onFrameAvailable the first frame is available
I/SurfaceComposerClient( 7876): apply transaction with the first frame. layerId: 74774, bufferData(ID: 33827162423313, frameNumber: 1)
I/VRI[MainActivity]@2ff39e4( 7876): Received frameCommittedCallback lastAttemptedDrawFrameNum=1 didProduceBuffer=true
D/HWUI    ( 7876): CFMS:: SetUp Pid : 7876    Tid : 7912
D/VRI[MainActivity]@2ff39e4( 7876): reportDrawFinished seqId=0
I/flutter ( 7876): step 1 condition: false
D/VRI[MainActivity]@2ff39e4( 7876): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb400007625629e00}
D/InputMethodManagerUtils( 7876): startInputInner - Id : 0
I/InputMethodManager( 7876): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
D/InputTransport( 7876): Input channel constructed: 'ClientS', fd=186
I/BLASTBufferQueue_Java( 7876): update, w= 1080 h= 2640 mName = VRI[MainActivity]@2ff39e4 mNativeObject= 0xb400007679d91000 sc.mNativeObject= 0xb400007613567fc0 format= -3 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3574 android.view.ViewRootImpl.relayoutWindow:11685 android.view.ViewRootImpl.performTraversals:4804 android.view.ViewRootImpl.doTraversal:3924 android.view.ViewRootImpl$TraversalRunnable.run:12903 android.view.Choreographer$CallbackRecord.run:1901 
I/VRI[MainActivity]@2ff39e4( 7876): Relayout returned: old=(0,0,1080,2640) new=(0,0,1080,2640) relayoutAsync=true req=(1080,2640)0 dur=0 res=0x0 s={true 0xb400007625629e00} ch=false seqId=0
I/VRI[MainActivity]@2ff39e4( 7876): updateBoundsLayer: t=android.view.SurfaceControl$Transaction@2088461 sc=Surface(name=Bounds for - com.example.flight_steps/com.example.flight_steps.MainActivity@0)/@0x9fc1b86 frame=2
I/VRI[MainActivity]@2ff39e4( 7876): registerCallbackForPendingTransactions
I/InputMethodManager( 7876): handleMessage: setImeVisibility visible=false
D/InsetsController( 7876): hide(ime(), fromIme=false)
I/ImeTracker( 7876): com.example.flight_steps:2a47856c: onCancelled at PHASE_CLIENT_ALREADY_HIDDEN
I/VRI[MainActivity]@2ff39e4( 7876): mWNT: t=0xb4000076255b1400 mBlastBufferQueue=0xb400007679d91000 fn= 2 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$10.onFrameDraw:6536 android.view.ViewRootImpl$4.onFrameDraw:2489 android.view.ThreadedRenderer$1.onFrameDraw:718 
I/flutter ( 7876): AppLifecycleState: AppLifecycleState.inactive
I/ImeFocusController( 7876): onPreWindowFocus: skipped hasWindowFocus=false mHasImeFocus=true
I/ImeFocusController( 7876): onPostWindowFocus: skipped hasWindowFocus=false mHasImeFocus=true
I/BLASTBufferQueue_Java( 7876): update, w= 1080 h= 2640 mName = VRI[MainActivity]@2ff39e4 mNativeObject= 0xb400007679d91000 sc.mNativeObject= 0xb400007613567fc0 format= -3 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3574 android.view.ViewRootImpl.relayoutWindow:11685 android.view.ViewRootImpl.performTraversals:4804 android.view.ViewRootImpl.doTraversal:3924 android.view.ViewRootImpl$TraversalRunnable.run:12903 android.view.Choreographer$CallbackRecord.run:1901 
I/VRI[MainActivity]@2ff39e4( 7876): Relayout returned: old=(0,0,1080,2640) new=(0,0,1080,2640) relayoutAsync=true req=(1080,2640)0 dur=0 res=0x0 s={true 0xb400007625629e00} ch=false seqId=0
I/VRI[MainActivity]@2ff39e4( 7876): updateBoundsLayer: t=android.view.SurfaceControl$Transaction@2088461 sc=Surface(name=Bounds for - com.example.flight_steps/com.example.flight_steps.MainActivity@0)/@0x9fc1b86 frame=3
I/VRI[MainActivity]@2ff39e4( 7876): registerCallbackForPendingTransactions
I/VRI[MainActivity]@2ff39e4( 7876): mWNT: t=0xb40000756e963680 mBlastBufferQueue=0xb400007679d91000 fn= 3 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$10.onFrameDraw:6536 android.view.ViewRootImpl$4.onFrameDraw:2489 android.view.ThreadedRenderer$1.onFrameDraw:718 
D/VRI[MainActivity]@2ff39e4( 7876): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb400007625629e00}
I/flutter ( 7876): AppLifecycleState: AppLifecycleState.resumed
D/InputMethodManagerUtils( 7876): startInputInner - Id : 0
I/InputMethodManager( 7876): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/InputMethodManager( 7876): handleMessage: setImeVisibility visible=false
D/InsetsController( 7876): hide(ime(), fromIme=false)
I/ImeTracker( 7876): com.example.flight_steps:2148f0ce: onCancelled at PHASE_CLIENT_ALREADY_HIDDEN
D/InputTransport( 7876): Input channel constructed: 'ClientS', fd=203
D/ProfileInstaller( 7876): Installing profile for com.example.flight_steps
I/VRI[MainActivity]@2ff39e4( 7876): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@2ff39e4
D/InputTransport( 7876): Input channel destroyed: 'ClientS', fd=203
I/flutter ( 7876): Phone: 01041850688, Employee ID: devel
I/flutter ( 7876): https://test-flight-steps.mapside.kr/api/user/login post result : {uuid: cd8fc1a0c3b94bacbc01b092c5520b73, username: 박선하, phoneNumber: 01041850688, employeeId: devel, groups: [user, airline_meal], config: {functionEnabled: [work, tracker, agreelist]}}
I/flutter ( 7876): 쿠키 저장됨: [session=kM51sVuV12%2BqQQmqE%2FM842JHJ2CfuS%2BdZHrLWFc6AnWbFWxAz0pB1EIcA%2BGATyF67Ojheh3uZQp0ttShuzPVZr4s3z4oC4dKOo0LDAFHzCrHc14%3D%3BWaIQZ8cEr2iDyQnd3Au8MlnDlpTeyqpV; Max-Age=86400; Path=/; HttpOnly; SameSite=Lax]
I/flutter ( 7876): getUser.config [work, tracker, agreelist]
I/flutter ( 7876): checkPermission
I/flutter ( 7876): setLocationListener
I/flutter ( 7876): {Content-Type: application/json}
I/flutter ( 7876): login step 2
I/flutter ( 7876): foreground step 4
I/flutter ( 7876): foreground step 5
I/flutter ( 7876): {Content-Type: application/json, cookie: session=kM51sVuV12%2BqQQmqE%2FM842JHJ2CfuS%2BdZHrLWFc6AnWbFWxAz0pB1EIcA%2BGATyF67Ojheh3uZQp0ttShuzPVZr4s3z4oC4dKOo0LDAFHzCrHc14%3D%3BWaIQZ8cEr2iDyQnd3Au8MlnDlpTeyqpV; Max-Age=86400; Path=/; HttpOnly; SameSite=Lax}
W/WindowOnBackDispatcher( 7876): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher( 7876): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/AdrenoVK-0( 7876): QUALCOMM build          : dc3d4da3a2, Idd45c2c082
I/AdrenoVK-0( 7876): Build Date              : 05/30/25
I/AdrenoVK-0( 7876): Shader Compiler Version : E031.41.03.62
I/AdrenoVK-0( 7876): Local Branch            : 
I/AdrenoVK-0( 7876): Remote Branch           : refs/tags/AU_LINUX_ANDROID_LA.VENDOR.13.2.0.11.00.00.856.062
I/AdrenoVK-0( 7876): Remote Branch           : NONE
I/AdrenoVK-0( 7876): Reconstruct Branch      : NOTHING
I/AdrenoVK-0( 7876): Build Config            : S P 14.1.4 AArch64
I/AdrenoVK-0( 7876): Driver Path             : /vendor/lib64/hw/vulkan.adreno.so
I/AdrenoVK-0( 7876): Driver Version          : 0676.73
I/AdrenoVK-0( 7876): PFP                     : 0x01740181
I/AdrenoVK-0( 7876): ME                      : 0x00000000
I/AdrenoVK-0( 7876): Application Name    : Impeller
I/AdrenoVK-0( 7876): Application Version : 0x00800000
I/AdrenoVK-0( 7876): Engine Name         : Impeller
I/AdrenoVK-0( 7876): Engine Version      : 0x00400000
I/AdrenoVK-0( 7876): Api Version         : 0x00401000
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3b9ff250 provided to vkGetPhysicalDeviceFeatures2
I/AdrenoVK-0( 7876): Unknown struct with type 0x3ba17508 provided to vkGetPhysicalDeviceFeatures2
I/flutter ( 7876): [IMPORTANT:flutter/shell/platform/android/android_context_vk_impeller.cc(62)] Using the Impeller rendering backend (Vulkan).
D/FlutterGeolocator( 7876): Geolocator foreground service connected
D/FlutterGeolocator( 7876): Initializing Geolocator services
D/FlutterGeolocator( 7876): Flutter engine connected. Connected engine count 2
I/BLASTBufferQueue_Java( 7876): update, w= 1080 h= 2640 mName = VRI[MainActivity]@2ff39e4 mNativeObject= 0xb400007679d91000 sc.mNativeObject= 0xb400007613567fc0 format= -3 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3574 android.view.ViewRootImpl.relayoutWindow:11685 android.view.ViewRootImpl.performTraversals:4804 android.view.ViewRootImpl.doTraversal:3924 android.view.ViewRootImpl$TraversalRunnable.run:12903 android.view.Choreographer$CallbackRecord.run:1901 
I/VRI[MainActivity]@2ff39e4( 7876): Relayout returned: old=(0,0,1080,2640) new=(0,0,1080,2640) relayoutAsync=true req=(1080,2640)0 dur=0 res=0x0 s={true 0xb400007625629e00} ch=false seqId=0
I/VRI[MainActivity]@2ff39e4( 7876): updateBoundsLayer: t=android.view.SurfaceControl$Transaction@2088461 sc=Surface(name=Bounds for - com.example.flight_steps/com.example.flight_steps.MainActivity@0)/@0x9fc1b86 frame=4
I/VRI[MainActivity]@2ff39e4( 7876): registerCallbackForPendingTransactions
I/VRI[MainActivity]@2ff39e4( 7876): mWNT: t=0xb400007570a0be80 mBlastBufferQueue=0xb400007679d91000 fn= 4 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$10.onFrameDraw:6536 android.view.ViewRootImpl$4.onFrameDraw:2489 android.view.ThreadedRenderer$1.onFrameDraw:718
I/flutter ( 7876): https://test-flight-steps.mapside.kr/api/config/checklist get result : [{uuid: 925ad592749d44d1af60291cb9fb517f, name: GPS를 통한 실시간 위치 정보 수집, description: 업무 운영 효율화 및 안전 관리를 위해 위치 정보를 수집 및 이용합니다. 본 정보는 근무 시간 내에 한하여 수집하며, 앱을 종료하게 될 경우 수집되지 않습니다. 내용을 이해하고 이에 동의하십니까?, value: null}, {uuid: 9c2f43f85f0c4319b99e4fe9d7262df6, name: GPS 수집 정보 보유 기간, description: 본 수집 정보는 서비스 제공 및 업무 분석 목적 달성 시까지(단, 퇴사 시 또는 동의 철회 시 즉시 파기) 수집 및 보관됩니다. 위치정보법 및 관련 법령에 따라 로그 기록은 일정 기간 보존될 수 있습니다. 내용을 이해하고 이에 동의하십니까?, value: null}]
I/flutter ( 7876): onStart : 2026-02-11 12:09:41.809646Z
I/flutter ( 7876): https://test-flight-steps.mapside.kr/api/config/gps get error : DioException [bad response]: This exception was thrown because the response has a status code of 401 and RequestOptions.validateStatus was configured to throw for this status code.
I/flutter ( 7876): The status code of 401 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
I/flutter ( 7876): Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
I/flutter ( 7876): In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.
I/flutter ( 7876):
E/flutter ( 7876): [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Bad state: No element
E/flutter ( 7876): #0 ListBase.firstWhere (dart:collection/list.dart:132:5)
list.dart:132
E/flutter ( 7876): #1 ServiceLocation.setLocationListener (package:flight_steps/service/location.dart:33:16)
location.dart:33
E/flutter ( 7876): <asynchronous suspension>
E/flutter ( 7876):
I/flutter ( 7876): {Content-Type: application/json}
I/VRI[MainActivity]@2ff39e4( 7876): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@2ff39e4
I/flutter ( 7876): https://test-flight-steps.mapside.kr/api/config/gps get error : DioException [bad response]: This exception was thrown because the response has a status code of 401 and RequestOptions.validateStatus was configured to throw for this status code.
I/flutter ( 7876): The status code of 401 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
I/flutter ( 7876): Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
I/flutter ( 7876): In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.
I/flutter ( 7876):
I/flutter ( 7876): initTask response []
