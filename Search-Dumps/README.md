Search-Dump.ps1
===============

A simple script for searching through a dump of data, such as compromised
credentials. It has been tested to work with GNU/Linux, MacOS, and Cygwin Bash.
For a Bash version of this script, see
[search-dump.sh](https://github.com/seanthegeek/toolbox/blob/master/search-dump/search-dump.sh).

Assumptions
-----------

- The data that you want to find is in text format
- The names of the files to be searched end in `.txt` or `.TXT`

Usage
-----

1. Create a list of domains or other terms that you would like to search for,
one term per line. Save the list as `mydomains.csv`
2. Place `mydomains.csv` in the same directory as the files that you wish to
search
3. `cd` to the directory
4. Run `Search-Dump.ps1`

Like any other command, you can redirect the output to a file:

    Search-Dump.ps1 > output.csv

Parameters
----------

**InputFiles** (String, Optional)

A filename or wildcard matching the file(s) to search. `*.txt` by default.

**SearchList** (String, Optional)

The path to a file containing a list of strings to search for, such as domain
names, one per line. `mydomains.csv` by default.
