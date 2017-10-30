local Class = require "hump.class"

local TT = Class{}

function TT:init(name, quad, moveCost, walkable)
    self.name = name
    self.sprite = Quads[quad]
    self.w = 32
    self.h = 32
    self.moveCost = moveCost
    self.walkable = (walkable == nil) or walkable
end

return TT
