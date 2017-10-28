local Class = require "hump.class"
local vector = require "hump.vector"

local U = Class{}

function U:init(x, y)
    self.pos = vector(x, y)
    self.w = 16
    self.h = 16
end

function U:update(dt)

end

function U:draw()
    love.graphics.draw(Tileset, Quads[4], self.pos.x * 32 - 32, self.pos.y * 32 - 32)
end

return U
