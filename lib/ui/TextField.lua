local Label = require("lib.ui.Label")
local U = require("lib.Utils")
local utf8 = require("utf8")

local TextField = Label:derive("TextField")

local cursor = "|"

function TextField:new(x, y, w, h, text, color, align)
    TextField.super.new(self, x, y, w, h, text, color, align)
    self.focused = false
    self.focusedColor = U.grey(128)
    self.unfocusedColor = U.grey(32)

    self.bgColor = self.unfocusedColor

    self.keyPressed = function(key) if key == "backspace" then self:onTextInput(key) end end
    self.textInput = function(text) self:onTextInput(text) end

end

function TextField:getRect()
    return {x = self.pos.x, y = self.pos.y - self.h / 2, w = self.w, h = self.h}
end

function TextField:setFocus(focused)
    assert(type(focused) == "boolean", "parameter focused should be of type boolean")

    if focused then
        self.bgColor = self.focusedColor
        if not self.focused then
            self.text = self.text .. cursor
        end
    elseif not focused then
        self.bgColor = self.unfocusedColor
        if self.focused then
            self:removeEndchars(1)
        end
    end

    self.focused = focused

end

function TextField:onEnter()
    _G.events:hook("keyPressed", self.keyPressed)
    _G.events:hook("textInput", self.textInput)
end

function TextField:onExit()
    _G.events:unhook("keyPressed", self.keyPressed)
    _G.events:unhook("textInput", self.textInput)
end

function TextField:onTextInput(text)
    if not self.focused or not self.enabled then return end


    if text == "backspace" then
        self:removeEndchars(2)
        self.text = self.text .. cursor
    else
        self:removeEndchars(1)
        self.text = self.text .. text
        self.text = self.text .. cursor
    end
end

function TextField:removeEndchars(num)
    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset = utf8.offset(self.text, - num)

    if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters,
        -- so we couldn't do string.sub(text, 1, -2).
        self.text = string.sub(self.text, 1, byteoffset - 1)
    end
end

function TextField:draw()
    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y - self.h / 2, self.w, self.h)
    TextField.super.draw(self)
end

return TextField
