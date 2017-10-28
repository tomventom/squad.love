local Class = require("hump.class")
local TileType = require("TileType")

local Tilemap = Class{}



function Tilemap:init(sizeX, sizeY)
    self.grassTile = TileType("grass", 1)
    self.swampTile = TileType("swamp", 2)
    self.waterTile = TileType("water", 3)

    self.tiles = {}
    self.sizeX = sizeX
    self.sizeY = sizeY
    for x = 1, sizeX do
        self.tiles[x] = {}
        for y = 1, sizeY do
            self.tiles[x][y] = self.grassTile
        end
    end

    -- swamp
    for x = 3, 5 do
        for y = 7, 10 do
            self.tiles[x][y] = self.swampTile
        end
    end

    -- U shaped water
    self.tiles[4][4] = self.waterTile
    self.tiles[5][4] = self.waterTile
    self.tiles[6][4] = self.waterTile
    self.tiles[7][4] = self.waterTile
    self.tiles[8][4] = self.waterTile
    self.tiles[4][5] = self.waterTile
    self.tiles[4][6] = self.waterTile
    self.tiles[8][5] = self.waterTile
    self.tiles[8][6] = self.waterTile

end

function Tilemap:setTile(x, y, type)
    self.tiles[x][y] = type
end

function Tilemap:draw()
    for x = 1, self.sizeX do
        for y = 1, self.sizeY do
            love.graphics.draw(Tileset, self.tiles[x][y].sprite, x * 32 - 32, y * 32 - 32)
        end
    end
end

return Tilemap
