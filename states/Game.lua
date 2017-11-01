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

local tmap = Tilemap(64, 64)
local finders = {}
local pathf = Pathfinder(tmap, 64, 64)
local mx, my = 0,0
local tx, ty = 0,0
local drawMousePos = false
local drawClosed = false
local closedList
local units = {}

local camX, camY = 0,0

-- initialize the map, unit and camera
function Game:init()
    for i = 1, 6 do
        units[i] = Pawn(i*10, 5)
        finders[i] = Pathfinder(tmap, 64, 64)
    end
    -- unit = Pawn(60, 5)
    camera = Camera(256, 192, .5)
end


function Game:update(dt)
    if dt > 0.04 then return end
    for i = 1, #units do
        units[i]:update(dt)
    end
    -- camera:lockPosition(unit.pos.x * 32 - 32, unit.pos.y * 32 - 32, Camera.smooth.damped(4))
    if love.keyboard.isDown("w") then camY = -1 elseif love.keyboard.isDown("s") then camY = 1 end
    if love.keyboard.isDown("a") then camX = -1 elseif love.keyboard.isDown("d") then camX = 1 end
    camera:move(camX * 300 * dt, camY * 300 * dt)
    camX, camY = 0,0
    -- get the mouse position in world coordinates
    mx, my = camera:worldCoords(love.mouse.getPosition())
    tx, ty = tmap:getTile(mx, my)

    drawMousePos = tx ~= 0 and ty ~= 0
end

function Game:keypressed(key)
    if key == "escape" then
        -- Gamestate.switch(Menu)
        love.event.quit()
    elseif key == "k" then
        drawClosed = not drawClosed
    end

    if key == "m" then
        local goals = {}
        for i = 1, #units do
            units[i]:fixPosition()
            goals[i] = finders[i].findPath(units[i].pos.x, units[i].pos.y, love.math.random(5, 59), love.math.random(5, 59))
            if goals[i] then units[i]:move(goals[i]) end
        end
    end
end

function Game:mousereleased()
    -- if a tile was clicked, move the unit to it
    if tx ~= 0 and ty ~= 0 then
        unit:fixPosition()
        local path, closed = pathf.findPath(unit.pos.x, unit.pos.y, tx, ty)
        closedList = closed
        if path then
            unit:move(path)
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
    if drawClosed and closedList then
        for i = 1, #closedList do
            love.graphics.setColor(255, 0, 0, 180)
            love.graphics.rectangle("line", closedList[i].x * 32 - 32, closedList[i].y * 32 - 32, 32, 32)
        end
        love.graphics.setColor(255, 255, 255, 255)
    end
    if drawMousePos then love.graphics.rectangle("line", tx * 32 - 32, ty * 32 - 32, 32, 32) end
    camera:detach()
end

return Game
