local Game = {}

local Camera = require("hump.camera")
local Tilemap = require("Tilemap")
local Unit = require("Unit")

Tileset = love.graphics.newImage("assets/tileset.png")
local tw = Tileset:getWidth()
local th = Tileset:getHeight()
Quads = {}
Quads[1] = love.graphics.newQuad(0, 0, 32, 32, tw, th) -- grass
Quads[2] = love.graphics.newQuad(32, 0, 32, 32, tw, th) -- swamp
Quads[3] = love.graphics.newQuad(64, 0, 32, 32, tw, th) -- water
Quads[4] = love.graphics.newQuad(96, 0, 32, 32, tw, th) -- unit


function Game:init()
    tmap = Tilemap(15, 10)
    unit = Unit(1, 1)
    camera = Camera(unit.pos.x, unit.pos.y)
end

function Game:update(dt)
    unit:update(dt)
end

function Game:keypressed(key)
    if key == "escape" then
        Gamestate.switch(Menu)
    end
end

function Game:draw()
    love.graphics.clear(200, 200, 200)
    camera:attach()
    tmap:draw()
    unit:draw()
    camera:detach()
end

return Game
