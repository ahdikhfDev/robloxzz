#!/usr/bin/env python3
"""
Adaptive Web Scraper - Powered by Scrapling
Usage: scrape-adaptive.py <URL> [selector]

This scraper adapts to website changes automatically!
"""

import sys
import json
import re

def clean_text(text):
    if not text:
        return ""
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def main():
    if len(sys.argv) < 2:
        print("Usage: scrape-adaptive.py <URL> [selector]")
        print("Example: scrape-adaptive.py https://example.com")
        print("        scrape-adaptive.py https://example.com .article")
        sys.exit(1)
    
    url = sys.argv[1]
    selector = sys.argv[2] if len(sys.argv) > 2 else None
    
    try:
        from scrapling.fetchers import Fetcher
        
        print(f"[*] Fetching: {url}")
        page = Fetcher.get(url)
        
        if selector:
            print(f"[*] Extracting: {selector}")
            elements = page.css(selector)
            results = []
            for elem in elements[:30]:
                text = clean_text(elem.get_text())
                if text:
                    results.append(text)
            print('\n'.join(results) if results else "No content found")
        else:
            # Extract main content
            print("[*] Extracting all content...")
            
            # Try common patterns
            patterns = ['article', 'main', '.content', '.post', 'h1', 'h2', 'p']
            all_content = []
            
            for pattern in patterns:
                elements = page.css(pattern)
                if elements:
                    for elem in elements[:10]:
                        text = clean_text(elem.get_text())
                        if text and len(text) > 20:
                            all_content.append(text)
            
            # Also get all links and images
            links = page.css('a::attr(href)').getall()[:20]
            images = page.css('img::attr(src)').getall()[:10]
            
            # Print results
            print("\n" + "="*50)
            print("CONTENT:")
            print("="*50)
            for content in all_content[:20]:
                print(f"- {content[:200]}...")
            
            print("\n" + "="*50)
            print(f"LINKS ({len(links)} found):")
            print("="*50)
            for link in links[:15]:
                print(link)
            
            print("\n" + "="*50)
            print(f"IMAGES ({len(images)} found):")
            print("="*50)
            for img in images[:10]:
                print(img)
                
    except ImportError:
        print("Error: scrapling not installed. Run: pip install scrapling")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
