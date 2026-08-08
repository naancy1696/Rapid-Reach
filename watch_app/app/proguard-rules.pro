# ProGuard rules for Rapid Reach Wear OS

# Keep the main activity
-keep class com.rapidreach.wearos.MainActivity { *; }

# Keep Jetpack Compose classes
-keep class androidx.compose.** { *; }
-keepnames class androidx.compose.** { *; }

# Keep Wear OS specific classes
-keep class androidx.wear.** { *; }
-keepnames class androidx.wear.** { *; }

# Keep Kotlin metadata
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Optimization
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Renaming
-allowaccessmodification
-repackageclasses

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
