#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup
import json
import sys

URL = "http://45.11.57.129"

def scrape_drama_list():
    headers = {'User-Agent': 'Mozilla/5.0'}
    
    print("Fetching homepage...")
    resp = requests.get(URL, headers=headers)
    soup = BeautifulSoup(resp.text, 'html.parser')
    
    data = {
        "ongoing": [],
        "completed": [],
        "movies": [],
        "variety": []
    }
    
    # Ongoing dramas
    ongoing_section = soup.find('h3', string='Sedang Tayang')
    if ongoing_section:
        for item in ongoing_section.find_next('ul').find_all('li')[:20]:
            link = item.find('a')
            if link:
                title = link.get_text(strip=True).split(' Episode')[0]
                ep_info = link.get_text(strip=True)
                data["ongoing"].append({
                    "title": title,
                    "info": ep_info,
                    "link": URL + link.get('href')
                })
    
    # Completed dramas
    completed_section = soup.find('h3', string='Completed')
    if completed_section:
        for item in completed_section.find_all('a', href=True)[:15]:
            title = item.get_text(strip=True)
            if 'Episode' in title or 'Movie' in title:
                data["completed"].append({
                    "title": title,
                    "link": URL + item.get('href')
                })
    
    # Movies
    for movie in soup.find_all('a', href=lambda x: x and '/movie/' in x if x else False)[:10]:
        data["movies"].append({
            "title": movie.get_text(strip=True),
            "link": URL + movie.get('href')
        })
    
    return data

def save_to_file():
    data = scrape_drama_list()
    
    with open('/root/.nullclaw/workspace/data/oppadrama_list.json', 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"\nSaved {len(data['ongoing'])} ongoing, {len(data['completed'])} completed, {len(data['movies'])} movies")
    print("File: /root/.nullclaw/workspace/data/oppadrama_list.json")

if __name__ == "__main__":
    save_to_file()
