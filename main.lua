Gamestate = require("hump.gamestate")
Utils = require("lib.Utils")
local Events = require("lib.Events")
Menu = require("states.Menu")
Game = require("states.Game")

Timer = require("hump.timer")
flux = require("lib.flux")
Tween = require("lib.Tween")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineWidth(3)
    _G.events = Events(false)

    Gamestate.registerEvents()
    Gamestate.switch(Menu)
end

function love.update(dt)
    if not love.window.hasMouseFocus() then return end
    Timer.update(dt)
    flux.update(dt)
    Tween.update(dt)

end

function love.draw()

end
