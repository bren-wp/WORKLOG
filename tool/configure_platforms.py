#!/usr/bin/env python3
from pathlib import Path
import re


def add_manifest_permission(text: str, permission: str) -> str:
    marker = f'android.permission.{permission}'
    if marker in text:
        return text
    line = f'    <uses-permission android:name="{marker}"/>\n'
    return text.replace("<application", line + "    <application", 1)


def configure_ios() -> None:
    path = Path("ios/Runner/Info.plist")
    if not path.exists():
        return

    text = path.read_text(encoding="utf-8")
    text = re.sub(
        r"(<key>CFBundleDisplayName</key>\s*<string>).*?(</string>)",
        r"\1WORKLOG\2",
        text,
        flags=re.S,
    )

    entries = {
        "NSCameraUsageDescription": "WORKLOG koristi kameru za fotografiranje stanja prije, tijekom i nakon radova.",
        "NSPhotoLibraryUsageDescription": "WORKLOG koristi galeriju za dodavanje fotografija uz terenske poslove.",
        "NSPhotoLibraryAddUsageDescription": "WORKLOG može spremiti fotografije i dokumente koje izradite u aplikaciji.",
        "NSFaceIDUsageDescription": "WORKLOG koristi Face ID za zaštitu poslovnih podataka u aplikaciji.",
    }
    for key, value in entries.items():
        if f"<key>{key}</key>" in text:
            continue
        snippet = f"\t<key>{key}</key>\n\t<string>{value}</string>\n"
        text = text.replace("</dict>", snippet + "</dict>", 1)

    path.write_text(text, encoding="utf-8")


def configure_android_manifest() -> None:
    path = Path("android/app/src/main/AndroidManifest.xml")
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
    path.write_text(text, encoding="utf-8")


def configure_android_activity() -> None:
    candidates = list(Path("android/app/src/main").rglob("MainActivity.kt"))
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


def configure_android_gradle() -> None:
    kotlin_path = Path("android/app/build.gradle.kts")
    groovy_path = Path("android/app/build.gradle")

    if kotlin_path.exists():
        text = kotlin_path.read_text(encoding="utf-8")
        if "isCoreLibraryDesugaringEnabled" not in text:
            text = text.replace(
                "compileOptions {",
                "compileOptions {\n        isCoreLibraryDesugaringEnabled = true",
                1,
            )
        text = text.replace(
            "JavaVersion.VERSION_11",
            "JavaVersion.VERSION_17",
        )
        text = re.sub(
            r'jvmTarget\s*=\s*JavaVersion\.VERSION_\d+\.toString\(\)',
            'jvmTarget = JavaVersion.VERSION_17.toString()',
            text,
        )
        if "coreLibraryDesugaring(" not in text:
            dependency = (
                '\ndependencies {\n'
                '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n'
                '}\n'
            )
            text = text.rstrip() + dependency
        kotlin_path.write_text(text, encoding="utf-8")
        return

    if groovy_path.exists():
        text = groovy_path.read_text(encoding="utf-8")
        if "coreLibraryDesugaringEnabled" not in text:
            text = text.replace(
                "compileOptions {",
                "compileOptions {\n        coreLibraryDesugaringEnabled true",
                1,
            )
        text = text.replace(
            "JavaVersion.VERSION_11",
            "JavaVersion.VERSION_17",
        )
        if "coreLibraryDesugaring " not in text:
            dependency = (
                "\ndependencies {\n"
                "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n"
                "}\n"
            )
            text = text.rstrip() + dependency
        groovy_path.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    configure_ios()
    configure_android_manifest()
    configure_android_activity()
    configure_android_gradle()
    print("WORKLOG platforme su konfigurirane.")
