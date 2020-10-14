# Tasker integration

The app can be opened and instructed to control receivers by sending it XML messages in
"onpcScript" format.  XML messages can be sent to the app via Android Intents.
Tasker can send these [intents](https://tasker.joaoapps.com/userguide/en/intents.html), though
Tasker can also send the XML messages via the Launch App action, which is simpler to use.

The XML messages contain [ISCP commands](https://github.com/mkulesh/onpc/blob/master/doc/ISCP_AVR_140.xlsx).
Scripts can be composed externally to Tasker, or by Taskers tasks, enabling variable user input
(including voice control with help from AutoVoice (see [below](#sample-voice-control-in-tasker))).

## Intents
The intent created in Tasker shall have following parameters:
- _Action_: android.intent.action.MAIN
- _Type_: text/xml
- _Category_: android.intent.category.LAUNCHER
- _Component_: com.mkulesh.onpc/.MainActivity
- _Data_: the script described below

From a technical point of view, the app expects the following intent from Tasker:
```
{
  act=android.intent.action.MAIN
  cat=[android.intent.category.LAUNCHER]
  dat=<message script>
  typ=text/xml
  flg=0x30800004
  cmp=com.mkulesh.onpc/.MainActivity
}
```

Alternatively, use the Launch App action in tasker as below.
In order to start the app with this intent, we can, for example, configure following tasks in Tasker:
<img src="https://github.com/mkulesh/onpc/blob/master/doc/Tasker/TaskerTasks.png" align="center">

We have here two tasks:
- The first task sends ISCP command PWR(01) in order to power on the receiver:
<img src="https://github.com/mkulesh/onpc/blob/master/doc/Tasker/TaskerPowerOn.png" align="center">
- The second task sends ISCP command PWR(00) in order to put the receiver in standby mode:
<img src="https://github.com/mkulesh/onpc/blob/master/doc/Tasker/TaskerPowerOff.png" align="center">

Both tasks declare an order of ISCP commands to be sent to the receiver in the form of a script written in XML.
The script format is described below.

## Tasker scripts

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
This script has the following parameters
- _host and port_ (optional): IP and port of the target receiver
- _zone_ (optional): target zone if the receiver has multi-zone support
- _tab_ (optional): the tab in the app that will be set when script is started
- _send_: the description of the action

The onpcScript element contains the description of the ISCP commands (with parameters) that shall be sent to
the receiver and the rule that defines when the command is finished and the next command shall be sent:
- _cmd_: the mandatory code of the ISCP command. For available codes please see official Onkyo
description of the [ISCP protocol](https://github.com/mkulesh/onpc/blob/master/doc/ISCP_AVR_140.xlsx)
- _par_: the mandatory command parameter
- _wait_: mandatory flag that describes the waiting condition.  Ideally this will be the code of an ISCP
command that will be expected as a response from the receiver; alternatively, it may be a positive integer
(waiting duration is milliseconds)
- _resp_: optional response parameter. If not given, the app just waits on the response message
given as _wait_ parameter with any response value. If _resp_ is given the app waits on the
response message with exactly this response value.
- _listitem_: the name of a media item. The command will be finalized, when the receiver provides
a media list that contains this media item.


## Examples
In this directory, we collected a set of helpful examples of scripts:
- [DeezerFlow.xml](DeezerFlow.xml): starts playing of Deezer Flow from network services
- [DlnaGenre.xml](DlnaGenre.xml): starts playing of the first song from "Blues" genre on the DLNA server. In order
to use this script, you shall change the name of your DLNA server ("Supermicro DLNA Server" in this
example), set desired genre instead of "Blues" and the title of the song instead of
"All Along The Watchtower"
- [PlayQueue.xml](PlayQueue.xml): plays the first song from Play Queue. Instead of "01 - Eclipse.mp3", set your
actual song title.
- [TuneInPreset.xml](TuneInPreset.xml): plays "Absolut relax (Easy Listening)" channel from TuneIn presets.
- [UsbStorage.xml](UsbStorage.xml): plays the song "Never Die" placed on the external USB rear storage with the path
"onkyo_music"/"Power Metall"/"Allen-Olzon"/"Worlds Apart (2020)"

# Sample Voice Control in Tasker

There's infinite ways to implement anything in software - here's one way of doing voice control of onpc, via Tasker and the associated app AutoVoice (also by Tasker's developer).

Installing AutoVoice allows you to say to your phone, "Ok Google, ask AutoVoice to X Y Z" - and the Google Assistant will send the command "X Y Z" to AutoVoice. You can then define profiles in Tasker to react to "X Y Z", eg using AutoVoice Recognized events.  Natural Language can also be used in Tasker, but requires a subscription if started via Google Assistant.

Once your command is inside Tasker, it's simply a matter of creating the required XML messages, and sending them to onpc via an intent.  You can hardcode much of the whole messages if desired - the method below tries to parametrize them somewhat, and extract the common parts.  It was written before the limit of only two parameters in a Perform Task action was removed - so those two parameters are overloaded somewhat at times by concatenating parameters with a separator character.

The general method employed is to define a tasker variable to hold the current xml script (%iscpCmd), and call tasks that append to that variable, then send it via an intent.
All tasks and profiles are included in [the onpc tasker project](OnpcVoiceControl.prj.xml) which should be able to be imported by long clicking on the picture of a house in the bottom left corner of the Tasker screen and selecting "Import Project".

Knowing which ISCP messages to send is the hardest part - tips can be gleaned from the example messages and ISCP references in the onpc repository, and from executing the app via Android Studio and enabling debugging.

## Tasker Tasks to construct and send XML messages to onpc

### ONPC [Find|Play] [By Artist|From Album|Track]
A series of very similar tasks to be targets of corresponding voice-activated profiles
- `ONPC Find By Artist`
- `ONPC Find From Album`
- `ONPC Find Track`
- `ONPC Play By Artist`
- `ONPC Play From Album`
- `ONPC Play Track`

All use [`IscpSearchPlay`](#iscpsearchplay) and send an Android Intent to onpc.

### IscpSearchPlay
Append code to %iscpCmd to connect to a DLNA server using IscpToDlna, select Search and the requested method to search with, execute the search, then play from the first track found if configured to do so.  Parameters:
- _par1_: \<search_type>:\<search_string>
- _par2_: "Play" to commence playing the first song and select the LISTEN tab, empty to open the search results and select the MEDIA tab

where
- _search_type_: is one of Artist, Album or Track
- _search_string_: is the string for the DLNA search function to look for

Uses [`IscpToDlna`](#iscptodlna) and [`IscpCmd`](#iscpcmd).

### IscpToDlna
Append code to %iscpCmd to connect to an Onkyo receiver, select NET, then a DLNA server, as specified by the variables at the top of the task:
- _ONPC_ADDRESS_: \<ip_address_of_receiver>:\<port_of_receiver>
- _DLNA_SERVER_NAME_: \<name_DLNA_server_to_connect_to>

Uses `IscpConnect` and [`IscpCmd`](#iscpcmd).

### IscpConnect
Append code to %iscpCmd to connect to an Onkyo receiver, with parameters:
- _par1_: \<ip_address_of_receiver>:\<port_of_receiver>
- _par2_: \<receiver_zone>:\<onpc_tab_to_switch_to>

See [`IscpToDlna`](#iscptodlna) for example usage.

### IscpCmd
Append code to %iscpCmd to add an ISCP command message, with parameters:
- _par1_: \<iscp_cmd_code>;\<parameter_for_cmd>
- _par2_: \<wait_parameter>;\<resp_parameter>;\<listitem>

with:
- _iscp_cmd_code_: ISCP command, eg PWR
- _parameter_for_cmd_: parameter for the command, eg ON
- _wait_parameter_: an ISCP command to wait for in response, else a number, representing a number of milliseconds to delay before sending the next command
- _resp_parameter_: something in the response message to match against
- _listitem_: an item to match against in a list of items returned by the receiver

See [`IscpToDlna`](#iscptodlna) for example usage.

### IscpCmdEscape
Individual ISCP command parameters sometimes contain XML, but they must go inside the overall XML message being sent, via Intent, to onpc.  Thus - we escape the inner message using the method in this command, with parameter:
- _par1_: xml text for which the characters '<', '>' and '"' shall be escaped (via a method agreed with onpc)

IscpCmd calls this on all input parameters, so if using that, it may not need to be manually called.

### IscpEnd
Append code to %iscpCmd to terminate the onpc XML script.  No parameters.

## Profiles to Search for, and/or Play, tracks by Artist, Album or Title
- `Find Songs By Artist`
- `Find Songs From Album`
- `Find Songs Called`
- `Play Songs By Artist`
- `Play Songs From Album`
- `Play Songs Called`

All profiles use an AutoVoice Recognized event to initiate them some minor variations on the words to invoke them, and call a corresponding task.

