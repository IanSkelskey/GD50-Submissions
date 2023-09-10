Gem = Class{__includes = GameObject}

function Gem:init(x, y)
    GameObject.init(self, {
        x = x,
        y = y,
        texture = 'gems',
        frame = math.random(#GEMS),
        width = 16,
        height = 16,
        consumable = true,
        solid = false,
        collidable = true,
        onConsume = function(player, object)
            gSounds['pickup']:play()
            player.score = player.score + 100
        end
    })
end