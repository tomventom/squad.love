local Class = require("lib.Class")
local vector = require("hump.vector")


local SU = Class:derive("Unit")

function SU:new(id, x, y)
    self.id = id
    self.pos = vector(x, y)
    self.drawPos = vector(x, y)
end

function SU:update(dt)

end

function SU:draw()
    love.graphics.draw(Tileset, Quads[4], self.drawPos.x * 32 - 32, self.drawPos.y * 32 - 32)
end

return SU
