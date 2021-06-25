About
--------

A simple websocket relay than listen on port 9081 and 9080,
and relay any message received on 9081 to 9080.

Basically :

* Listen on port 9081
* Listen on port 9080
* When receiving a message on 9081, relay to 9080.

This is just used with [RemoteLogix](https://github.com/vr-voyage/remote-logix),
in order to get Websocket support in the HTML version.

This is not an essential part of **RemoteLogix**. You can EASILY replace
this with a few lines of code of any programming language you know,
that supports Websocket servers.  
It's just provided for testing convenience.

There's no real support for changing the port numbers inside the app,
you'll have to use Godot and edit the Websocket scenes objects properties
for that.  I'll add basic configuration support ASAP.  

Limitations
---------------

* No configuration or start/stop buttons.  
  This is just a quick test utility, at the moment.
  Configuration will be added shortly.

  
