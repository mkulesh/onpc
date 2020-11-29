Pioneer has two different versions of the network protocol used for the communication between 
the receiver and remote app:
- The first version is a plain text protocol that was uses for older Pioneer models. These models 
usually accept commands on telnet port 23:
https://raymondjulin.com/blog/remote-control-your-pioneer-vsx-receiver-over-telnet.
Or more generally, these devices support command-set which is somewhat similar to the 
Integra commands.
http://www.pioneerelectronics.com/StaticFiles/PUSA/Files/Home%20Custom%20Install/VSX-1120-K-RS232.PDF
- The second version is a XML-based protocol (ISCP) developed by Onkyo and used in the modern 
Pioneer devices. The description of this protocol for Pioneer receivers is 
[here](https://github.com/mkulesh/onpc/blob/master/doc/Pioneer_AVR_104.xlsx).
The first sheet contains the list of supported models, it seems to be Pioneer started the support
 of Onkyo ISCP protocol in 2016 with models VSX-831 and VSX-LX101.

The difference between the message format and commands for these two protocols is huge. 
The app supports currently Onkyo ISCP protocol only for two reasons:
- Actual documentation about Pioneer receivers is not available
- I have no older Pioneer model available for testing

However, the app is open source and distributed under GPLv3 license. It is completely legal 
to fork the app and expand communication protocol by Pioneer commands.
I can support such a development.