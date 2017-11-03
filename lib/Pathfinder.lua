local Class = require("lib.Class")
local Node = require("lib.Node")

local Pathfinder = Class:derive("Pathfinder")

local min, abs = math.min, math.abs
local sqrt2 = math.sqrt(2)
local w = 0
local h = 0

function Pathfinder:new(tilemap, width, height)
    w = width
    h = height
    self.tiles = tilemap:getTileGrid()
end

local function isGoal(x, y, tx, ty)
    return x == tx and y == ty
end

local function isDiagonal(nx, ny, gx, gy)
    return nx ~= gx and ny ~= gy
end

-- good heuristic
local function heuristic(nx, ny, gx, gy)
    local dx = abs(nx - gx)
    local dy = abs(ny - gy)
    return 1 * (dx + dy) + (sqrt2 - 2 * 1) * min(dx, dy)
end

local function contains(t, node)
    for i = 1, #t do
        if t[i].x == node.x and t[i].y == node.y then return true end
    end
    return false
end

local function constructPath(target, discardTarget, closedList)
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
        else
            if #path == 1 then
                return
            end
        end
        table.remove(path, #path)
        Utils.reverse(path)
    end
    return path, closedList
end

local function getNeighbours(q)
    local neighbours = {}
    local tryLeft = false
    -- try left
    if q.x > 1 then
        tryLeft = true
        local node = Node(q.x - 1, q.y)
        node.parent = q
        table.insert(neighbours, node)
    end

    local tryRight = false
    -- try right
    if q.x < w then
        tryRight = true
        local node = Node(q.x + 1, q.y)
        node.parent = q
        table.insert(neighbours, node)
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

    -- diagonal left
    if tryLeft then
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

    -- diagonal right
    if tryRight then
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
    return neighbours
end

function Pathfinder:findPath(sx, sy, tx, ty, blockedTile)
    local blocked = blockedTile
    if not blocked then print("null") else print("yes") end
    if not self.tiles[tx * h + ty - 1].walkable then
        local ns = getNeighbours(Node(tx, ty))
        local surrounded = true
        for k, v in pairs(ns) do
            if self.tiles[v.x * h + v.y - 1].walkable then surrounded = false end
        end
        if surrounded == true then return end
    end

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
        if #closed >= 1600 then print("ERROR: took too long to compute path") return end
        if not q then print("no path") return end
        if q.x == tx and q.y == ty then print("already on source tile") return end

        local neighbours = getNeighbours(q)
        for k, v in pairs(neighbours) do
            if isGoal(v.x, v.y, tx, ty) then
                if self.tiles[tx * h + ty - 1].walkable then
                    return constructPath(v, false, closed)
                else
                    return constructPath(v, true, closed)
                end
            end
            v.g = self.tiles[v.x * h + v.y - 1].moveCost + v.parent.g
            v.h = heuristic(v.x, v.y, tx, ty)
            v.f = v.g + v.h
            v.cost = self.tiles[v.x * h + v.y - 1].moveCost
            if blocked then if v.x == blocked.x and v.y == blocked.y then table.insert(closed, v) end end
            if not contains(closed, v) then
                if not contains(open, v) then
                    table.insert(open, v)
                else
                    if q.g + 1 < v.g then
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
