import math

def calculate_haversine_distance(lat1, lon1, lat2, lon2):
    """
    Calculate the great circle distance between two points 
    on the earth (specified in decimal degrees)
    Returns distance in kilometers.
    """
    # Convert decimal degrees to radians 
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula 
    dlon = lon2 - lon1 
    dlat = lat2 - lat1 
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a)) 
    
    # Earth radius in km
    r = 6371 
    return c * r

def get_bounding_box(lat, lon, radius_km):
    """
    Returns a bounding box (min_lat, max_lat, min_lon, max_lon)
    to pre-filter database queries quickly.
    1 degree of latitude is ~111.32 km.
    1 degree of longitude is ~111.32 * cos(latitude) km.
    """
    lat_delta = radius_km / 111.32
    lon_delta = radius_km / (111.32 * math.cos(math.radians(lat)))
    
    return (
        lat - lat_delta, 
        lat + lat_delta, 
        lon - lon_delta, 
        lon + lon_delta
    )
