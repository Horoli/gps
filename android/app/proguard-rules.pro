# Dio 관련 클래스 유지
-keep class io.flutter.plugins.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keep class com.github.tekartik.sqflite.** { *; }

# BehaviorSubject 관련 클래스 유지
-keep class io.reactivex.** { *; }
-keep class io.reactivex.rxjava3.** { *; }
-keep class rx.** { *; }

# 모델 클래스 유지
-keep class com.yourpackage.models.** { *; }