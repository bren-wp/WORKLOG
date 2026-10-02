#!/usr/bin/env python3
from pathlib import Path
import re


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
    }
    for key, value in entries.items():
        if f"<key>{key}</key>" in text:
            continue
        snippet = f"\t<key>{key}</key>\n\t<string>{value}</string>\n"
        text = text.replace("</dict>", snippet + "</dict>", 1)

    path.write_text(text, encoding="utf-8")


def configure_android() -> None:
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
    path.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    configure_ios()
    configure_android()
    print("WORKLOG platforme su konfigurirane.")
