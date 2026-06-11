# ProGuard Rules for LinkShelf Release Build

# Keep Drift database classes, generated components, and schema tables
-keep class * extends drift.GeneratedDatabase { *; }
-keep class * extends drift.Table { *; }
-keep class * extends java.lang.Enum { *; }

# Keep native sqlite3 libraries and dynamic wrappers
-keep class org.sqlite.** { *; }
-keep class sqlite3_flutter_libs.** { *; }

# Keep local notification receiver/service classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
