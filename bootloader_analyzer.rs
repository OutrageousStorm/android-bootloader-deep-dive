// bootloader_analyzer.rs -- Rust CLI to analyze device bootloader state
// Compile: rustc bootloader_analyzer.rs -o bootloader_analyzer
// Usage: ./bootloader_analyzer [serial]

use std::process::Command;
use std::env;

fn adb(args: &[&str]) -> String {
    let output = Command::new("adb")
        .args(args)
        .output()
        .expect("Failed to run adb");
    String::from_utf8_lossy(&output.stdout).to_string()
}

fn check_bootloader(serial: &str) -> (String, String, String) {
    let mut args = vec![];
    if serial != "" {
        args.push("-s");
        args.push(serial);
    }
    args.push("getvar");
    args.push("all");
    
    let unlock_state = adb(&["shell", "getprop", "ro.boot.verifiedbootstate"]);
    let bl_version = adb(&["shell", "getprop", "ro.bootloader"]);
    let device = adb(&["shell", "getprop", "ro.product.model"]);
    
    (unlock_state, bl_version, device)
}

fn main() {
    let serial = env::args().nth(1).unwrap_or_default();
    println!("\n🔓 Bootloader Analyzer\n");
    
    let (unlock, bl_ver, device) = check_bootloader(&serial);
    
    println!("Device:          {}", device.trim());
    println!("Bootloader:      {}", bl_ver.trim());
    println!("Verified Boot:   {}", unlock.trim());
    
    let is_locked = unlock.contains("green") || unlock.contains("locked");
    let status = if is_locked { "🔒 LOCKED" } else { "🔓 UNLOCKED" };
    println!("Status:          {}\n", status);
    
    if is_locked {
        println!("⚠️  Device is bootloader-locked. Options:");
        println!("   1. OEM unlock via settings (if available)");
        println!("   2. Use fastboot oem unlock (device-specific)");
        println!("   3. Check XDA forums for unlock exploit");
    } else {
        println!("✅ Bootloader is unlocked. You can flash custom ROMs.");
    }
}
