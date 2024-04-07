import os
import ssl
import boto3
import socket
import datetime
from email.mime.text import MIMEText

def check_ssl_expiry(domain, port, recipient_emails):
    try: 
        context = ssl.create_default_context()
        with socket.create_connection((domain,port)) as sock:
            with context.wrap_socket(sock, server_hostname=domain) as connection:
                certificate = connection.getpeercert()
                expiry_date = datetime.datetime.strptime(certificate['notAfter'], '%b %d %H:%M:%S %Y %Z')
                days_until_expiry = (expiry_date - datetime.datetime.now()).days
                if days_until_expiry < 15:
                    send_email_alert(days_until_expiry, recipient_emails, domain, port)
            
    except Exception as e:
        print(f"Error checking for SSL certificate expiry for {domain}:{port}.\nReason: {e}")
        
def send_email_alert(days_until_expiry, recipient_mails, domain, port):
    ses_client = boto3.client("ses", region_name="us-east-1")                           # AWS Access and Secret keys passed through environment variables
    CHARSET = "UTF-8"
    subject = f"SSL Certificate Expiry Alert for {domain}"
    if days_until_expiry == 0:
        body = f"SSL certificate for {domain}:{port} expired."
    elif days_until_expiry == 1:
        body = f"SSL certificate for {domain}:{port} expiring in {days_until_expiry} day."
    else:
        body = f"SSL certificate for {domain}:{port} expiring in {days_until_expiry} days."

    try:
        mail = ses_client.send_email(
            Destination={
                "ToAddresses": recipient_mails,
            },
            Message={
                "Body": {
                    "Text": {
                        "Charset": CHARSET,
                        "Data": body,
                    }
                },
                "Subject": {
                    "Charset": CHARSET,
                    "Data": subject
                },
            },
            Source="sender@company.com"
        )
    except Exception as e:
        print(f"Error Sending Mail.\nReason: {e}")    

def main():
    list_of_addresses = ["www.google.com:443", "www.facebook.com:443", "www.x.com:443"]
    for addresses in list_of_addresses:
        domain, port = map(lambda x: int(x) if x.isdigit() else x, addresses.split(":"))
        recipient_mails = ["reciever@company.com"]
        check_ssl_expiry(domain, port, recipient_mails)

if __name__ == "__main__":
    main()