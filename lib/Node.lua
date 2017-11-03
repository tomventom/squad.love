local Class = require("lib.Class")

local N = Class:derive("Node")

function N:new(x, y)
    self.parent = nil
    self.x = x
    self.y = y
    self.f = 0
    self.g = 0
    self.h = 0
    self.cost = 1
end

return N
