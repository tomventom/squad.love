local Unit = require("lib.Unit")

local Pawn = Unit:derive("Pawn")

function Pawn:new(x, y)
    Pawn.super.new(self, x, y)
    self:saySomething()
end

function Pawn:saySomething()
end

return Pawn
