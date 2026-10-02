#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess
import sys

ANDROID_COMPILE_SDK = 36
ANDROID_TARGET_SDK = 36
ANDROID_MIN_SDK = 24
IOS_DEPLOYMENT_TARGET = "13.0"

ROOT = Path(__file__).resolve().parents[1]


def add_manifest_permission(text: str, permission: str) -> str:
    marker = f"android.permission.{permission}"
    if marker in text:
        return text
    line = f'    <uses-permission android:name="{marker}"/>\n'
    return text.replace("<application", line + "    <application", 1)


def generate_brand_assets() -> None:
    subprocess.run(
        [sys.executable, str(ROOT / "tool" / "generate_brand_assets.py")],
        check=True,
        cwd=ROOT,
    )


def configure_ios() -> None:
    path = ROOT / "ios" / "Runner" / "Info.plist"
    if path.exists():
        text = path.read_text(encoding="utf-8")
        text = re.sub(
            r"(<key>CFBundleDisplayName</key>\s*<string>).*?(</string>)",
            r"\1WORKLOG\2",
            text,
            flags=re.S,
        )

        entries = {
            "NSCameraUsageDescription": (
                "WORKLOG koristi kameru za fotografiranje stanja prije, tijekom i nakon radova."
            ),
            "NSPhotoLibraryUsageDescription": (
                "WORKLOG koristi galeriju za dodavanje fotografija uz terenske poslove."
            ),
            "NSPhotoLibraryAddUsageDescription": (
                "WORKLOG može spremiti fotografije i dokumente koje izradite u aplikaciji."
            ),
            "NSFaceIDUsageDescription": (
                "WORKLOG koristi Face ID za zaštitu poslovnih podataka u aplikaciji."
            ),
        }
        for key, value in entries.items():
            if f"<key>{key}</key>" in text:
                continue
            snippet = f"\t<key>{key}</key>\n\t<string>{value}</string>\n"
            text = text.replace("</dict>", snippet + "</dict>", 1)

        path.write_text(text, encoding="utf-8")

    project = ROOT / "ios" / "Runner.xcodeproj" / "project.pbxproj"
    if project.exists():
        text = project.read_text(encoding="utf-8")
        text = re.sub(
            r"IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+;",
            f"IPHONEOS_DEPLOYMENT_TARGET = {IOS_DEPLOYMENT_TARGET};",
            text,
        )
        project.write_text(text, encoding="utf-8")

    podfile = ROOT / "ios" / "Podfile"
    if podfile.exists():
        text = podfile.read_text(encoding="utf-8")
        platform_line = f"platform :ios, '{IOS_DEPLOYMENT_TARGET}'"
        if re.search(r"^#?\s*platform :ios,", text, flags=re.M):
            text = re.sub(
                r"^#?\s*platform :ios,\s*'[^']+'",
                platform_line,
                text,
                count=1,
                flags=re.M,
            )
        else:
            text = platform_line + "\n" + text
        podfile.write_text(text, encoding="utf-8")


def configure_android_manifest() -> None:
    path = ROOT / "android" / "app" / "src" / "main" / "AndroidManifest.xml"
    if not path.exists():
        return

    text = path.read_text(encoding="utf-8")
    text = re.sub(
        r'android:label="[^"]*"',
        'android:label="WORKLOG"',
        text,
        count=1,
    )
    text = add_manifest_permission(text, "USE_BIOMETRIC")
    text = add_manifest_permission(text, "POST_NOTIFICATIONS")

    if "android:enableOnBackInvokedCallback" not in text:
        text = text.replace(
            "<application",
            '<application\n        android:enableOnBackInvokedCallback="true"',
            1,
        )
    if "android:usesCleartextTraffic" not in text:
        text = text.replace(
            "<application",
            '<application\n        android:usesCleartextTraffic="false"',
            1,
        )

    path.write_text(text, encoding="utf-8")


def configure_android_activity() -> None:
    candidates = list((ROOT / "android" / "app" / "src" / "main").rglob("MainActivity.kt"))
    for path in candidates:
        text = path.read_text(encoding="utf-8")
        text = text.replace(
            "import io.flutter.embedding.android.FlutterActivity",
            "import io.flutter.embedding.android.FlutterFragmentActivity",
        )
        text = text.replace(
            "FlutterActivity()",
            "FlutterFragmentActivity()",
        )
        path.write_text(text, encoding="utf-8")


def configure_android_theme() -> None:
    roots = [
        ROOT / "android" / "app" / "src" / "main" / "res" / "values" / "styles.xml",
        ROOT
        / "android"
        / "app"
        / "src"
        / "main"
        / "res"
        / "values-night"
        / "styles.xml",
    ]
    for path in roots:
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        text = re.sub(
            r'(<style\s+name="LaunchTheme"\s+parent=")[^"]+(")',
            r"\1Theme.AppCompat.DayNight\2",
            text,
            count=1,
        )
        text = text.replace(
            "<item name=\"android:windowBackground\">@drawable/launch_background</item>",
            "<item name=\"android:windowBackground\">@drawable/launch_background</item>",
        )
        path.write_text(text, encoding="utf-8")

    v31 = (
        ROOT
        / "android"
        / "app"
        / "src"
        / "main"
        / "res"
        / "values-v31"
        / "styles.xml"
    )
    v31.parent.mkdir(parents=True, exist_ok=True)
    v31.write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="Theme.AppCompat.DayNight">
        <item name="android:windowSplashScreenBackground">@color/worklog_splash_background</item>
        <item name="android:windowSplashScreenAnimatedIcon">@drawable/worklog_foreground</item>
        <item name="android:windowSplashScreenIconBackgroundColor">@color/worklog_splash_background</item>
        <item name="android:windowLightStatusBar">false</item>
        <item name="android:navigationBarColor">@color/worklog_splash_background</item>
    </style>
</resources>
""",
        encoding="utf-8",
    )


def configure_android_gradle() -> None:
    kotlin_path = ROOT / "android" / "app" / "build.gradle.kts"
    groovy_path = ROOT / "android" / "app" / "build.gradle"

    if kotlin_path.exists():
        text = kotlin_path.read_text(encoding="utf-8")
        text = re.sub(
            r"compileSdk\s*=\s*flutter\.compileSdkVersion",
            f"compileSdk = {ANDROID_COMPILE_SDK}",
            text,
        )
        text = re.sub(
            r"minSdk\s*=\s*flutter\.minSdkVersion",
            f"minSdk = {ANDROID_MIN_SDK}",
            text,
        )
        text = re.sub(
            r"targetSdk\s*=\s*flutter\.targetSdkVersion",
            f"targetSdk = {ANDROID_TARGET_SDK}",
            text,
        )
        if "isCoreLibraryDesugaringEnabled" not in text:
            text = text.replace(
                "compileOptions {",
                "compileOptions {\n        isCoreLibraryDesugaringEnabled = true",
                1,
            )
        text = text.replace("JavaVersion.VERSION_11", "JavaVersion.VERSION_17")
        text = re.sub(
            r"jvmTarget\s*=\s*JavaVersion\.VERSION_\d+\.toString\(\)",
            "jvmTarget = JavaVersion.VERSION_17.toString()",
            text,
        )

        signing_prelude = """
val worklogKeystorePath = System.getenv("WORKLOG_KEYSTORE_PATH")
val worklogKeystorePassword = System.getenv("WORKLOG_KEYSTORE_PASSWORD")
val worklogKeyAlias = System.getenv("WORKLOG_KEY_ALIAS")
val worklogKeyPassword = System.getenv("WORKLOG_KEY_PASSWORD")

"""
        if "val worklogKeystorePath" not in text:
            android_index = text.find("android {")
            text = text[:android_index] + signing_prelude + text[android_index:]

        if 'create("worklogRelease")' not in text:
            marker = "    buildTypes {"
            signing_block = """    signingConfigs {
        if (!worklogKeystorePath.isNullOrBlank()) {
            create("worklogRelease") {
                storeFile = file(worklogKeystorePath)
                storePassword = worklogKeystorePassword
                keyAlias = worklogKeyAlias
                keyPassword = worklogKeyPassword
            }
        }
    }

"""
            text = text.replace(marker, signing_block + marker, 1)

        text = text.replace(
            'signingConfig = signingConfigs.getByName("debug")',
            """signingConfig = if (!worklogKeystorePath.isNullOrBlank()) {
                signingConfigs.getByName("worklogRelease")
            } else {
                signingConfigs.getByName("debug")
            }""",
        )

        if "coreLibraryDesugaring(" not in text:
            text = text.rstrip() + (
                '\n\ndependencies {\n'
                '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n'
                '}\n'
            )
        kotlin_path.write_text(text, encoding="utf-8")
        return

    if groovy_path.exists():
        text = groovy_path.read_text(encoding="utf-8")
        text = re.sub(
            r"compileSdkVersion\s+flutter\.compileSdkVersion",
            f"compileSdkVersion {ANDROID_COMPILE_SDK}",
            text,
        )
        text = text.replace(
            "minSdkVersion flutter.minSdkVersion",
            f"minSdkVersion {ANDROID_MIN_SDK}",
        )
        text = text.replace(
            "targetSdkVersion flutter.targetSdkVersion",
            f"targetSdkVersion {ANDROID_TARGET_SDK}",
        )
        if "coreLibraryDesugaringEnabled" not in text:
            text = text.replace(
                "compileOptions {",
                "compileOptions {\n        coreLibraryDesugaringEnabled true",
                1,
            )
        text = text.replace("JavaVersion.VERSION_11", "JavaVersion.VERSION_17")
        if "coreLibraryDesugaring " not in text:
            text = text.rstrip() + (
                "\n\ndependencies {\n"
                "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n"
                "}\n"
            )
        groovy_path.write_text(text, encoding="utf-8")


def verify_configuration() -> None:
    kotlin_path = ROOT / "android" / "app" / "build.gradle.kts"
    if kotlin_path.exists():
        text = kotlin_path.read_text(encoding="utf-8")
        required = (
            f"compileSdk = {ANDROID_COMPILE_SDK}",
            f"minSdk = {ANDROID_MIN_SDK}",
            f"targetSdk = {ANDROID_TARGET_SDK}",
        )
        for value in required:
            if value not in text:
                raise RuntimeError(f"Nedostaje Android konfiguracija: {value}")

    project = ROOT / "ios" / "Runner.xcodeproj" / "project.pbxproj"
    if project.exists():
        text = project.read_text(encoding="utf-8")
        if f"IPHONEOS_DEPLOYMENT_TARGET = {IOS_DEPLOYMENT_TARGET};" not in text:
            raise RuntimeError("iOS deployment target nije pravilno postavljen.")


if __name__ == "__main__":
    generate_brand_assets()
    configure_ios()
    configure_android_manifest()
    configure_android_activity()
    configure_android_theme()
    configure_android_gradle()
    verify_configuration()
    print(
        "WORKLOG platforme su konfigurirane: "
        f"Android compile/target {ANDROID_COMPILE_SDK}, min {ANDROID_MIN_SDK}; "
        f"iOS {IOS_DEPLOYMENT_TARGET}+."
    )
