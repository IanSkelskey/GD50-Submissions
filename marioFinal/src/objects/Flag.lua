Flag = Class{__includes = GameObject}

function Flag:init(x, y, color, eventManager)
    
    self.color = color  -- 1, 2, 3, or 4
    self.animation = Animation {
        frames = {1, 2},  -- Assuming the first two frames are for waving
        interval = 0.2
    }
    self.state = 'waving'  -- Initial state

    self.poleFrame = color  -- Directly use the color number as the pole frame

    GameObject.init(self, {
        x = x,
        y = y,
        texture = 'flags',
        frame = self:getFrameForColor(),
        width = 16,
        height = 48,
        consumable = true,
        solid = false,
        collidable = true,
        onConsume = function(player, object)
            gSounds['pickup']:play()
            player.score = player.score + 100
            eventManager:emit('flagConsume', player)
        end
    })
end

function Flag:update(dt)
    self.animation:update(dt)
    self.frame = self.animation:getCurrentFrame() + self:getFrameOffsetForColor()
end

function Flag:render()
    local flagOffsetX = 9  -- The flag is 9 pixels to the right of the pole
    local flagOffsetY = 5  -- The flag is 5 pixels below the pole

    -- Render the pole first
    love.graphics.draw(gTextures['poles'], gFrames['poles'][self.poleFrame], self.x, self.y)

    -- Render the flag
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x + flagOffsetX, self.y + flagOffsetY)
end

function Flag:getFrameForColor()
    return (self.color - 1) * 3 + 1  -- Assuming each color has 3 frames
end

function Flag:getFrameOffsetForColor()
    return (self.color - 1) * 3  -- Assuming each color has 3 frames
end
