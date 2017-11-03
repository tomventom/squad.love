local Class = require("lib.Class")
local vector = require("hump.vector")
local U = require("lib.Utils")

local Slider = Class:derive("Slider")

function Slider:new(x, y, w, h, id, isVertical)
	self.pos = vector(x or 0, y or 0)
	self.w = w
	self.h = h
	self.id = id or ""

	self.isVertical = (isVertical == true) or false
	-- relative to slider pos
	self.sliderPos = 0
	self.prevSliderPos = 0
	self.sliderDelta = 0
	self.sliderSize = 10
	self.grooveSize = 6

	self.value = 0
	self.movingSlider = false

	-- slider colors
	self.normal = U.grey(180)
	self.highlight = U.grey(220)
	self.pressed = U.grey(255)
	self.disabled = U.grey(128, 128)

	self.grooveColor = U.grey(180)
	self.color = self.normal
	self.interactible = true
	self.prevLeftClick = false
end

function Slider:getValue()
	if self.isVertical then
		return U.round(self.sliderPos * 100 / (self.h - self.sliderSize))
	else
		return U.round(self.sliderPos * 100 / (self.w - self.sliderSize))
	end
end

function Slider:update(dt)
	if not self.interactible then return end
	local mx, my = love.mouse.getPosition()
	local leftClick = love.mouse.isDown(1)
	local inBounds = false
	if self.isVertical then
		inBounds = U.mouseInRect(self.pos.x + self.w / 2, self.pos.y + self.h - self.sliderPos - self.sliderSize / 2, self.w, self.sliderSize, mx, my)
	else
		inBounds = U.mouseInRect(self.pos.x + self.sliderPos + self.sliderSize / 2, self.pos.y - self.h / 2, self.sliderSize, self.h, mx, my)
	end

	if inBounds and not leftClick then
		self.color = self.highlight
	elseif inBounds and leftClick then
		if not self.prevLeftClick then
			if self.isVertical then
				self.sliderDelta = self.pos.y + self.h - self.sliderPos - my
			else
				self.sliderDelta = self.sliderPos - mx
			end
			self.movingSlider = true
		end
	elseif not inBounds then
		self.color = self.normal
	end

	if self.movingSlider and leftClick then
		self.color = self.pressed
		self.prevSliderPos = self.sliderPos

		if self.isVertical then
			self.sliderPos = self.pos.y + self.h -(my + self.sliderDelta)
			if self.sliderPos > self.h - self.sliderSize then
				self.sliderPos = self.h - self.sliderSize
			elseif self.sliderPos < 0 then
				self.sliderPos = 0
			end
		else
			self.sliderPos = mx + self.sliderDelta
			if self.sliderPos > self.w - self.sliderSize then
				self.sliderPos = self.w - self.sliderSize
			elseif self.sliderPos < 0 then
				self.sliderPos = 0
			end
		end

		if self.prevSliderPos ~= self.sliderPos then
			_G.events:invoke("onSliderChanged", self)
		end

	elseif self.movingSlider and not leftClick then
		self.movingSlider = false
		self.color = self.normal
	end
	self.prevLeftClick = leftClick
end

function Slider:draw()
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(self.grooveColor)

	if self.isVertical then
		love.graphics.rectangle("fill", self.pos.x + self.w / 2 - self.grooveSize / 2, self.pos.y, self.grooveSize, self.h, 2, 2)
		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill", self.pos.x, self.pos.y + self.h - self.sliderPos - self.sliderSize, self.w, self.sliderSize, 2, 2)
	else
		love.graphics.rectangle("fill", self.pos.x, self.pos.y - self.h / 2 - self.grooveSize / 2, self.w, self.grooveSize, 2, 2)
		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill", self.pos.x + self.sliderPos, self.pos.y - self.h, self.sliderSize, self.h, 2, 2)
	end

	love.graphics.setColor(r, g, b, a)
end

return Slider
