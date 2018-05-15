import smtplib
import json
import os

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


USERNAME = os.environ['EMAIL_USERNAME']
PASSWORD = os.environ['EMAIL_PASSWORD']
DIR = os.environ['SEND_EMAIL_DIR']

def sendemail(recipients, subject, text, html=''):
    me = 'support@hcc.unl.edu'

    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = me
    msg['To'] = ", ".join(recipients)

    part1 = MIMEText(text, 'plain')
    msg.attach(part1)

    if len(html):
        part2 = MIMEText(html, 'html')
        msg.attach(part2)

    try:
        server = smtplib.SMTP("hcc.unl.edu", 25)
        server.ehlo()
        server.starttls()
        server.login(USERNAME, PASSWORD)
        server.sendmail(me, recipients, msg.as_string())
        server.close()
        print('successfully sent the mail')
    except:
        print('failed to send mail')


def main():
    with open(DIR + '/emailinput.txt') as f:
        content = f.readlines()

    if len(content) >= 3:
        recipients = json.loads(content[0].strip())
        subject = json.loads(content[1].strip())
        text = json.loads(content[2].strip())
        html = ''
        if len(content) > 3:
            html = json.loads(content[3].strip())
        sendemail(recipients, subject, text, html)
    else:
        print("wrong content")
        print(content)

if __name__ == "__main__":
     main()
