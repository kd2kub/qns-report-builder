# qns-report-builder
This script creates a National Traffic System QNS Report to send to Net Managers. 

## "How do I use this script?"
First, this script is BASH Shell based and works only on Linux systems. It may work on ming?

Second,  Here is how it works:
1. Prepare to be net control for your designated evening.
2. Open up your desired text editor (mine is vim) and save off a copy of the template file. This is provided in the qns.sh script and also in this repo.
3. Listing traffic is easy. Repeater frequencies are 6 characters plus the decimal.  That is used to note which repeaters traffic is being checked in and logged. there is an unlimited number of entries for frequencies someone can use.
4. As checkins accumulate, their decorators (/n/d) are first tab delimited from their callsign.  Any traffic they are holding gets tab delimited and then if they pass that traffic then that is also tab delimited.
5. When net checkins are over, simply run qns.sh with your file argument.
6. A working folder is created with all files.

[![asciicast](https://asciinema.org/a/AGr46mfcAflAIqhx.svg)](https://asciinema.org/a/AGr46mfcAflAIqhx)

## Installation
Simply clone this repository in your choice of directory. 

## Issues, Irritations, Aggrvations?
Feel free to enter an issue. 
