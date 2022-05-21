import requests

def get_ip():
    
    response = requests.get('https://api.ipify.org')
    
    if not response.ok:
        print(response.reason)
        print(response.text)
        print(response.content)
        return False
    
    ip = response.content.decode('utf8')
        
    print(f"Obtido o IP: '{ip}'")
    return ip
    
if __name__ == '__main__':
    ip = get_ip()