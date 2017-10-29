local Class = require "hump.class"

local N = Class{}

function N:init(x, y)
    self.parent = nil
    self.x = x
    self.y = y
    self.f = 0
    self.g = 0
    self.h = 0
end

return N
