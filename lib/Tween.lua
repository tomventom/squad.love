local T = {}

local activeTweens = {}

-- Easing funcs

function T.create(target, propName, to, duration)
    assert(type(target) == "table", "target parameter must be a table!")
    assert(type(propName) == "string", "propName parameter must be a string!")

    local t = 0
    local from = target[propName]
    local diff = to - from
    local update = function(dt)
        if t >= duration then
            target[propName] = to
            return true
        end


        target[propName] = from + diff * ((t / duration)*(t / duration))

        t = t + dt
        return false
    end
    activeTweens[#activeTweens+1] = update
end

function T.update(dt)
    for i = #activeTweens, 1, -1 do
        -- TODO: if the tween has an onComplete callback, call it
        if activeTweens[i](dt) then table.remove(activeTweens, i) end
    end
end

return T
