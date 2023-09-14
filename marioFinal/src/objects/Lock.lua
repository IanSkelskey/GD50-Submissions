Lock = Class{__includes = GameObject}

function Lock:init(x, y, color, eventManager)
    local function onConsume(player, object)
        gSounds['pickup']:play()
        player.score = player.score + 100
        player.key = nil
        eventManager:emit('unlock', color)
    end

    GameObject.init(self, {
        x = x,
        y = y,
        texture = 'keys-and-locks',
        frame = LOCKS[color],
        width = 16,
        height = 16,
        solid = true,
        consumable = false,
        onConsume = onConsume,
        collidable = true,
        onCollide = function(obj)
                gSounds['empty-block']:play()
        end

    })
end