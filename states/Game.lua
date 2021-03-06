
local Game = {}

local Camera = require("hump.camera")
local Tilemap = require("lib.Tilemap")
local Player = require("lib.Player")
local Unit = require("lib.Unit")
local Pathfinder = require("lib.Pathfinder")

local sw = love.graphics.getWidth()
local sh = love.graphics.getHeight()

local EntityMgr = require("lib.EntityMgr")
local Button = require("lib.ui.Button")
local Label = require("lib.ui.Label")
local Slider = require("lib.ui.Slider")
local TextField = require("lib.ui.TextField")

Tileset = love.graphics.newImage("assets/tilesetnogrid.png")
local mapImage = love.graphics.newImage("maps/ambush1.png")
local tw = Tileset:getWidth()
local th = Tileset:getHeight()

TmapSizeX, TmapSizeY = 40, 20

-- Quads contains the seperate tile sprites
Quads = {}
Quads[1] = love.graphics.newQuad(0, 0, 32, 32, tw, th) -- grass
Quads[2] = love.graphics.newQuad(32, 0, 32, 32, tw, th) -- swamp
Quads[3] = love.graphics.newQuad(64, 0, 32, 32, tw, th) -- water
Quads[4] = love.graphics.newQuad(128, 0, 32, 32, tw, th) -- unit
Quads[5] = love.graphics.newQuad(0, 32, 32, 32, tw, th) -- sand
Quads[6] = love.graphics.newQuad(128, 32, 32, 64, tw, th) -- tree
Quads[7] = love.graphics.newQuad(0, 64, 32, 32, tw, th) -- selected


Quads[99] = love.graphics.newQuad(96, 64, 32, 32, tw, th) -- empty

local tmap = Tilemap(TmapSizeX, TmapSizeY, mapImage)
GlobalMap = {}
local mx, my = 0, 0
local tx, ty = 0, 0
local drawMousePos = false
local selected

local dragging = false
local dragX, dragY = 0, 0
local camX, camY, camZoom = 0, 0, 1

local player

-- initialize the map, unit and camera
function Game:init()
    self.uiMgr = EntityMgr()
    self.em = EntityMgr()

    self.endTurnButton = Button(sw - 100, sh - 40, 160, 60, "End Turn")
    self.endTurnButton:setButtonColors(Utils.grey(200, 160), Utils.grey(200, 200), Utils.grey(240))
    self.endTurnButton:setTextColors(Utils.grey(0), Utils.grey(60))
    self.uiMgr:add(self.endTurnButton)
    self.buttonClick = function(button) self:onClick(button) end
    GlobalMap = tmap:getTileGrid()
    UnitMap = {}

        local p = Player("1", 5, 5)
        self.em:add(p)
        local p = Unit("2", 16, 7)
        p.pathfinder = Pathfinder()
        self.em:add(p)
        local p = Unit("3", 17, 8)
        p.pathfinder = Pathfinder()
        self.em:add(p)
        local p = Unit("4", 16, 9)
        p.pathfinder = Pathfinder()
        self.em:add(p)

    for i = 1, #self.em.entities do
        if self.em.entities[i]:is(Player) then player = self.em.entities[i] print("found player") end
    end
    camera = Camera(256, 192, camZoom)
end

function Game:enter()
    self.uiMgr:onEnter()
    self.em:onEnter()
    _G.events:hook("onButtonClick", self.buttonClick)
end

function Game:leave()
    self.uiMgr:onExit()
    self.em:onExit()
    _G.events:unhook("onButtonClick", self.buttonClick)
end

function Game:onClick(button)
    if button.text == "End Turn" then
        button:enabled(false)
        _G.events:invoke("onEndTurn")
        Timer.after(.6, function() button:enabled(true) end)
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        if camZoom < 2 then camZoom = camZoom + 0.5 end
    elseif y < 0 then
        if camZoom > 0.5 then camZoom = camZoom - 0.5 end
    end
    camera:zoomTo(camZoom)
end

function Game:update(dt)
    self.uiMgr:update(dt)
    self.em:update(dt)

    if dragging then
        camera.x = camera.x + dragX - mx
        camera.y = camera.y + dragY - my
    end
    if love.keyboard.isDown("w") then camY = -1 elseif love.keyboard.isDown("s") then camY = 1 end
    if love.keyboard.isDown("a") then camX = -1 elseif love.keyboard.isDown("d") then camX = 1 end
    camera:move(camX * 400 * dt, camY * 400 * dt)
    camX, camY = 0, 0

    -- get the mouse position in world coordinates
    mx, my = camera:worldCoords(love.mouse.getPosition())
    tx, ty = tmap:getTile(mx, my)

    drawMousePos = tx ~= 0 and ty ~= 0
end

local function selectUnit(unit)
    selected = unit
    selected.drawMe = true
end

local function deselectUnit()
    selected.drawMe = false
    selected = nil
end

function Game:keypressed(key)
    if key == "escape" then
        -- Gamestate.switch(Menu)
        love.event.quit()
    end

    if key == "1" then selectUnit(1) end
    if key == "2" then selectUnit(2) end
    if key == "3" then selectUnit(3) end
    if key == "4" then selectUnit(4) end
end

function Game:mousepressed(x, y, key)

    if key == 3 then
        dragging = true
        dragX, dragY = mx, my
    end
end

function Game:mousereleased(x, y, key)
    if key == 3 then dragging = false end
    if self.endTurnButton.inBounds then return end
    -- if a tile was clicked, move the unit to it
    if key == 2 and tx ~= 0 and ty ~= 0 and selected then
        selected:moveTo(tx, ty)
    end
    if key == 1 then
        if selected then deselectUnit() end
        for i = 1, #self.em.entities do
            if self.em.entities[i]:is(Unit) then
                if self.em.entities[i].pos.x == tx and self.em.entities[i].pos.y == ty then selectUnit(self.em.entities[i]) end
            end
        end
    end
end

function Game:draw()
    love.graphics.clear(200, 200, 200)
    camera:attach()
    tmap:draw()

    self.em:draw()
    if selected then love.graphics.draw(Tileset, Quads[7], selected.pos.x * 32 - 32, selected.pos.y * 32 - 32) end
    if drawMousePos then
        if UnitMap[tx * TmapSizeY + ty - 1] ~= nil then
            love.graphics.setColor(255, 0, 0)
        else
            love.graphics.setColor(0, 255, 0)
        end
        love.graphics.rectangle("line", tx * 32 - 32, ty * 32 - 32, 32, 32)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(tx .. ", " .. ty, mx + 10, my - 10)
        love.graphics.setColor(255, 255, 255)
    end
    -- for x = 1, TmapSizeX do
    --     for y = 1, TmapSizeY do
    --         if UnitMap[x * TmapSizeY + y - 1] ~= nil then
    --             love.graphics.rectangle("line", x * 32 - 32, y * 32 - 32, 32, 32)
    --         end
    --     end
    -- end
    camera:detach()
    self.uiMgr:draw()
end

return Game
