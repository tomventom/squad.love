local Game = {}

local Camera = require("hump.camera")
local Tilemap = require("lib.Tilemap")
local Unit = require("lib.Unit")
local Pawn = require("lib.Pawn")
local Pathfinder = require("lib.Pathfinder")


Tileset = love.graphics.newImage("assets/tileset.png")
local tw = Tileset:getWidth()
local th = Tileset:getHeight()

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

local tmap = Tilemap(64, 64)
local mx, my = 0, 0
local tx, ty = 0, 0
local drawMousePos = false
local units = {}
local selected

local dragging = false
local dragX, dragY = 0, 0
local camX, camY, camZoom = 0, 0, .5

-- initialize the map, unit and camera
function Game:init()
    for i = 1, 11 do
        units[i] = Pawn(i * 5, 5)
        units[i].pathfinder = Pathfinder(tmap, 64, 64)
    end
    -- unit = Pawn(60, 5)
    camera = Camera(256, 192, camZoom)
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
    if dt > 0.04 then return end
    for i = 1, #units do
        units[i]:update(dt)
    end

    if dragging then
        camera.x = camera.x + dragX - mx
        camera.y = camera.y + dragY - my
    end
    -- camera:lockPosition(unit.pos.x * 32 - 32, unit.pos.y * 32 - 32, Camera.smooth.damped(4))
    if love.keyboard.isDown("w") then camY = -1 elseif love.keyboard.isDown("s") then camY = 1 end
    if love.keyboard.isDown("a") then camX = -1 elseif love.keyboard.isDown("d") then camX = 1 end
    camera:move(camX * 400 * dt, camY * 400 * dt)
    camX, camY = 0, 0

    -- get the mouse position in world coordinates
    mx, my = camera:worldCoords(love.mouse.getPosition())
    tx, ty = tmap:getTile(mx, my)

    drawMousePos = tx ~= 0 and ty ~= 0
end

function Game:keypressed(key)
    if key == "escape" then
        -- Gamestate.switch(Menu)
        love.event.quit()
    elseif key == "k" and selected then
    end

    if key == "m" then
        for i = 1, #units do
            units[i]:move() end
        end

        if key == "1" then selected = units[1] end
        if key == "2" then selected = units[2] end
        if key == "3" then selected = units[3] end
        if key == "4" then selected = units[4] end
    end

    function Game:mousepressed(x, y, key)
        if key == 3 then
            dragging = true
            dragX, dragY = mx, my
        end
    end

    function Game:mousereleased(x, y, key)
        if key == 3 then dragging = false end

        -- if a tile was clicked, move the unit to it
        if key == 2 and tx ~= 0 and ty ~= 0 and selected then
            selected:moveTo(tx, ty)
        end
        if key == 1 then
            if selected then selected = nil end
            for i = 1, #units do
                if units[i].pos.x == tx and units[i].pos.y == ty then selected = units[i] end
            end
        end
    end

    function Game:draw()
        love.graphics.clear(200, 200, 200)
        camera:attach()
        tmap:draw()
        for i = 1, #units do
            units[i]:draw()
        end
        if selected then love.graphics.draw(Tileset, Quads[7], selected.pos.x * 32 - 32, selected.pos.y * 32 - 32) end
        if drawMousePos then love.graphics.rectangle("line", tx * 32 - 32, ty * 32 - 32, 32, 32) end
        camera:detach()
    end

    return Game
