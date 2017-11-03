local Class = require("lib.Class")
local vector = require("hump.vector")
local U = require("lib.Utils")

local Button = Class:derive("Button")

function Button:new(x, y, w, h, text)
	self.pos = vector(x or 0, y or 0)
	self.w = w
	self.h = h
	self.text = text
	-- button colors
	self.normal = U.color(100, 190, 50, 180)
	self.highlight = U.color(100, 190, 50, 255)
	self.pressed = U.color(100, 240, 50, 255)
	self.disabled = U.grey(128, 180)
	-- text colors
	self.textNormal = U.color(255)
	self.textDisabled = U.grey(180, 255)

	self.textColor = self.textNormal
	self.color = self.normal
	self.prevLeftClick = false
	self.interactible = true
	self.inBounds = false
end

function Button:setTextColors(normal, disabled)
	assert(type(normal) == "table", "normal parameter must be a table!")
	assert(type(disabled) == "table", "disabled parameter must be a table!")
	self.textNormal = normal
	self.textDisabled = disabled
	self.textColor = self.textNormal
end

function Button:setButtonColors(normal, highlight, pressed)
	assert(type(normal) == "table", "normal parameter must be a table!")
	assert(type(highlight) == "table", "highlight parameter must be a table!")
	assert(type(pressed) == "table", "pressed parameter must be a table!")

	self.normal = normal
	self.highlight = highlight
	self.pressed = pressed
end

function Button:left(x)
	self.pos.x = x + self.w / 2
end

function Button:right(x)
	self.pos.x = x - self.w / 2
end

function Button:top(y)
	self.pos.y = y + self.h / 2
end

function Button:bottom(y)
	self.pos.y = y - self.h / 2
end

function Button:enabled(enable)
	self.interactible = enable
	if not enable then
		self.color = self.disabled
		self.textColor = self.textDisabled
	else
		self.textColor = self.textNormal
	end
end

function mouseInBounds(self, mouseX, mouseY)
	return mouseX >= self.pos.x - self.w / 2 and
	mouseX <= self.pos.x + self.w / 2 and
	mouseY >= self.pos.y - self.h / 2 and
	mouseY <= self.pos.y + self.h / 2
end

function Button:update(dt)
	local mx, my = love.mouse.getPosition()
	self.inBounds = mouseInBounds(self, mx, my)
	if not self.interactible then self.color = self.disabled return end
	local leftClick = love.mouse.isDown(1)

	if self.inBounds and not leftClick then
		if self.prevLeftClick and self.color == self.pressed then
			_G.events:invoke("onButtonClick", self)
		end
		self.color = self.highlight
	elseif self.inBounds and leftClick and not self.prevLeftClick then
		self.color = self.pressed
	elseif not self.inBounds then
		self.color = self.normal
	end

	self.prevLeftClick = leftClick

end

function Button:draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.pos.x - self.w / 2, self.pos.y - self.h / 2, self.w, self.h, 4, 4)

	local f = love.graphics.getFont()
	local _, lines = f:getWrap(self.text, self.w)
	local fh = f:getHeight()
	love.graphics.setColor(self.textColor)
	love.graphics.printf(self.text, self.pos.x - self.w / 2, self.pos.y - (fh / 2 * #lines), self.w, "center")
	love.graphics.setColor(r, g, b, a)
end

return Button
