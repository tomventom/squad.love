local Class = require("hump.class")
local Node = require("lib.Node")

local Pathfinder = Class{}

local w = 0
local h = 0
local tiles = nil

function Pathfinder:init(tilemap, width, height)
    w = width
    h = height
    tiles = tilemap:getTileGrid()
end

local function isGoal(x, y, tx, ty)
    return x == tx and y == ty
end

local function heuristic(nx, ny, gx, gy)
    dx = math.abs(nx - gx)
    dy = math.abs(ny - gy)
    if nx ~= gx and ny ~= gy then
        return (dx + dy) + (dx + dy) * 0.001
    else
        return (dx + dy)
    end

end

local function chebyshev(nx, ny, gx, gy)
    dx = math.abs(nx - gx)
    dy = math.abs(ny - gy)
    return 1 * (dx + dy) + (1.4 - 2 * 1) * math.min(dx, dy)
end

local function contains(t, node)
    for k,v in pairs(t) do
        if v.x == node.x and v.y == node.y then return true end
    end
    return false
end

local function constructPath(target, discardTarget)
    local path = {}

    if target.parent then
        local i = 1
        path[1] = target.parent
        while path[i].parent do
            path[i + 1] = path[i].parent
            i = i + 1
        end
        if not discardTarget then
            table.insert(path, 1, target)
        end
        table.remove(path, #path)
        Utils.reverse(path)
    end
    for i = 1, #path do
        print(i, path[i].x, path[i].y)
    end
    return path
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
        table.insert(closed, q)
        if not q then return end
        if q.x == tx and q.y == ty then print("path found") return end

        local neighbours = {}

        -- This is the 4-way version
        -- if q.x > 1 then
        --     local node = Node(q.x - 1, q.y)
        --     node.parent = q
        --     table.insert(neighbours, node)
        -- end
        --
        -- if q.x < w then
        --     local node = Node(q.x + 1, q.y)
        --     node.parent = q
        --     table.insert(neighbours, node)
        -- end
        -- if q.y > 1 then
        --     local node = Node(q.x, q.y - 1)
        --     node.parent = q
        --     table.insert(neighbours, node)
        -- end
        -- if q.y < h then
        --     local node = Node(q.x, q.y + 1)
        --     node.parent = q
        --     table.insert(neighbours, node)
        -- end

        -- this is the 8-way version. allows diagonal movement
        -- try left
        if q.x > 1 then
            local node = Node(q.x - 1, q.y)
            node.parent = q
            table.insert(neighbours, node)
            if q.y > 1 then
                local node = Node(q.x - 1, q.y - 1)
                node.parent = q
                table.insert(neighbours, node)
            end
            if q.y < h then
                local node = Node(q.x - 1, q.y + 1)
                node.parent = q
                table.insert(neighbours, node)
            end
        end

        -- try right
        if q.x < w then
            local node = Node(q.x + 1, q.y)
            node.parent = q
            table.insert(neighbours, node)
            if q.y > 1 then
                local node = Node(q.x + 1, q.y - 1)
                node.parent = q
                table.insert(neighbours, node)
            end
            if q.y < h then
                local node = Node(q.x + 1, q.y + 1)
                node.parent = q
                table.insert(neighbours, node)
            end
        end

        -- try straight up and down
        if q.y > 1 then
            local node = Node(q.x, q.y - 1)
            node.parent = q
            table.insert(neighbours, node)
        end
        if q.y < h then
            local node = Node(q.x, q.y + 1)
            node.parent = q
            table.insert(neighbours, node)
        end


        for k, v in pairs(neighbours) do
            if isGoal(v.x, v.y, tx, ty) then
                print("path found")
                if tiles[tx * h + ty-1].walkable then
                    return constructPath(v, false)
                else
                    return constructPath(v, true)
                end
            end
            v.g = tiles[v.x * h + v.y-1].moveCost + v.parent.g
            v.h = heuristic(v.x, v.y, tx, ty)
            v.f = v.g + v.h

            if not contains(closed, v) then
                if not contains(open, v) then
                    table.insert(open, v)
                else
                    if q.g+1 < v.g then
                        v.parent = q
                    end
                end
            end
        end
    end
    -- end while
    print("no path")
    return nil
end
-- if q.x < w then table.insert(q, Node(q.x+1, q.y)) end
-- if isGoal(q.x-1, q.y, tx, ty) then break end



return Pathfinder