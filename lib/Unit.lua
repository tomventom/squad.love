local Class = require("lib.Class")
local vector = require("hump.vector")

local U = Class:derive("Unit")

local speed = 0.2

function U:new(id, x, y)
    self.id = id
    self.pos = vector(x, y)
    self.w = 16
    self.h = 16

    self.pathfinder = nil
    self.path = nil
    self.currentPath = nil
    self.moveSpeed = 1
    self.remainingSpeed = self.moveSpeed
    self.tweening = false
    self.lastposX, self.lastposY = x, y

    self.drawMe = false

    UnitMap[self.pos.x * TmapSizeY + self.pos.y - 1] = self

    self.endTurn = function() self:moveToNextTile() end
end

function U:onEnter()
    _G.events:hook("onEndTurn", self.endTurn)
end

function U:onExit()
    _G.events:unhook("onEndTurn", self.endTurn)
end

-- Returns true if the first tile in the currentPath has another Unit in it
local function checkNextTile(self)
    local nextTile = self.currentPath[1]
    return UnitMap[nextTile.x * TmapSizeY + nextTile.y - 1] ~= nil
end

-- Returns true if the unit in the next tile is moving to my current position
local function movingToMyPos(self)
    local nextTile = self.currentPath[1]
    local u = UnitMap[nextTile.x * TmapSizeY + nextTile.y - 1]
    if u and u.currentPath then
        if #u.currentPath > 0 then
            return u.currentPath[1].x == self.pos.x and u.currentPath[1].y == self.pos.y
        elseif #u.currentPath <= 0 then
            return true
        end
    elseif u then return true
    end
    return false
end

local function movingToTheSamePos(self)
    local nextTile = self.currentPath[1]
    local u = UnitMap[nextTile.x * TmapSizeY + nextTile.y - 1]
    if u and u.currentPath and #u.currentPath > 0 then
        return u.currentPath[1].x == self.currentPath[1].x and u.currentPath[1].y == self.currentPath[1].y
    end
    return false
end

-- Rounds the position to the nearest round value
local function fixPosition(self)
    self.pos.x = Utils.round(self.pos.x)
    self.pos.y = Utils.round(self.pos.y)
end

-- Asks the pathfinder for a path to the given x,y coordinates
-- If the unit is currently tweening, or if
-- the pathfinder returns no path, return
function U:moveTo(x, y, blocked)
    if self.tweening then return end
    fixPosition(self)
    local path = self.pathfinder:findPath(self.pos.x, self.pos.y, x, y, blocked)
    if not path then self.path = nil return end
    self.path = path
    self.currentPath = Utils.clone(self.path)
end

local function sequenceTween(self)
    flux.to(self.pos, 1, {x = self.currentPath[1].x, y = self.currentPath[1].y}):oncomplete(function()
        self.remainingSpeed = self.remainingSpeed - self.currentPath[1].cost
        table.remove(self.currentPath, 1)
        self.lastposX, self.lastposY = self.pos.x, self.pos.y
    end)
end

-- Move to the next tile/s on the current path
function U:moveToNextTile()
    -- print(self.id)
    UnitMap[self.pos.x * TmapSizeY + self.pos.y - 1] = self

    if not self.path then return end
    if self.tweening then return end

    -- If the current path has no values, the path is empty
    if #self.currentPath == 0 then return end

    -- If the current path only has one value, make sure the remaining speed
    -- is set to 1
    if #self.currentPath == 1 then
        self.remainingSpeed = 1
    end

    -- If the next tile is blocked, recalc path
    if movingToTheSamePos(self) then return end
    if movingToMyPos(self) then
        self:moveTo(self.path[#self.path].x, self.path[#self.path].y, true)
        if not self.path then return end
        if self.remainingSpeed < 1 then return end
        if #self.currentPath == 1 then self.path = nil return end
    end

    self.tweening = true

    UnitMap[self.lastposX * TmapSizeY + self.lastposY - 1] = nil

    UnitMap[self.currentPath[1].x * TmapSizeY + self.currentPath[1].y - 1] = self
    print(string.format("ID: %d \nLast Pos: %d,%d is now nil \nNext Pos: %d,%d is now self \n======", self.id, self.lastposX, self.lastposY, self.currentPath[1].x, self.currentPath[1].y))
    sequenceTween(self)

    Timer.after(2, function()
        self.tweening = false
        -- If the unit still has speed, keep going
        if self.remainingSpeed > 0 then
            self:moveToNextTile()
        else
            self.remainingSpeed = self.moveSpeed
        end
    end)


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
