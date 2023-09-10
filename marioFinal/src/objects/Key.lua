Key = Class{__includes = GameObject}

function Key:init(x, y, color, eventManager)
    local function onConsume(player, object)
        eventManager:emit('keyConsume', color)
        gSounds['pickup']:play()
        player.score = player.score + 100
        player.key = self
    end

    GameObject.init(self, {
        x = x,
        y = y,
        texture = 'keys-and-locks',
        frame = KEYS[color],
        width = 16,
        height = 16,
        consumable = true,
        solid = false,
        collidable = true,
        onConsume = onConsume
    })
    self.color = color
end