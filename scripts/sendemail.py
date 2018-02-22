import smtplib
import json
import os

USERNAME = os.environ['EMAIL_USERNAME']
PASSWORD = os.environ['EMAIL_PASSWORD']
DIR = os.environ['SEND_EMAIL_DIR']

def sendemail(admins, user):
    FROM = 'support@hcc.unl.edu'
    TO = admins
    SUBJECT = 'New GloDET user registered'
    TEXT = user

    # Prepare actual message
    message = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (FROM, ", ".join(TO), SUBJECT, TEXT)
    try:
        server = smtplib.SMTP("hcc.unl.edu", 25)
        server.ehlo()
        server.starttls()
        server.login(USERNAME, PASSWORD)
        server.sendmail(FROM, TO, message)
        server.close()
        print('successfully sent the mail')
    except:
        print('failed to send mail')

with open(DIR + '/emailinput.txt') as f:
    content = f.readlines()

if len(content) == 2:
    admins = json.loads(content[0])
    user = content[1]
    sendemail(admins, user)
else:
    print("wrong content")
    print(content)