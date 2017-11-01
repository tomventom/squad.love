Gamestate = require("hump.gamestate")
Utils = require("lib.Utils")

Menu = require("states.Menu")
Game = require("states.Game")

flux = require("lib.flux")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end

function love.update(dt)
    flux.update(dt)
end

function love.draw()

end
