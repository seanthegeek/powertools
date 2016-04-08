Get-msert.ps1
=============

Downloads and runs Microsoft Safety Scanner for silent remediation, 
then sends the logs to a web server.

`logmailer` is a Python/Flask-based web server that accepts logs from
`get-msert.ps1`, and emails them to analysts.

Setting up the web server
-------------------------

Install the dependencies
~~~~~~~~~~~~~~~~~~~~~~~~
    
    $ sudo apt-get install git python-pip
    $ git clone https://github.com/seanthegeek/powertools
    $ cd powertools/get-msert/logmailer
    $ sudo pip install -r requirements.txt
    
Edit the mail configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    $ nano config.py
    
Run the server
~~~~~~~~~~~~~~

    $ python logmailer.py &
    
Ensure that TCP port 5000 is reachable

Using the script
----------------

Edit the `$LogServer` variable to math the log server address.
 
Run `get-msert.ps1` as `Administrator`