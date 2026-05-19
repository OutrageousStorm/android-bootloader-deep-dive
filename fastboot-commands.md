# Fastboot Commands Reference

Complete fastboot command reference with real-world examples.

## Device Info
```bash
fastboot devices              # list connected devices
fastboot getvar all          # dump all vars (serial, unlocked, product, etc)
fastboot getvar bootloader   # get bootloader version
fastboot getvar is-userspace # check if running fastbootd vs fastboot
fastboot getvar product      # device codename
fastboot getvar max-download-size
```

## Flashing
```bash
fastboot flash boot boot.img                    # flash boot partition
fastboot flash system system.img                # flash system (A/B: flashes inactive slot)
fastboot flash vendor vendor.img
fastboot flash recovery recovery.img            # old devices only
fastboot flash vbmeta vbmeta.img

# Disable AVB (Android Verified Boot) for testing
fastboot flash vbmeta --disable-verity --disable-verification vbmeta.img

# A/B bootloader: force slot
fastboot --set-active=a
fastboot --set-active=b
```

## Erase
```bash
fastboot erase system           # wipe system partition
fastboot erase userdata         # wipe /data (user files, cache)
fastboot erase cache
fastboot erase recovery
fastboot erase all              # dangerous!
fastboot -w                     # shorthand: wipe data + cache
```

## Bootloader
```bash
fastboot reboot                 # reboot to system
fastboot reboot bootloader      # reboot back to fastboot
fastboot reboot fastboot        # reboot to fastbootd (recovery mode for system flashing)
fastboot reboot recovery

fastboot oem unlock             # unlock bootloader (device-specific, erases data!)
fastboot oem lock               # lock bootloader
fastboot flashing unlock        # Pixel: unlock
fastboot flashing lock          # Pixel: lock

fastboot oem device-info        # Samsung: show device state
```

## Variables & Validation
```bash
# Check if image is valid
fastboot verify system.img

# Get free space before flashing
fastboot getvar max-download-size

# Sparse vs raw images
fastboot flash system system.img   # sparse (optimized)
fastboot flash system system.raw   # raw (larger, safer)
```

## Advanced
```bash
# Update bootloader itself (dangerous!)
fastboot flash bootloader bootloader-redfin-redfin-1.0.img
fastboot reboot-bootloader

# Fetch images from device
fastboot fetch:raw system out.img  # download from device

# Upload large files in chunks
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img

# Stay in fastboot after reboot
fastboot reboot && fastboot devices
```

## Common Issues

**"device offline"** — USB connection lost
```bash
fastboot kill-server
fastboot devices  # reconnect
```

**"FAILED (remote: 'data too large')"** — partition too small
```bash
# Use sparse image or resize partition
fastboot getvar partition-size:system
```

**"FAILED (remote: 'Permission denied')"** — SELinux or bootloader lock
```bash
fastboot flashing unlock
```

**Device stuck in fastboot** — force reboot
```bash
fastboot reboot
# if that fails:
adb reboot bootloader
# if ADB not available, remove battery for 10s then reconnect
```
