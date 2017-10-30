local Class = require("hump.class")
local vector = require("hump.vector")
local Timer = require("hump.timer")

local U = Class{}

local draw = false
local hasPath = false


function U:init(x, y)
    self.pos = vector(x, y)
    self.w = 16
    self.h = 16
    self.path = nil
end

function U:moveTo(x, y)
    self.pos.x = x
    self.pos.y = y
end

function U:move(path)
    if hasPath then return end
    -- draw = true
    hasPath = true
    self.path = path
    -- self.pos.x = path[#path].x
    -- self.pos.y = path[#path].y
end

local timer = 0
local index = 1
function U:update(dt)
    Timer.update(dt)
    -- this adds dt every frame, adding 1 every second
    timer = timer + dt
    -- this checks if timer is greater than the time interval (in seconds)
    if timer >= .5 then
        -- subtract timer by interval
        timer = timer - .2
        if hasPath then
            self.pos.x = self.path[index].x
            self.pos.y = self.path[index].y
            index = index + 1
            if index > #self.path then
                hasPath = false
                index = 1
            end
        end
    end
end

function U:draw()
    love.graphics.draw(Tileset, Quads[4], self.pos.x * 32 - 32, self.pos.y * 32 - 32)
    if draw then
        for k, v in pairs(self.path) do
            love.graphics.rectangle("line", v.x * 32 - 32, v.y * 32 - 32, 32, 32)
        end
    end
end

return U
