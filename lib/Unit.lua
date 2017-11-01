local Class = require("hump.class")
local vector = require("hump.vector")
local flux = require("lib.flux")

local U = Class{}

local draw = false
local hasPath = false
local timer = 0
local index = 1

local speed = 0.3

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
    if hasPath then
        index = 1
        self.path = path
        return
    end
    draw = true
    self.path = path
    hasPath = true
end

function U:fixPosition()
    self.pos.x = Utils.round(self.pos.x)
    self.pos.y = Utils.round(self.pos.y)
end

function U:update(dt)
    flux.update(dt)
    -- this adds dt every frame, adding 1 every second
    timer = timer + dt
    -- this checks if timer is greater than the time interval (in seconds)
    if timer >= speed then
        -- subtract timer by interval
        timer = timer - speed
        if hasPath then
            -- self.pos.x = self.path[index].x
            -- self.pos.y = self.path[index].y
            flux.to(self.pos, speed, {x = self.path[index].x, y = self.path[index].y})
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
    if draw and self.path then
        love.graphics.setColor(0, 0, 0, 255)
        for k, v in pairs(self.path) do
            love.graphics.rectangle("line", v.x * 32 - 32, v.y * 32 - 32, 32, 32)
        end
        love.graphics.setColor(255, 255, 255, 255)
    end
end

return U
