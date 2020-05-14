# myCenter Module

If you're here I assume you want to help make myCenter better. From here you can open pull-requests, or issues with the actual module.

# Guide to setup

First, download the MainModule, and drag it into Roblox Studio.
Second, put it in ServerScriptStorage, at this point I'm assuming you already have your centers require that looks like this
```
require(123456787)("mcv5_loader_id:"ffhdsyf8f87dsf87yds78yffs8fsd87fsd78);
```
We're going to want to change the numbers to
```
require(script.Parent.NameOfModule)(theotherrandomthing);
```
From here you should be able to make changes to the module, and it show up in your game.
