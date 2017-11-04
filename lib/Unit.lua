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
    self.currentPath = nil
    self.stepsTaken = 1
    self.drawMe = false
    self.timer = 0
    self.pathfinder = nil
    self.moveSpeed = 2
    self.remainingSpeed = 0
    self.tweening = false
    self.lastposX, self.lastposY = x, y
    GlobalMap[self.pos.x * TmapSizeY + self.pos.y - 1].occupied = true

    -- if self.saySomething then self:saySomething(...) end
end

local function checkNextTile(self)
    local nextTile = self.currentPath[1]
    return GlobalMap[nextTile.x * TmapSizeY + nextTile.y - 1].occupied
end

function U:confirmPosition()
    GlobalMap[self.pos.x * TmapSizeY + self.pos.y - 1].occupied = true
end

local function fixPosition(self)
    self.pos.x = Utils.round(self.pos.x)
    self.pos.y = Utils.round(self.pos.y)
end

function U:moveTo(x, y, blocked)
    fixPosition(self)
    local path = self.pathfinder:findPath(self.pos.x, self.pos.y, x, y, blocked)
    if not path then self.path = nil return end
    if self.hasPath then
        self.path = path
        self.currentPath = Utils.clone(self.path)
        self.stepsTaken = 1
        return
    end
    -- self.drawMe = true
    self.path = path
    self.hasPath = true
    self.currentPath = Utils.clone(self.path)
    self.stepsTaken = 1
end

function U:moveAtRandom()
    fixPosition(self)
    local path = self.pathfinder:findPath(self.pos.x, self.pos.y, love.math.random(1, 39), love.math.random(1, 19))
    if not path then return end
    if self.hasPath then
        self.path = path
        self.currentPath = Utils.clone(self.path)
        self.stepsTaken = 1
        return
    end
    -- self.drawMe = true
    self.path = path
    self.currentPath = Utils.clone(self.path)
    self.stepsTaken = 1
    self.hasPath = true
end

local function sequenceTween(self)
    self.tweening = true
    if #self.currentPath == 0 then return end
    -- uncomment this for non turn-based movement
    -- self.remainingSpeed = #self.currentPath

    if checkNextTile(self) then
        self.tweening = false
        self:moveTo(self.path[#self.path].x, self.path[#self.path].y, true)
        if not self.path then return end
        if self.remainingSpeed < 1 then return end
        if #self.currentPath == 1 then return end
    end

    -- tell the Global Map the tile we're on is occupied
    GlobalMap[self.lastposX * TmapSizeY + self.lastposY - 1].occupied = false
    GlobalMap[self.currentPath[1].x * TmapSizeY + self.currentPath[1].y - 1].occupied = true

    flux.to(self.pos, speed, {x = self.currentPath[1].x, y = self.currentPath[1].y}):oncomplete(function()
    -- self.pos.x, self.pos.y = self.currentPath[1].x, self.currentPath[1].y
        self.remainingSpeed = self.remainingSpeed - self.currentPath[1].cost
        table.remove(self.currentPath, 1)
        self.stepsTaken = self.stepsTaken + 1

        self.lastposX, self.lastposY = self.pos.x, self.pos.y

        self.tweening = false
        if #self.currentPath > 0 and checkNextTile(self) then
            -- self.tweening = false
            self:moveTo(self.path[#self.path].x, self.path[#self.path].y, true)
            if not self.path then return end
            if self.remainingSpeed < 1 then return end
        end
        if self.remainingSpeed > 0 then sequenceTween(self) end
    end)

end

function U:moveToNextTile()
    self.remainingSpeed = self.moveSpeed
    if not self.path then return end
    if not self.hasPath then self.stepsTaken = 1 return end
    if not self.tweening then
        if #self.currentPath == 0 then return end
        if #self.currentPath == 1 then
            self.remainingSpeed = 1
            self.hasPath = false
        end
        sequenceTween(self)
    end
end

function U:update(dt)

end

function U:drawPath()
    if self.drawMe and self.path then
        love.graphics.setColor(255, 255, 255, 100)
        local linePath = {}
        local prevX, prevY = self.lastposX, self.lastposY
        for i = 1, #self.currentPath do
            love.graphics.line(prevX * 32 - 16, prevY * 32 - 16, self.currentPath[i].x * 32 - 16, self.currentPath[i].y * 32 - 16)
            prevX, prevY = self.currentPath[i].x, self.currentPath[i].y
        end
        love.graphics.setColor(255, 255, 255, 255)
    end
end

function U:draw()
    love.graphics.draw(Tileset, Quads[4], self.pos.x * 32 - 32, self.pos.y * 32 - 32)
    self:drawPath()
end

return U
