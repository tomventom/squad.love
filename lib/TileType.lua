local Class = require "lib.Class"

local TT = Class:derive("TileType")

function TT:new(name, quad, moveCost, walkable)
    self.name = name
    self.sprite = Quads[quad]
    self.w = 32
    self.h = 32
    self.moveCost = moveCost
    self.walkable = (walkable == nil) or walkable
end

return TT
