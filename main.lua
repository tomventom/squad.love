Gamestate = require "hump.gamestate"

Menu = require("states.Menu")
Game = require("states.Game")

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Menu)
end

function love.update(dt)

end

function love.draw()

end
