# flutter_local_notifications serialises its models with Gson (it needs their
# names and fields in release builds).
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keepattributes *Annotation*,Signature
