local Class = require("lib.Class")
local TileType = require("lib.TileType")
local Tilemap = Class:derive("Tilemap")

local function stringToTileType(self, string)
    if string == "grass" then
        return self.grassTile
    elseif string == "empty" then
        return self.empty
    elseif string == "tree" then
        return self.tree
    elseif string == "swamp" then
        return self.swampTile
    elseif string == "water" then
        return self.waterTile
    elseif string == "sand" then
        return self.sandTile
    end

end

function Tilemap:new(sizeX, sizeY, mapImage)
    self.mapImage = mapImage
    -- initialize tiles with a name and sprite index from Quads table
    self.grassTile = TileType("grass", 1, 1)
    self.sandTile = TileType("sand", 5, 1)
    self.swampTile = TileType("swamp", 2, 2)
    self.waterTile = TileType("water", 3, math.huge, false)
    self.empty = TileType("empty", 99, 0)
    self.tree = TileType("tree", 6, math.huge, false)

    -- TODO: Have a Cost Map instead of a tilemap
    -- TODO: Draw objects seperately
    -- create the tile array and set all to grass
    self.tiles = {}
    self.objLayer = {}
    self.sizeX = sizeX
    self.sizeY = sizeY
    local curr
    local index = 1
    for line in io.lines("maps/ambush1_tileLayer.csv") do
        curr = Utils.ParseCSVLine(line)

        for x = 1, sizeX do
            self.tiles[x * sizeY + index - 1] = stringToTileType(self, curr[x])
        end
        index = index + 1
    end
    index = 1
    for line in io.lines("maps/ambush1_objLayer.csv") do
        curr = Utils.ParseCSVLine(line)

        for x = 1, sizeX do
            self.objLayer[x * sizeY + index - 1] = stringToTileType(self, curr[x])
        end
        index = index + 1
    end

end

-- set tile at x, y to given type
function Tilemap:setTile(x, y, type)
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
    local copy = Utils.clone(self.tiles)
    for x = 1, self.sizeX do
        for y = 1, self.sizeY do
            copy[x * self.sizeY + y - 1].moveCost = copy[x * self.sizeY + y - 1].moveCost + self.objLayer[x * self.sizeY + y - 1].moveCost
            if not self.objLayer[x * self.sizeY + y - 1].walkable then copy[x * self.sizeY + y - 1].walkable = false end
        end
    end

    if copy then return copy end
end



function Tilemap:draw()
    -- for x = 1, self.sizeX do
    --     for y = 1, self.sizeY do
    --         love.graphics.draw(Tileset, self.tiles[x * self.sizeY + y - 1].sprite, x * 32 - 32, y * 32 - 32)
    --     end
    -- end
    love.graphics.draw(self.mapImage, 0, 0)
    for x = 1, self.sizeX do
        for y = self.sizeY, 1, - 1 do
            love.graphics.draw(Tileset, self.objLayer[x * self.sizeY + y - 1].sprite, x * 32 - 32, y * 32 - 64)
        end
    end
end

return Tilemap
