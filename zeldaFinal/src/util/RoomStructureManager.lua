RoomStructureManager = Class {}

function RoomStructureManager:init(room)
    self.room = room
    self.tiles = {}
    self.doorways = {}
    self:generateWallsAndFloors()
    self:generateDoorways()
end

function RoomStructureManager:renderDoors()
    for _, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end
end

function RoomStructureManager:renderTiles()
    for y = 1, self.room.height do
        for x = 1, self.room.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX,
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end
end


function RoomStructureManager:generateWallsAndFloors()
    -- Your existing logic for generating walls and floors
    -- Populate self.tiles
    for y = 1, self.room.height do
        table.insert(self.tiles, {})

        for x = 1, self.room.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.room.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.room.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.room.width and y == self.room.height then
                id = TILE_BOTTOM_RIGHT_CORNER

                -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.room.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.room.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end

            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

function RoomStructureManager:generateDoorways()
    function Room:generateDoorways()
        local directions = {'top', 'bottom', 'left', 'right'}
        for _, dir in pairs(directions) do
            table.insert(self.doorways, Doorway(dir, false, self))
        end
    end
end

function RoomStructureManager:render()
    self:renderTiles()
    self:renderDoors()
end
