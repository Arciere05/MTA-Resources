# VendingMachineMTA
I developed a Multi Theft Auto resource named "Vending Machine" some time ago, and I'm excited to share it with the community.

![image](https://github.com/Arciere05/VendingMachineMTA/assets/57197999/5e87e64b-fb12-4475-8c94-66721553016a)


* This made for role-playing game mode

This is an advanced vending machine resource allows you to create machines all around san andreas, once a machine been created you can simply stand in front of the machine and a list of drinks will show up, select which beverage you want to drink and purchase it.

How to create a vending machine :

- Get the coordinate you wish to place the vending machine
(exemple): x="0", y="0", z="2" --middle of the map
- Open vendingMachine.xml and add this line of code

Syntax
<object object= int modelId, x= float x, y= float y, z= float z, rx= float rx, ry= float ry, rz = float rz, markerZ= float mz, bool markerVisible= true/>

Required Arguments
* object: A whole integer specifying the GTA:SA object model ID.
* x: A floating point number representing the X coordinate on the map.
* y: A floating point number representing the Y coordinate on the map.
* z: A floating point number representing the Z coordinate on the map.
* rx: A floating point number representing the rotation about the X axis in degrees.
* ry: A floating point number representing the rotation about the Y axis in degrees.
* rz: A floating point number representing the rotation about the Z axis in degrees.
* markerZ: A floating point number representing the Z coordinate on the map.
* markerVisible: This defines if marker will be visible or not.

You can also adjust items in client.lua

* You can change item name, price, hp
* you can add items
* you can remove items

Key binds

* up/down arrows to select items/drinks.
* Enter to purchase item.
* Backspace to close window.

Note: You need to have DGS resource installed if you wish to run this resource.

Enjoy!

Example Video :
https://youtu.be/kfBh-hf21Zc

https://community.multitheftauto.com/index.php?p=resources&s=details&id=18802
