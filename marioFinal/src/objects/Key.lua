Key = Class{__includes = GameObject}

function Key:init(x, y, color)
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
        onConsume = function(player, object)
            gSounds['pickup']:play()
            player.score = player.score + 100
            player.hasKey = true
        end
    })
end