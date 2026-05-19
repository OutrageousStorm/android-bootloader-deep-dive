#!/bin/bash
# secureboot-validator.sh -- Check secure boot state and verify device trust
# Usage: ./secureboot-validator.sh

echo "🔐 Secure Boot Validator"
echo "========================"

VERIFIED_BOOT=$(adb shell getprop ro.boot.verifiedbootstate)
UNLOCK_STATE=$(adb shell getprop ro.boot.verificationstate)
VBMETA=$(adb shell test -f /dev/block/by-name/vbmeta && echo "found" || echo "missing")

echo "\nVerifiedBoot: $VERIFIED_BOOT"
echo "VerificationState: $UNLOCK_STATE"
echo "vbmeta partition: $VBMETA"

if [[ "$VERIFIED_BOOT" == "green" || "$VERIFIED_BOOT" == "yellow" ]]; then
  echo "\n✅ Bootloader locked (secure boot active)"
else
  echo "\n⚠️  Bootloader unlocked — secure boot bypassed"
fi

echo "\nBoot info:"
adb shell getprop | grep -E "ro.boot.(verif|lock)" | sed 's/^/  /'
