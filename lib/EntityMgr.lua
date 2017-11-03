local Class = require("lib.Class")

local EM = Class:derive("EntityMgr")

-- check whether the given list contains a given item/entity
local function contains(list, item)
    for v in pairs(list) do
        if v == item then return true end
    end
    return false
end

local function layerCompare(e1, e2)
    return e1.layer < e2.layer
end

function EM:new()
    self.entities = {}
end

function EM:add(entity)
    if contains(self.entities, entity) then return end

    -- add additional table entries that need to exist in all entities
    entity.layer = entity.layer or 1
    entity.started = entity.started or false
    entity.enabled = (entity.enabled == nil) or entity.enabled
    self.entities[#self.entities + 1] = entity

    -- TODO: sort the entities by layer
    table.sort(self.entities, layerCompare)
end

function EM:onEnter()
    for i = #self.entities, 1, -1 do
        local e = self.entities[i]
        if e.onEnter then e:onEnter() end
    end
end

function EM:onExit()
    for i = 1, #self.entities do
        local e = self.entities[i]
        if e.onExit then e:onExit() end
    end
end

function EM:update(dt)
    for i = #self.entities, 1, -1 do
        local e = self.entities[i]

        -- if the entity requests removal then remove it
        if e.remove == true then
            e.remove = false
            if e.onRemove then e:onRemove() end
            table.remove(self.entities, i)
        end

        if e.enabled then
            if not e.started then
                e.started = true
                if e.onStart then e:onStart() end
            else
                e:update(dt)
            end
        end
    end
end

function EM:draw()
    for i = 1, #self.entities do
        if self.entities[i].enabled then
            self.entities[i]:draw()
        end
    end
end

return EM
