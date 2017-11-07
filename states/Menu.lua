local Menu = {}

local EntityMgr = require("lib.EntityMgr")
local Button = require("lib.ui.Button")
local Label = require("lib.ui.Label")
local Slider = require("lib.ui.Slider")
local TextField = require("lib.ui.TextField")

local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

function Menu:init()
    self.em = EntityMgr()

    local startButton = Button(sw / 2, sh / 2 - 30, 140, 40, "Start")
    local exitButton = Button(sw / 2, sh / 2 + 30, 140, 40, "Exit")
    exitButton:setButtonColors({170, 50, 50, 220}, {220, 40, 40}, {255, 20, 20})
    self.em:add(startButton)
    self.em:add(exitButton)

    self.buttonClick = function(button) self:onClick(button) end
end

function Menu:enter()
    self.em:onEnter()
    _G.events:hook("onButtonClick", self.buttonClick)
end

function Menu:leave()
    self.em:onExit()
    _G.events:unhook("onButtonClick", self.buttonClick)
end

function Menu:onClick(button)
	if button.text == "Start" then
		Gamestate.switch(Game)
	elseif button.text == "Exit" then
		-- love.event.quit()
        Tween.create(button.pos, "x", 0, 1)
	end
end

-- function Menu:keypressed(key)
--     if key == "escape" then
--         love.event.quit()
--     elseif key == "return" then
--         Gamestate.switch(Game)
--     end
-- end

function Menu:update(dt) self.em:update(dt) end

function Menu:draw()
    love.graphics.clear(155, 205, 255)
    self.em:draw()
end

return Menu
