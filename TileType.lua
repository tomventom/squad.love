local Class = require "hump.class"

local TT = Class{}

function TT:init(name, quad)
    self.name = name
    self.sprite = Quads[quad]
    self.w = 32
    self.h = 32
end

return TT
