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
