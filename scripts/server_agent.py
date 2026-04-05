#!/usr/bin/env python3
import subprocess,sys,requests,json
T="8187479612:AAE3ZF-qItlSd2MhoZX2e0NbvTBaeAVemhc"
C="7250558059"
M={"ram":"free -h","disk":"df -h","cpu":"top -bn1 | head -15","load":"uptime","process":"ps aux --sort=-%mem | head -10","internet":"curl -s -o /dev/null -w '%{http_code}' https://api.openrouter.ai","services":"systemctl list-units --type=service --state=running | head -20","nullclaw":"systemctl status nullclaw"}
def s(m):
    try:requests.post(f"https://api.telegram.org/bot{T}/sendMessage",json={"chat_id":C,"text":m,"parse_mode":"Markdown"},timeout=10)
    except:pass
def x(c):
    try:r=subprocess.run(c,shell=True,capture_output=True,text=True,timeout=30);return r.stdout or r.stderr or "No output"
    except:return"Error"
if len(sys.argv)<2:print(json.dumps({"error":"Usage: server_agent.py <command>"}));sys.exit(1)
k=sys.argv[1].lower()
o=x(M.get(k,k))
s(f"Server Report - {k.upper()}\n```\n{o[:4000]}\n```")
print(json.dumps({"status":"success","output":o[:500]}))
