#!/usr/bin/env python3
"""
Universal Web Scraper - Lightweight & Powerful
Usage: scrape.py <URL> <task> [selector]

Tasks:
  links    - Extract all links from page
  images   - Extract all image URLs
  text     - Clean text content (no ads)
  titles   - Extract all headings (h1-h6)
  table    - Extract tables to CSV
  meta     - Extract meta tags (title, desc, keywords)
  custom   - Custom CSS selector
  
Examples:
  scrape.py https://example.com links
  scrape.py https://example.com text
  scrape.py https://example.com custom .article
"""

import sys
import requests
from bs4 import BeautifulSoup
import re
import json
import csv
from io import StringIO
import argparse

def clean_text(text):
    """Remove extra whitespace and clean text"""
    if not text:
        return ""
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def fetch_page(url):
    """Fetch URL with browser-like headers"""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
    }
    try:
        response = requests.get(url, headers=headers, timeout=15)
        response.raise_for_status()
        return response.text
    except Exception as e:
        return f"ERROR: {str(e)}"

def extract_links(html, base_url=None):
    """Extract all links from page"""
    soup = BeautifulSoup(html, 'html.parser')
    links = []
    for a in soup.find_all('a', href=True):
        href = a['href']
        if base_url and not href.startswith('http'):
            href = base_url + href if href.startswith('/') else base_url + '/' + href
        links.append(href)
    return list(set(links))

def extract_images(html):
    """Extract all image URLs"""
    soup = BeautifulSoup(html, 'html.parser')
    images = []
    for img in soup.find_all('img', src=True):
        images.append(img['src'])
    return images

def extract_text(html):
    """Extract clean text content"""
    soup = BeautifulSoup(html, 'html.parser')
    
    # Remove script, style, nav, footer, ads
    for tag in soup(['script', 'style', 'nav', 'footer', 'header', 'aside', 
                     'noscript', 'iframe', 'form', 'button']):
        tag.decompose()
    
    # Also remove common ad-related classes
    for tag in soup.find_all(class_=re.compile(r'ad-|ads-|advert|sidebar|social|share', re.I)):
        tag.decompose()
    
    text = soup.get_text(separator='\n', strip=True)
    # Clean extra blank lines
    lines = [clean_text(line) for line in text.split('\n')]
    lines = [line for line in lines if line and len(line) > 2]
    return '\n'.join(lines[:200])  # Limit to 200 lines

def extract_titles(html):
    """Extract all headings"""
    soup = BeautifulSoup(html, 'html.parser')
    titles = []
    for i in range(1, 7):
        for tag in soup.find_all(f'h{i}'):
            text = clean_text(tag.get_text())
            if text:
                titles.append(f"H{i}: {text}")
    return titles

def extract_table(html):
    """Extract tables to CSV format"""
    soup = BeautifulSoup(html, 'html.parser')
    tables = soup.find_all('table')
    if not tables:
        return "No tables found"
    
    output = []
    for i, table in enumerate(tables[:3]):  # Max 3 tables
        rows = table.find_all('tr')
        if rows:
            output.append(f"=== Table {i+1} ===")
            for row in rows[:20]:  # Max 20 rows per table
                cells = row.find_all(['td', 'th'])
                row_data = [clean_text(cell.get_text()) for cell in cells]
                output.append(' | '.join(row_data))
    return '\n'.join(output)

def extract_meta(html):
    """Extract meta tags"""
    soup = BeautifulSoup(html, 'html.parser')
    result = []
    
    # Title
    title = soup.find('title')
    if title:
        result.append(f"Title: {clean_text(title.get_text())}")
    
    # Meta tags
    for meta in soup.find_all('meta'):
        name = meta.get('name') or meta.get('property', '')
        content = meta.get('content', '')
        if name and content:
            result.append(f"{name}: {content[:200]}")
    
    return '\n'.join(result[:20])

def custom_selector(html, selector):
    """Extract using custom CSS selector"""
    soup = BeautifulSoup(html, 'html.parser')
    elements = soup.select(selector)
    result = []
    for elem in elements[:50]:
        text = clean_text(elem.get_text())
        if text:
            result.append(text)
    return '\n'.join(result)

def main():
    if len(sys.argv) < 3:
        print("Usage: scrape.py <URL> <task> [selector]")
        print("Tasks: links, images, text, titles, table, meta, custom")
        sys.exit(1)
    
    url = sys.argv[1]
    task = sys.argv[2].lower()
    selector = sys.argv[3] if len(sys.argv) > 3 else None
    
    html = fetch_page(url)
    
    if html.startswith("ERROR:"):
        print(html)
        sys.exit(1)
    
    if task == "links":
        result = extract_links(html, url)
        print('\n'.join(result) if result else "No links found")
    elif task == "images":
        result = extract_images(html)
        print('\n'.join(result) if result else "No images found")
    elif task == "text":
        print(extract_text(html))
    elif task == "titles":
        result = extract_titles(html)
        print('\n'.join(result) if result else "No titles found")
    elif task == "table":
        print(extract_table(html))
    elif task == "meta":
        print(extract_meta(html))
    elif task == "custom":
        if not selector:
            print("Error: selector required for custom task")
            sys.exit(1)
        print(custom_selector(html, selector))
    else:
        print(f"Unknown task: {task}")
        print("Tasks: links, images, text, titles, table, meta, custom")

if __name__ == "__main__":
    main()
