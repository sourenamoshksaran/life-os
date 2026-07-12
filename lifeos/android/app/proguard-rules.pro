# Isar — keep generated schema/collection classes and native bindings.
-keep class io.isar.** { *; }
-dontwarn io.isar.**

# flutter_local_notifications — keep its receivers/services (also
# declared explicitly in AndroidManifest.xml) and Gson-reflected models.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
