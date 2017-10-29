local Class = require "hump.class"

local Pathfinder = Class{}

local w = 0
local h = 0

function Pathfinder:init()
    self.tiles = {}

end

function Pathfinder:setTilemap(tilemap, w, h)
    self.tiles = tilemap:getTileGrid()
    w = w
    h = h
end

function Pathfinder.findPath(sx, sy, tx, ty)

    local open = {}
    local closed = {}
    table.insert(open, Node(sx, sy))

    while #open > 0 do
        local q
        local index
        minF = math.huge
        for i = 1, #open do
            if open[i].f < minF then
                minF = open[i].f
                q = open[i]
                index = i
            end
        end
        table.remove(open, index)


        if q.x == tx and q.y == ty then break end

        local neighbours = {}

        if q.x > 1 then
            local node = Node(q.x-1, q.y)
            node.parent = q
            table.insert(neighbours, node)
        end

        if q.x < w then
            local node = Node(q.x+1, q.y)
            node.parent = q
            table.insert(neighbours, node)
        end
        if q.y > 1 then
            local node = Node(q.x, q.y-1)
            node.parent = q
            table.insert(neighbours, node)
        end
        if q.y < h then
            local node = Node(q.x, q.y+1)
            node.parent = q
            table.insert(neighbours, node)
        end

    end

end
-- if q.x < w then table.insert(q, Node(q.x+1, q.y)) end
-- if isGoal(q.x-1, q.y, tx, ty) then break end

local function isGoal(x, y, tx, ty)
    return x == tx and y == ty
end

return Pathfinder
