import smtplib
import json
import os


USERNAME = os.environ['EMAIL_USERNAME']
PASSWORD = os.environ['EMAIL_PASSWORD']
DIR = os.environ['SEND_EMAIL_DIR']

def sendemail(recipients, subject, text):
    me = 'support@hcc.unl.edu'

    # Prepare actual message
    message = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (me, ", ".join(recipients), subject, text)
    try:
        server = smtplib.SMTP("hcc.unl.edu", 25)
        server.ehlo()
        server.starttls()
        server.login(USERNAME, PASSWORD)
        server.sendmail(me, recipients, message)
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
        sendemail(recipients, subject, text)
    else:
        print("wrong content")
        print(content)

if __name__ == "__main__":
     main()
