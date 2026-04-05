#!/usr/bin/env python3
import subprocess
import sys

TOKEN = "8187479612:AAE3ZF-qItlSd2MhoZX2e0NbvTBaeAVemhc"
CHAT_ID = "7250558059"

def main():
    print("🔍 Menguji koneksi ke Telegram Bot...")
    
    # Test kirim pesan teks sederhana
    cmd = [
        "curl", "-s", "-X", "POST",
        f"https://api.telegram.org/bot{TOKEN}/sendMessage",
        "-d", f"chat_id={CHAT_ID}",
        "-d", "text=✅ *Test Koneksi Berhasil!*\nBot telah terhubung ke server STB.",
        "-d", "parse_mode=Markdown"
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if '"ok":true' in result.stdout:
        print("✅ SUKSES! Pesan test telah dikirim ke Telegram.")
        print("Silakan cek chat kamu sekarang.")
    else:
        print("❌ GAGAL mengirim pesan.")
        print(f"Response API: {result.stdout}")
        if result.stderr:
            print(f"Error: {result.stderr}")
        print("\nKemungkinan penyebab:")
        print("1. Token Bot atau Chat ID salah/kedaluwarsa")
        print("2. Server STB tidak terhubung ke internet")
        print("3. Bot belum di-start atau di-block oleh user")
        sys.exit(1)

if __name__ == "__main__":
    main()
