import requests
import json
import os

# Overpass API endpoint
OVERPASS_URL = "http://overpass-api.de/api/interpreter"

# Bounding box for Continental Africa approx: (bottom-lat, left-lng, top-lat, right-lng)
# Note: Fetching the entire continent at once may timeout public Overpass instances. 
# It is recommended to run this in regional chunks or use a dedicated planet.osm extract.
AFRICA_BBOX = "-34.8, -17.5, 37.3, 51.2"

query = f"""
[out:json][timeout:900];
(
  node["amenity"="hospital"]({AFRICA_BBOX});
  way["amenity"="hospital"]({AFRICA_BBOX});
  relation["amenity"="hospital"]({AFRICA_BBOX});
);
out center;
"""

def fetch_africa_hospitals():
    print("Requesting Continental Africa Hospital data from OpenStreetMap Overpass API...")
    print("Warning: This may take a long time or timeout depending on the Overpass server load.")
    
    response = requests.post(OVERPASS_URL, data={'data': query})
    
    if response.status_code == 200:
        data = response.json()
        
        # Convert to GeoJSON format identical to the Flutter app's expectations
        features = []
        for element in data.get('elements', []):
            lat = element.get('lat') or element.get('center', {}).get('lat')
            lon = element.get('lon') or element.get('center', {}).get('lon')
            tags = element.get('tags', {})
            
            if lat and lon:
                feature = {
                    "type": "Feature",
                    "geometry": {
                        "type": "Point",
                        "coordinates": [lon, lat]
                    },
                    "properties": {
                        "id": element.get('id'),
                        "name": tags.get('name', 'Hospital'),
                        "amenity": "hospital",
                        "address": tags.get('addr:street', 'Address unavailable'),
                        "phone": tags.get('phone', 'Not provided'),
                        "opening_hours": tags.get('opening_hours', '24/7')
                    }
                }
                features.append(feature)
        
        geojson = {
            "type": "FeatureCollection",
            "features": features
        }
        
        output_path = "/home/light667/Dev/PulseAI/assets/data/hospitals_africa.geojson"
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(geojson, f, indent=2, ensure_ascii=False)
            
        print(f"Successfully generated GeoJSON with {len(features)} hospitals across Africa!")
        print(f"Saved to: {output_path}")
    else:
        print(f"Failed to fetch data: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    fetch_africa_hospitals()
