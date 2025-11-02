# Flutter Local Notifications - Prevent obfuscation
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Gson (used by notification plugin for serialization)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep notification data classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
