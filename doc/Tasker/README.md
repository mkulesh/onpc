# Tasker integration

The app can be integrated with Tsaker using [intents] (https://tasker.joaoapps.com/userguide/en/intents.html). 
Intents are Android's main method for allowing apps to communicate with each other and share data. 
Intents are for advanced users.

On the Tasker side, it is possible to write a script that contains a sequence of 
[ISCP commands](https://github.com/mkulesh/onpc/blob/master/doc/ISCP_AVR_140.xlsx). 
The Tasker is able to parametrize this script and sent it to the app. The app reads this script 
and performs the commands from it.

The script on the Tasker side is an XML message that looks like:

```xml
<?xml version="1.0" encoding="utf-8"?>
<onpcScript host="10.49.0.7" port="60128" zone="0" tab="MEDIA">
  <send cmd="NA" par="NA" wait="NRI"/>
  <send cmd="PWR" par="QSTN" wait="PWR"/>
  <send cmd="PWR" par="01" wait="PWR" resp="01"/>
  <send cmd="SLI" par="QSTN" wait="SLI"/>
  <send cmd="SLI" par="2B" wait="SLI" resp="2B"/>
  <send cmd="NLT" par="QSTN" wait="NLT"/>
  <send cmd="NTC" par="TOP" wait="NLS" listitem="Music Server (DLNA)"/>
  <send cmd="NSV" par="000" wait="NLA" listitem="Our NAS (j1n)"/>
  <send cmd="NLA" par="Our NAS (j1n)" wait="NLA" listitem="Search"/>
  <send cmd="NLA" par="Search" wait="NLA" listitem="Search by Artist"/>
  <send cmd="NLA" par="Search by Artist" wait="NCP"/>
</onpcScript>
```

This script has following parameters
- _host and port_ (optional): IP and port of the target receiver
- _zone_ (optional): target zone if the receiver has multi-zone support
- _tab_ (optional): the tab in the app that will be set when script is started
- _send_: the description of the action

Action contains the description of the ISCP commands (with parameters) that shall be send to 
the receiver and the rule that defines when command is finished and the app shall go to the 
next command:
- _cmd_: the mandatory code of the ISCP command. For available codes please see official Onkyo 
description of the [ISCP protocol](https://github.com/mkulesh/onpc/blob/master/doc/ISCP_AVR_140.xlsx)
- _par_: the mandatory command parameter
- _wait_: mandatory flag that describes the waiting condition. May be a positive integer 
(waiting duration is milliseconds), or a code of ISCP command that will be expected as a response
from the receiver
- _resp_: optional response parameter. If not given, the app just waits on the response message
given as _wait_ parameter with any response value. If _resp_ is given the app waits on the
response message with exactly this response value.
- _listitem_: a name od the media item. The command will be finalized, when the receiver provides
a media list that contains this media item.
