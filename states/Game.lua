local Game = {}

local Camera = require("hump.camera")
local Tilemap = require("lib.Tilemap")
local Unit = require("lib.Unit")
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

local tmap = Tilemap(64, 64)
local pathf = Pathfinder(tmap, 64, 64)
local mx, my = 0,0
local tx, ty = 0,0
local drawMousePos = false

-- initialize the map, unit and camera
function Game:init()
    unit = Unit(5, 5)
    camera = Camera(256, 192)
end

function Game:update(dt)
    unit:update(dt)
    camera:lockPosition(unit.pos.x * 32 - 32, unit.pos.y * 32 - 32, Camera.smooth.damped(4))
    -- get the mouse position in world coordinates
    mx, my = camera:worldCoords(love.mouse.getPosition())
    tx, ty = tmap:getTile(mx, my)

    drawMousePos = tx ~= 0 and ty ~= 0
end

function Game:keypressed(key)
    if key == "escape" then
        -- Gamestate.switch(Menu)
        love.event.quit()
    end
end

function Game:mousereleased()
    -- if a tile was clicked, move the unit to it
    if tx ~= 0 and ty ~= 0 then
        unit:fixPosition()
        local path = pathf.findPath(unit.pos.x, unit.pos.y, tx, ty)
        if path then
            unit:move(path)
        end
    end
end

function Game:draw()
    love.graphics.clear(200, 200, 200)
    camera:attach()
    tmap:draw()
    unit:draw()
    if drawMousePos then love.graphics.rectangle("line", tx * 32 - 32, ty * 32 - 32, 32, 32) end
    camera:detach()
end

return Game
