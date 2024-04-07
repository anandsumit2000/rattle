import ssl
import socket
import datetime

def check_ssl_expiry(domain, port):
    try: 
        context = ssl.create_default_context()
        with socket.create_connection((domain,port)) as sock:
            with context.wrap_socket(sock, server_hostname=domain) as connection:
                certificate = connection.getpeercert()
                expiry_date = datetime.datetime.strptime(certificate['notAfter'], '%b %d %H:%M:%S %Y %Z')
                days_until_expiry = (expiry_date - datetime.datetime.now()).days
                return days_until_expiry
            
    except Exception as e:
        print(f"Error checking for SSL certificate expiry for {domain}:{port}. \n Reason: {e}")
        

def main():
    list_of_addresses = ["www.google.com:443", "www.facebook.com:22", "www.x.com:443"]
    for addresses in list_of_addresses:
        domain, port = map(lambda x: int(x) if x.isdigit() else x, addresses.split(":"))
        days = (check_ssl_expiry(domain, port))
        print(days)

if __name__ == "__main__":
    main()