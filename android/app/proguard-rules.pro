## Keep Image Cropper / uCrop (CanHub / Yalantis)
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
-keep class com.canhub.cropper.** { *; }
-dontwarn com.canhub.cropper.**

## Flutter InAppWebView
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**

## Keep Activities referenced by libraries
-keep public class * extends android.app.Activity

## Keep Providers used for file sharing
-keep class androidx.core.content.FileProvider { *; }

