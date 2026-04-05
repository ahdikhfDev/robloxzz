#!/usr/bin/env python3
import sys
import os
import subprocess

TOKEN = "8187479612:AAE3ZF-qItlSd2MhoZX2e0NbvTBaeAVemhc"
CHAT_ID = "7250558059"

def send_document(filepath):
    filename = os.path.basename(filepath)
    cmd = [
        "curl", "-s", "-F", f"chat_id={CHAT_ID}",
        "-F", f"document=@{filepath}",
        "-F", f"caption=File: {filename}",
        f"https://api.telegram.org/bot{TOKEN}/sendDocument"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 kirim_tele.py <file_path>")
        sys.exit(1)
    filepath = sys.argv[1]
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        sys.exit(1)
    result = send_document(filepath)
    print(result)
