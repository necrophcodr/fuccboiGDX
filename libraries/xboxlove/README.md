xboxlove
========

Update of Love2d xboxlove library to 0.9.

[Orignal Thread here ](http://love2d.org/forums/viewtopic.php?f=5&t=39984)

####Basic Use Changes

   - Constructor : xboxlove.create(joystick) joystick is an joystick object from love.joystick.getJoysticks()

####Updates

   - Compatiable with Love2d 0.9 new Joystick functionality.

   - New connected member to check if controller is connected.

   - When controller disconnects the library wont crash instead the 
values returned will be 0 or fals

##### Tested on Windows 7 and Mac OSX 10.9.1

#### Future Updates

   - Test and Implement PS3 Profile Controller support 

#### What someone else can do

   - Make the binding controllers to xbox 360 format super simple and easy using this library. 
