Bush = Class{__includes = GameObject}

function Bush:init(x, y)
    GameObject.init(self, {
        x = x,
        y = y,
        texture = 'bushes',
        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
        width = 16,
        height = 16,
        consumable = false,
        solid = false,
        collidable = false,
    })
end