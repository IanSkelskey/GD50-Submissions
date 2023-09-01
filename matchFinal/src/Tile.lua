--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]] Tile = Class {}

function Tile:init(x, y, color, variety)
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.shiny = math.random(1, 20) == 1 and true or false
end

function Tile:update(dt)

end

--[[
    Function to swap this tile with another tile, tweening the two's positions.
]]
function Tile:swap(tile)

end

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety], self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety], self.x + x, self.y + y)

    -- draw shiny effect
    if self.shiny then
        -- Use 'add' blend mode to make it more visible
        love.graphics.setBlendMode('add')
        -- This changes the color to a light yellow
        love.graphics.setColor(1, 1, 1, 1)
        local alpha = 96 + math.sin(love.timer.getTime() * 4) * 64
        love.graphics.setColor(1, 1, 1, alpha/255)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety], self.x + x, self.y + y)
    
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(1, 1, 1, 1)
    end
end
