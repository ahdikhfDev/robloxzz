#!/usr/bin/env python3
"""
Ultra Lightweight Web Scraper
Ringan, cepat, works di STB!
"""

import sys
import requests
from bs4 import BeautifulSoup
import re

requests.packages.urllib3.disable_warnings()

def clean(text):
    if not text:
        return ""
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def scrape(url, mode='all'):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,*/*',
    }
    
    try:
        resp = requests.get(url, headers=headers, timeout=15, verify=False)
        soup = BeautifulSoup(resp.text, 'html.parser')
        
        # Remove script, style, nav
        for tag in soup(['script', 'style', 'nav', 'footer', 'header', 'aside']):
            tag.decompose()
        
        if mode == 'links':
            links = [a.get('href', '') for a in soup.find_all('a') if a.get('href')]
            return '\n'.join(links[:50])
        
        elif mode == 'images':
            imgs = [img.get('src', '') for img in soup.find_all('img') if img.get('src')]
            return '\n'.join(imgs[:30])
        
        elif mode == 'text':
            text = soup.get_text(separator='\n', strip=True)
            lines = [clean(l) for l in text.split('\n') if len(clean(l)) > 10]
            return '\n'.join(lines[:80])
        
        else:  # all
            content = []
            for tag in ['h1', 'h2', 'h3', 'article', 'main', 'p']:
                for elem in soup.find_all(tag)[:5]:
                    t = clean(elem.get_text())
                    if t and len(t) > 20:
                        content.append(t)
            
            links = [a.get('href', '') for a in soup.find_all('a') if a.get('href')][:20]
            imgs = [img.get('src', '') for img in soup.find_all('img') if img.get('src')][:15]
            
            result = []
            result.append("="*50)
            result.append("CONTENT:")
            result.append("="*50)
            for c in content[:15]:
                result.append(f"- {c[:150]}")
            
            result.append("\n" + "="*50)
            result.append(f"LINKS ({len(links)}):")
            result.append("="*50)
            for l in links[:15]:
                result.append(l)
            
            result.append("\n" + "="*50)
            result.append(f"IMAGES ({len(imgs)}):")
            result.append("="*50)
            for i in imgs[:10]:
                result.append(i)
            
            return '\n'.join(result)
            
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ultra-scrape.py <URL> [links|images|text|all]")
        sys.exit(1)
    
    url = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) > 2 else 'all'
    
    print(f"Scraping: {url}")
    print(scrape(url, mode))
