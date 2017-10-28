local Menu = {}

function Menu:init()

end

function Menu:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "return" then
        Gamestate.switch(Game)
    end
end

function Menu:draw()
    love.graphics.clear(155, 205, 255)
end

return Menu
