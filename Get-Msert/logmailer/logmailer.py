#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
A simple web app for emailing logs from Get-Mmsert.ps1

Copyright 2016 Sean Whalen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

from flask import Flask, request
from werkzeug.utils import secure_filename
from flask_mail import Mail, Message

app = Flask(__name__)
app.config.from_object("config")
mail = Mail(app)


@app.route('/msert', methods=["POST"])
def msert_log():
    if request.method == 'POST':
        log = request.files[list(request.files.keys())[0]]
        filename = secure_filename(log.filename)
        computer_name = filename.split("_")[1].split(".")[-2]
        subject = "Microsoft Safety Scanner log from {0}".format(computer_name)
        body = "Please see the attached {0}.".format(subject)

        msg = Message(sender=app.config['MAIL_FROM'],
                      recipients=app.config['MAIL_RECIPIENTS'],
                      subject=subject,
                      body=body)

        msg.attach(filename=log.filename, content_type="text/plain",
                   data=log.read())

        mail.send(msg)

        return ""

if __name__ == '__main__':
    app.run(host="0.0.0.0")
