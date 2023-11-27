--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]] GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['pot'] = {
       type = 'pot',
       texture = 'tiles',
       frame = 110,
       width = 16,
       height = 16,
       solid = true,
       defaultState = 'idle',
       states = {
           ['idle'] = {
               frame = 110
           },
           ['broken'] = {
               frame = 111
           }
       }
    },
    ['heart'] = {
        type = 'heart',
        texture = 'hearts',
        frame = 1,
        width = 16,
        height = 16,
        solid = false,
    },
    ['heart-drop'] = {
        type = 'heart-drop',
        texture = 'heart-drop',
        frame = 1,
        width = 16,
        height = 16,
        solid = false,
        consumable = true,
        onConsume = function(player, object)
            gSounds['heart-pickup']:play()
            player.health = math.min(player.health + 2, 6)
        end,
        defaultState = 'uncollected',
        states = {
            ['uncollected'] = {
                frame = 1
            },
            ['collected'] = {
                frame = 1
            },
        }
    }
}
