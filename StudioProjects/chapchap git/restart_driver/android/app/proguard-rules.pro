# ChapChap Driver - Règles ProGuard Optimisées

## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

## Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

## Dio (HTTP client)
-keep class io.flutter.plugins.** { *; }

## Stripe (commenté car package supprimé)
# -dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
# -dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
# -dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
# -dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
# -dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

## Optimisations générales
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

## Garder les attributs pour le debugging
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions