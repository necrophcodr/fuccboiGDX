--[[
	Copyright © 2013 Samuel Guillaume
  Edited by Harrison Smith 2014
	This work is free. You can redistribute it and/or modify it under the
	terms of the Do What The Fuck You Want To Public License, Version 2,
	as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
--]]

local _PLATFORM = os.getenv("windir") and "win32" or "unix"
local joystickCount = love.joystick.getJoystickCount()
local joysticks = {}

xboxlove = {}
xboxlove.__index = xboxlove

function xboxlove.create(joystick)

	local new = {}
	setmetatable(new,xboxlove)
  
  -- Check if joystick is not null, a connected joystick and currently not assigned
  -- If it passes assigned joystick and create new xboxlove object.
  if not joystick then
    return nil
  else
      local connectedJoysticks = love.joystick.getJoysticks()
      if inTable(connectedJoysticks,joystick) then
        if inTable(joysticks, joystick) then
          return nil
        else
          new.joystick = joystick
          table.insert(joysticks, joystick)
        end
      else
        return nil
      end
  end
  
  new.connected = true
  
	new.Axes = {}
	new.Axes.LeftX        = 0
	new.Axes.LeftY        = 0
	new.Axes.LeftAngle    = nil 
	new.Axes.Triggers     = 0
	new.Axes.LeftTrigger  = 0
	new.Axes.RightTrigger = 0
	new.Axes.RightX       = 0
	new.Axes.RightY       = 0
	new.Axes.RightAngle   = nil
  
	new.Axes.Deadzone = {}
	new.Axes.Deadzone.LeftX        = 0
	new.Axes.Deadzone.LeftY        = 0
	new.Axes.Deadzone.LeftTrigger  = 0
	new.Axes.Deadzone.RightTrigger = 0
	new.Axes.Deadzone.Triggers     = 0
	new.Axes.Deadzone.RightX       = 0
	new.Axes.Deadzone.RightY       = 0

	new.Dpad = {}
	new.Dpad.Direction = 'c'
	new.Dpad.Centered  = true
	new.Dpad.Up 	   = false
	new.Dpad.Down 	   = false
	new.Dpad.Right 	   = false
	new.Dpad.Left 	   = false

	new.Buttons = {}
	new.Buttons.A          = false
	new.Buttons.B          = false
	new.Buttons.X          = false
	new.Buttons.Y          = false
	new.Buttons.LT         = false
	new.Buttons.RT         = false
	new.Buttons.LB         = false
	new.Buttons.RB         = false
	new.Buttons.Back       = false
	new.Buttons.Start      = false
	new.Buttons.LeftStick  = false
	new.Buttons.RightStick = false
	new.Buttons.Home       = false

	return new
end

function xboxlove:getJoystick()
	return self.joystick
end

function xboxlove:setJoystick(joystick)
	if not joystick then
    return false
  end
  self.joystick = joystick
  return true
end

function xboxlove:setDeadzone(axes,deadzone)
	deadzone = tonumber(deadzone)
	if not deadzone then return false
	elseif deadzone >= 1 or deadzone < 0 then return false end

	axes = tostring(axes):upper()
	done = false
	if axes == "ALL" then
		self.Axes.Deadzone.LeftX    = deadzone
		self.Axes.Deadzone.LeftY    = deadzone
		self.Axes.Deadzone.Triggers = deadzone
		self.Axes.Deadzone.RightX   = deadzone
		self.Axes.Deadzone.RightY   = deadzone
		done = true
	else
		if axes:find("LX") then
			self.Axes.Deadzone.LeftX        = deadzone ; done = true end
		if axes:find("LY") then    
			self.Axes.Deadzone.LeftY        = deadzone ; done = true end
		if axes:find("TRIG") then    
			self.Axes.Deadzone.Triggers     = deadzone ; done = true end
		if axes:find("TLEFT") then
			self.Axes.Deadzone.LeftTrigger  = deadzone ; done = true end
		if axes:find("TRIGHT") then
			self.Axes.Deadzone.RightTrigger = deadzone ; done = true end
		if axes:find("RX") then
			self.Axes.Deadzone.RightX       = deadzone ; done = true end
		if axes:find("RY") then    
			self.Axes.Deadzone.RightY       = deadzone ; done = true end
	end

	return done
end

function xboxlove:isDown(button)
	for k,v in pairs(self.Buttons) do
		if k:upper() == tostring(button):upper() then return v end
	end
	return false
end

function xboxlove:update(dt)
	
  if self.joystick:isConnected() then
    self.connected = true
  else
    self.connected = false
  end
  
  if _PLATFORM == "win32" then
		-- Axes :
		self.Axes.LeftX    = self.joystick:getAxis(1)
		self.Axes.LeftY    = -self.joystick:getAxis(2)
		self.Axes.RightX   = self.joystick:getAxis(3)
		self.Axes.RightY   = -self.joystick:getAxis(4)
		self.Axes.LeftTrigger  = (self.joystick:getAxis(5)+1)/2
		self.Axes.RightTrigger = (self.joystick:getAxis(6)+1)/2
		self.Axes.Triggers     = (self.joystick:getAxis(5)+1)/2 - (self.joystick:getAxis(6)+1)/2

		-- Dpad :
		self.Dpad.Up    = self.joystick:isDown(0)
		self.Dpad.Down  = self.joystick:isDown(1)
		self.Dpad.Left  = self.joystick:isDown(2)
		self.Dpad.Right = self.joystick:isDown(3)

		self.Dpad.Direction = ''
		if (not self.Dpad.Up) and (not self.Dpad.Down) and (not self.Dpad.Left) and (not self.Dpad.Right) then
			self.Dpad.Direction = 'c'
			self.Dpad.Centered = true
		else
			self.Dpad.Centered = false
			if self.Dpad.Right then
				self.Dpad.Direction = self.Dpad.Direction..'r'
			elseif self.Dpad.Left then
				self.Dpad.Direction = self.Dpad.Direction..'l'
			end

			if self.Dpad.Down then
				self.Dpad.Direction = self.Dpad.Direction..'d'
			elseif self.Dpad.Up then
				self.Dpad.Direction = self.Dpad.Direction..'u'
			end
		end
		
		-- Buttons
		self.Buttons.A          = self.joystick:isDown(10)
		self.Buttons.B          = self.joystick:isDown(11)
		self.Buttons.X          = self.joystick:isDown(12)
		self.Buttons.Y          = self.joystick:isDown(13)
		self.Buttons.LB         = self.joystick:isDown(8)
		self.Buttons.RB         = self.joystick:isDown(9)
		self.Buttons.Back       = self.joystick:isDown(5)
		self.Buttons.Start      = self.joystick:isDown(4)
		self.Buttons.LeftStick  = self.joystick:isDown(6)
		self.Buttons.RightStick = self.joystick:isDown(7)
		self.Buttons.Home       = self.joystick:isDown(14)

		self.Buttons.LT = self.Axes.Triggers == 1
		self.Buttons.RT = self.Axes.Triggers == -1

-- UNIX
	else
		-- Axes
		self.Axes.LeftX        = self.joystick:getAxis(1)
		self.Axes.LeftY        = -self.joystick:getAxis(2)
		self.Axes.RightX       = self.joystick:getAxis(4)
		self.Axes.RightY       = -self.joystick:getAxis(5)
		self.Axes.LeftTrigger  = (self.joystick:getAxis(3)+1)/2
		self.Axes.RightTrigger = (self.joystick:getAxis(6)+1)/2
		self.Axes.Triggers     = (self.joystick:getAxis(3)+1)/2 - (self.joystick:getAxis(6)+1)/2

		-- Dpad
		self.Dpad.Up    = self.joystick:isDown(11)
		self.Dpad.Down  = self.joystick:isDown(12)
		self.Dpad.Left  = self.joystick:isDown(13)
		self.Dpad.Right = self.joystick:isDown(14)

		self.Dpad.Direction = ''
		if (not self.Dpad.Up) and (not self.Dpad.Down) and (not self.Dpad.Left) and (not self.Dpad.Right) then
			self.Dpad.Direction = 'c'
			self.Dpad.Centered = true
		else
			self.Dpad.Centered = false
			if self.Dpad.Right then
				self.Dpad.Direction = self.Dpad.Direction..'r'
			elseif self.Dpad.Left then
				self.Dpad.Direction = self.Dpad.Direction..'l'
			end

			if self.Dpad.Down then
				self.Dpad.Direction = self.Dpad.Direction..'d'
			elseif self.Dpad.Up then
				self.Dpad.Direction = self.Dpad.Direction..'u'
			end
		end

		-- Buttons
		self.Buttons.A          = self.joystick:isDown(0)
		self.Buttons.B          = self.joystick:isDown(1)
		self.Buttons.X          = self.joystick:isDown(2)
		self.Buttons.Y          = self.joystick:isDown(3)
		self.Buttons.LB         = self.joystick:isDown(4)
		self.Buttons.RB         = self.joystick:isDown(5)
    self.Buttons.LeftStick  = self.joystick:isDown(6)
		self.Buttons.RightStick = self.joystick:isDown(7)
		self.Buttons.Start      = self.joystick:isDown(8)
    self.Buttons.Back       = self.joystick:isDown(9)
		self.Buttons.Home       = self.joystick:isDown(10)

		self.Buttons.LT = self.joystick:getAxis(3) == 1
		self.Buttons.RT = self.joystick:getAxis(6) == 1

	end
	   
	-- Apply Deadzones
	local z = 0
	

	if self.Axes.LeftX > 0 then z = 1 else z = -1 end
	self.Axes.LeftX = math.abs(self.Axes.LeftX) - self.Axes.Deadzone.LeftX
	if self.Axes.LeftX < 0 then self.Axes.LeftX = 0 end
	self.Axes.LeftX = self.Axes.LeftX*(1/(1 - self.Axes.Deadzone.LeftX))*z
	
	if self.Axes.LeftY > 0 then z = 1 else z = -1 end
	self.Axes.LeftY = math.abs(self.Axes.LeftY) - self.Axes.Deadzone.LeftY
	if self.Axes.LeftY < 0 then self.Axes.LeftY = 0 end
	self.Axes.LeftY = self.Axes.LeftY*(1/(1 - self.Axes.Deadzone.LeftY))*z

	if math.abs(self.Axes.Triggers) < self.Axes.Deadzone.Triggers then self.Axes.Triggers = 0 end
	
	if self.Axes.RightX > 0 then z = 1 else z = -1 end
	self.Axes.RightX = math.abs(self.Axes.RightX) - self.Axes.Deadzone.RightX
	if self.Axes.RightX < 0 then self.Axes.RightX = 0 end
	self.Axes.RightX = self.Axes.RightX*(1/(1 - self.Axes.Deadzone.RightX))*z
	
	if self.Axes.RightY > 0 then z = 1 else z = -1 end
	self.Axes.RightY = math.abs(self.Axes.RightY) - self.Axes.Deadzone.RightY
	if self.Axes.RightY < 0 then self.Axes.RightY = 0 end
	self.Axes.RightY = self.Axes.RightY*(1/(1 - self.Axes.Deadzone.RightY))*z

	if self.Axes.LeftTrigger  and math.abs(self.Axes.LeftTrigger)  < self.Axes.Deadzone.LeftTrigger  then self.Axes.LeftTrigger  = 0 end
    if self.Axes.RightTrigger and math.abs(self.Axes.RightTrigger) < self.Axes.Deadzone.RightTrigger then self.Axes.RightTrigger = 0 end
	
			-- Angles
	if self.Axes.LeftY == 0 and self.Axes.LeftX == 0 then
    	self.Axes.LeftAngle = nil
    else
    	self.Axes.LeftAngle = math.atan2(self.Axes.LeftY,self.Axes.LeftX)
    end
	if self.Axes.RightY == 0 and self.Axes.RightX == 0 then
    	self.Axes.RightAngle = nil
    else
    	self.Axes.RightAngle = math.atan2(self.Axes.RightY,self.Axes.RightX)
    end
end

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end
