ifttt-imapfilter
================
IFTTT IMAPFilter Lua Script to Tie Various Home Automation Devices Together

About
-----

Ifttt-imapfilter is a simple self hosted method for implementing IFTTT functions without having to relinquish your credentials to a company with unknown origin or intentions.   

I have a home automation and home security system, but I also have a few cloud connected devices which do not support one of the well accepted HA protocols or do not have a public API, but those devices do have basic email, SMS, or mobile push notification capability.  In search for a way to tie these standalone devices together with my existing systems, it seemed the least common denominator was email capability.  Obviously, this means notifications and actions will not be real time and are not appropriate for property protection or personal safety applications.  

Disclaimer
----------

Ifttt-imapfilter example Lua script is just that. No more, no less.  It is not a long term development project.  I specifically did not use any non-standard libraries (XML parsers, table manipulation, etc.) to keep it as lightweight as possible.   Also, unlike other interpreted script languages (Ruby, Perl, Python, etc), Lua does not have very good package management system.  Often one must pull packages from multiple sources, or compile from source.  

IMAPFilter
----------

The great thing about IMAP mail servers is you can perform remote searches on email without actually syncing the mail content.  This means IMAP searches are lightweight, do not require much CPU resources, and essentially zero additional disk space.   You can move emails between folders, mark as read, or delete altogether.  This is where [IMAPFilter](https://github.com/lefcha/imapfilter) excels. You can install from source or you can simply install using any Linux distribution package installation.  

Install IMAPFilter
------------------

* `sudo apt-get install iampfilter`
* Follow the initial setup guide [here](https://raymii.org/s/blog/Filtering_IMAP_mail_with_imapfilter.html)

IMAPFilter as daemon
--------------------
* Use the [example](https://github.com/lefcha/imapfilter/blob/master/samples/extend.lua) provided by the developer

IMAPFilter as crontab
---------------------
This is the method I use since it will automatically restart on reboot, is very easy to change the frequency it runs, etc.

* `crontab -e`
* Add entry in crontab file which suits your needs.  See included example.

Home Automation System
----------------------

My primary home automation system is comprised of several components:

1. [Universal Devices](https://www.universal-devices.com)  ISY-994i Insteon/Zigbee/Zwave embedded lighting controller
2. [Elk Products](www.elkproducts.com) Elk-M1 Gold security alarm panel

The components which are not directly connected into a home automation system are:

1. Several [Trendnet](https://www.trendnet.com/) IP cameras
2. [ZoneMinder](http://www.zoneminder.com)  video camera and surveillance server.
2. [Liberty Safelert](http://www.libertysafe.com/accessory-safelert-monitoring-system-ps-17-pg-85.html) monition, door, humidity monitoring device
3. [Kidde Remotelync](https://remotelync.kidde.com) smoke and CO alarm monitoring device
4. [Rheem EcoNet WiFi Water Heater Module](http://www.rheem.com/EcoNet/wificenter) 

Universal Devices ISY-994i and Elk Products Elk M1 Gold
-------------------------------------------------------

The Universal Devices ISY-99i series of home automation controllers have a REST API which can be used for monitoring and control of your home automation system, including the Elk M1 Gold security panel if you purchase the Universal Devices add-on module for two way communication.  

The [ISY Developers Manual and Elk Integration Manual](http://www.universal-devices.com/developers/wsdk/) documents the REST API for the ISY-99i series of controllers.

Here are some simple [BASH scripts] (https://gist.github.com/4052516) you use to experiment with ISY-99i REST API.    

There also is a very active user and developer [support forum.](http://forum.universal-devices.com)

TrendNet IP Cameras
-------------------

[Trendnet](https://www.trendnet.com/) makes some reasonably priced wired and wireless IP cameras.  Since I can't run a dedicated PoE Ethernet cable to each camera location, I use some of their wireless IP cameras.   

ZoneMinder
----------

[ZoneMinder](http://www.zoneminder.com) is an open source project aimed at DIY video camera and surveillance.  You can use analog (with an acquisition card), web, or IP cameras to record video 24/7 or only when motion is detected in the FOV.  ZM does have plans to add an API to make it easier to integrate with home automation systems, but it currently is a WIP.  Some have been successful getting the API source files installed and configured, even then there are limitation with the API in it's current form.  For example, you can change the camera recording mode from Monitor (no recording) to Modect (record on motion), but you still have to restart the server for the mode change to take effect.  In the absence of a reliable and working API, you can interact with the built in web pages or emulate the web interaction using cURL commands.  

Liberty Safelert Safe Monitoring
--------------------------------
[Liberty](www.libertysafe.com) makes some great Made in the USA safes, and also has a separate Safelert device to monitor motion, door opening, humidity, temperature, etc.  There is a dedicated mobile app which you can set up push notification, email, and SMS text message alerts. 

Kidde RemoteLync
----------------
[Kidde Remotelync](https://remotelync.kidde.com) device plugs into an electrical outlet centrally location within your home.  The device monitors the unique frequencies emitted by your smoke and CO alarms.   Unlike other manufacturers remote smoke/CO alarm devices which use proprietary technology, the Kidde RemoteLync works with any smoke alarm manufactured after 1970.  Kidde also has a dedicated mobile app for push, email, and SMS notifications.   

Rheem EcoNet Wifi Module
------------------------
[Rheem EcoNet Module](http://www.rheem.com/EcoNet/wificenter) once again has no public API, but does have a dedicated app, push, email, and SMS notifications.  






 