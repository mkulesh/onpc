We already know that following Pioneer models are not supported: VSX-529, VSX-830, VSX-924, VSX-1021, VSX-1121, SC-95, N-50, N-50a, N-70A

Pioneer has two different versions of the network protocol used for the communication between 
the receiver and remote app:
- "External Command for CI": The first version that is a plain text protocol that was uses for older 
Pioneer models before 2016. These models usually accept commands on both RS232C and IP:
https://github.com/mkulesh/onpc/blob/master/doc/Pioneer/Pioneer_AVR_FY16_CIAMX.xlsx
More documentation can be found [www.pioneerelectronics.com](https://www.pioneerelectronics.com/PUSA/Support/Home-Entertainment-Custom-Install/RS-232+&+IP+Codes/A+V+Receivers)
- "Integrated Serial Communication Protocol": The second version is a XML-based protocol (ISCP) 
developed by Onkyo and used in the modern Pioneer devices after 2016: 
https://github.com/mkulesh/onpc/blob/master/doc/Pioneer/Pioneer_AVR_104.xlsx
The first sheet contains the list of supported models, it seems to be Pioneer started the support
of Onkyo ISCP protocol in 2016 with models VSX-831 and VSX-LX101.

The difference between the message format and commands for these two protocols is huge. 
The app supports currently Onkyo ISCP protocol only for two reasons:
- Actual documentation about Pioneer receivers is not available
- I have no older Pioneer model available for testing

However, the app is open source and distributed under GPLv3 license. It is completely legal 
to fork the app and expand communication protocol by Pioneer commands.
I can support such a development.