function Board:checkPotential()
    local potentialScore = 0

    -- looking for horizontal pairs with match potential
	for y = 1, 8 do
        --since we're peeking to the right of tiles no need to check last column
        for x = 1, 7 do
            local hasPotential = false
            tile = self.tiles[y][x]
		    if tile.color == self.tiles[tile.gridY][tile.gridX + 1].color then
			    -- Found a horizontal pair
				if tile:topEdge() then
					if tile:leftEdge() then
						if self.tiles[tile.gridY][tile.gridX + 3].color == tile.color or self.tiles[tile.gridY + 1][tile.gridX + 2] == tile.color then
							hasPotential = true
						end
					elseif tile:rightEdge() then
						if self.tiles[tile.gridY][tile.gridX - 2].color == tile.color or self.tiles[tile.gridY + 1][tile.gridX - 1] == tile.color then
							hasPotential = true
						end
					else
						if self.tiles[tile.gridY][tile.gridX + 3].color == tile.color or self.tiles[tile.gridY + 1][tile.gridX + 2] == tile.color or self.tiles[tile.gridY][tile.gridX - 2].color == tile.color or self.tiles[tile.gridY + 1][tile.gridX - 1] == tile.color then
						hasPotential = true
					end
				elseif tile:botEdge() then
					if tile:leftEdge() then
						if self.tiles[tile.gridY - 1][tile.gridX + 2].color == tile.color or self.tiles[tile.gridY][tile.gridX + 3] == tile.color then
							hasPotential = true
						end
					elseif tile:rightEdge() then
						if self.tiles[tile.gridY - 1][tile.gridX - 1].color == tile.color or self.tiles[tile.gridY][tile.gridX - 2] == tile.color then
							hasPotential = true
						end
					else
						if self.tiles[tile.gridY - 1][tile.gridX + 2].color == tile.color or self.tiles[tile.gridY][tile.gridX + 3] == tile.color or self.tiles[tile.gridY - 1][tile.gridX - 1].color == tile.color or self.tiles[tile.gridY][tile.gridX - 2] == tile.color then
							hasPotential = true
						end
					end
				elseif tile:leftEdge() then
					if self.tiles[tile.gridY][tile.gridX + 3].color == tile.color or self.tiles[tile.gridY + 1][tile.gridX + 2] == tile.color or self.tiles[tile.gridY - 1][tile.gridX + 2].color == tile.color then
						hasPotential = true
					end
				elseif tile:rightEdge() then
					if self.tiles[tile.gridY - 1][tile.gridX - 1].color == tile.color or self.tiles[tile.gridY][tile.gridX - 2] == tile.color or self.tiles[tile.gridY + 1][tile.gridX - 1] == tile.color then
						hasPotential = true
					end
				else
				    if self.tiles[tile.gridY][tile.gridX - 2].color == tile.color or self.tiles[tile.gridY - 1][tile.gridX - 1].color == tile.color or 
							self.tiles[tile.gridY + 1][tile.gridX - 1].color == tile.color or self.tiles[tile.gridY][tile.gridX + 3].color == tile.color or 
									self.tiles[tile.gridY - 1][tile.gridX + 2].color == tile.color or self.tiles[tile.gridY + 1][tile.gridX + 2].color == tile.color then
					    hasPotential = true
				    end
			    end
				potentialScore = potentialScore + 1
		    end
        end
	end

	return potentialScore
end