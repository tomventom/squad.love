local Class = require("lib.Class")
local vector = require("hump.vector")

local U = Class:derive("Unit")

local speed = 0.2

function U:new(x, y)
    self.pos = vector(x, y)
    self.w = 16
    self.h = 16
    self.hasPath = false
    self.path = nil
    self.drawMe = false
    self.timer = 0
    self.index = 1
    -- if self.saySomething then self:saySomething(...) end
end

function U:moveTo(x, y)
    self.pos.x = x
    self.pos.y = y
end

function U:move(path)
    if self.hasPath then
        self.index = 1
        self.path = path
        return
    end
    self.drawMe = true
    self.path = path
    self.hasPath = true
end

function U:fixPosition()
    self.pos.x = Utils.round(self.pos.x)
    self.pos.y = Utils.round(self.pos.y)
end

function U:update(dt)
    self.timer = self.timer + dt
    if self.timer >= speed then
        self.timer = self.timer - speed
        if self.hasPath then
            -- self.pos.x = self.path[self.index].x
            -- self.pos.y = self.path[self.index].y
            flux.to(self.pos, speed, {x = self.path[self.index].x, y = self.path[self.index].y})
            self.index = self.index + 1
            if self.index > #self.path then
                self.hasPath = false
                self.index = 1
            end
        end
    end
end

function U:draw()
    love.graphics.draw(Tileset, Quads[4], self.pos.x * 32 - 32, self.pos.y * 32 - 32)
    -- if draw and self.path then
    --     love.graphics.setColor(0, 0, 0, 255)
    --     for k, v in pairs(self.path) do
    --         love.graphics.rectangle("line", v.x * 32 - 32, v.y * 32 - 32, 32, 32)
    --     end
    --     love.graphics.setColor(255, 255, 255, 255)
    -- end
end

return U
