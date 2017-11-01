local Class = require("lib.Class")
local TileType = require("lib.TileType")
local Tilemap = Class:derive("Tilemap")

local function clone(t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

local function stringToTileType(self, string)
    if string == "grass" then
        return self.grassTile
    elseif string == "swamp" then
        return self.swampTile
    elseif string == "water" then
        return self.waterTile
    elseif string == "sand" then
        return self.sandTile
    end

end

function Tilemap:new(sizeX, sizeY)
    -- initialize tiles with a name and sprite index from Quads table
    self.grassTile = TileType("grass", 1, 1)
    self.sandTile = TileType("sand", 5, 1)
    self.swampTile = TileType("swamp", 2, 4)
    self.waterTile = TileType("water", 3, math.huge, false)
    self.empty = TileType("empty", 99, 0)
    self.tree = TileType("tree", 6, math.huge, false)

    -- create the tile array and set all to grass
    self.tiles = {}
    self.sizeX = sizeX
    self.sizeY = sizeY
    local curr
    local index = 1
    for line in io.lines("maps/demo.csv") do
        curr = Utils.ParseCSVLine(line)

        for x = 1, sizeX do
            self.tiles[x * sizeY + index - 1] = stringToTileType(self, curr[x])
        end
        index = index + 1
    end

    self.objLayer = {}
    for x = 1, sizeX do
        for y = 1, sizeY do
            self.objLayer[x * sizeY + y - 1] = self.empty
        end
    end

    for x = 20, 26 do
        for y = 15, 17 do
            self.objLayer[x * sizeY + y - 1] = self.tree
        end
    end
end

-- set tile at x, y to given type
function Tilemap:setTile(x, y, type)
    -- TODO: check if tiles[x * sizeY + y-1] exists
    self.tiles[x * sizeY + y - 1] = type
end

-- return the tile at given WORLD coordinates
function Tilemap:getTile(mx, my)
    local tx = math.ceil(mx / 32)
    local ty = math.ceil(my / 32)
    -- self.tiles[tx][ty]
    if tx >= 1 and tx <= self.sizeX and ty >= 1 and ty <= self.sizeY then
        return tx, ty
    else
        return 0, 0
    end
end

-- return walkable value of tile at given TILEMAP coordinates
function Tilemap:isTileWalkable(tx, ty)
    if tx >= 1 and tx <= self.sizeX and ty >= 1 and ty <= self.sizeY then
        return self.tiles[tx * self.sizeY + ty - 1].walkable
    end
end

function Tilemap:getTileGrid()
    local copy = clone(self.tiles)

    for x = 1, self.sizeX do
        for y = 1, self.sizeY do
            copy[x * self.sizeY + y - 1].moveCost = copy[x * self.sizeY + y - 1].moveCost + self.objLayer[x * self.sizeY + y - 1].moveCost
        end
    end

    if copy then return copy end
end



function Tilemap:draw()
    for x = 1, self.sizeX do
        for y = 1, self.sizeY do
            love.graphics.draw(Tileset, self.tiles[x * self.sizeY + y - 1].sprite, x * 32 - 32, y * 32 - 32)
        end
    end
    for x = 1, self.sizeX do
        for y = self.sizeY, 1, - 1 do
            love.graphics.draw(Tileset, self.objLayer[x * self.sizeY + y - 1].sprite, x * 32 - 32, y * 32 - 64)
        end
    end
end

return Tilemap
