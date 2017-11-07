local SuperUnit = require("lib.SuperUnit")

local Player = SuperUnit:derive("Player")

local down = love.keyboard.isDown
local moving = false

function Player:new(id, x, y)
    Player.super.new(self, id, x, y)
    self.drawPos = {x = x, y = y}
    UnitMap[self.pos.x * TmapSizeY + self.pos.y - 1] = self
    self.confirmPos = function() self:confirmPosition() end
end

function Player:onEnter()
    _G.events:hook("onConfirmPos", self.confirmPos)
end

function Player:onExit()
    _G.events:unhook("onConfirmPos", self.confirmPos)
end

function Player:confirmPosition()
    UnitMap[self.pos.x * TmapSizeY + self.pos.y - 1] = self
end

local function moveInput(self)
    if down("up") and down("left") then
        self:move(-1, - 1)
    elseif down("up") and down("right") then
        self:move(1, - 1)
    elseif down("down") and down("left") then
        self:move(-1, 1)
    elseif down("down") and down("right") then
        self:move(1, 1)
    elseif down("left") then
        self:move(-1, 0)
    elseif down("down") then
        self:move(0, 1)
    elseif down("right") then
        self:move(1, 0)
    elseif down("up") then
        self:move(0, - 1)
    end
end

function Player:move(x, y)
    local nextX, nextY = self.pos.x + x, self.pos.y + y
    if UnitMap[nextX * TmapSizeY + nextY - 1] ~= nil then return end
    if GlobalMap[nextX * TmapSizeY + nextY - 1].moveCost >= math.huge or not GlobalMap[nextX * TmapSizeY + nextY - 1].walkable then return end
    self.moving = true
    UnitMap[self.pos.x * TmapSizeY + self.pos.y - 1] = nil

    -- Tween.create(self.drawPos, "x", nextX, .3)
    -- Tween.create(self.drawPos, "y", nextY, .3)
    flux.to(self.drawPos, .3, {x = nextX, y = nextY}):ease("quadinout")
    self.pos.x = self.pos.x + x
    self.pos.y = self.pos.y + y

    UnitMap[self.pos.x * TmapSizeY + self.pos.y - 1] = self

    Timer.after(.2, function()
        _G.events:invoke("onMoveToPoint", self.pos.x, self.pos.y)
        _G.events:invoke("onEndTurn")
    end)

    Timer.after(.6, function() self.moving = false end)
    -- self.moving = false
end

function Player:update(dt)
    Player.super.update(self, dt)
    if not self.moving then
        moveInput(self)
    end
end

function Player:draw()
    Player.super.draw(self)
end

return Player
