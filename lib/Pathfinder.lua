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

local function isDiagonal(nx, ny, gx, gy)
    return nx ~= gx and ny ~= gy
end

-- good heuristic
local function heuristic(nx, ny, gx, gy)
    local dx = math.abs(nx - gx)
    local dy = math.abs(ny - gy)
    local h = 1 * (dx + dy) + (1.5 - 2 * 1) * math.min(dx, dy)
    return h + (h * 0.001)
end

-- bad heuristic, not used
local function chebyshev(nx, ny, gx, gy)
    local dx = math.abs(nx - gx)
    local dy = math.abs(ny - gy)
    return 1 * (dx + dy) + (1.4 - 2 * 1) * math.min(dx, dy)
end

local function contains(t, node)
    -- for k,v in pairs(t) do
    --     if v.x == node.x and v.y == node.y then return true end
    -- end
    -- return false
    for i = 1, #t do
        if t[i].x == node.x and t[i].y == node.y then return true end
    end
    return false
end

local function constructPath(target, discardTarget, closedList)
    local path = {}
    local startTime = love.timer.getTime()
    if target.parent then
        local i = 1
        path[1] = target.parent
        while path[i].parent do
            path[i + 1] = path[i].parent
            i = i + 1
        end
        if not discardTarget then
            table.insert(path, 1, target)
        else
            if #path == 1 then
                return
            end
        end
        table.remove(path, #path)
        Utils.reverse(path)
    end
    local endTime = love.timer.getTime()
    print(string.format("ms: %.3f", (endTime - startTime) * 1000000))

    return path, closedList
end

function Pathfinder.findPath(sx, sy, tx, ty)

    if not tiles[tx * h + ty-1].walkable then return end

    local open = {}
    local closed = {}
    table.insert(open, Node(sx, sy))

    while #open > 0 do
        local q
        local index
        local minF = math.huge
        for i = 1, #open do
            if open[i].f < minF then
                minF = open[i].f
                q = open[i]
                index = i
            end
        end
        table.remove(open, index)
        table.insert(closed, q)
        if not q then print("no path") return end
        if q.x == tx and q.y == ty then print("already on source tile") return end

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
                if tiles[tx * h + ty-1].walkable then
                    return constructPath(v, false, closed)
                else
                    return constructPath(v, true, closed)
                end
            end
            v.g = tiles[v.x * h + v.y-1].moveCost + v.parent.g + 1
            if (isDiagonal(q.x, q.y, v.x, v.y)) then v.g = v.g + .501 end
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
    return nil
end
-- if q.x < w then table.insert(q, Node(q.x+1, q.y)) end
-- if isGoal(q.x-1, q.y, tx, ty) then break end



return Pathfinder
