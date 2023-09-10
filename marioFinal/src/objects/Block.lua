Block = Class {
    __includes = GameObject
}

function Block:init(x, y, reward, eventManager)
    local function onCollide(obj)
        if not obj.hit then
            if self.reward then
                Timer.tween(0.1, {
                    [self.reward] = {
                        y = self.reward.y - 4
                    }
                })
                gSounds['powerup-reveal']:play()
                eventManager:emit('blockHit', self.reward)
            else
                gSounds['empty-block']:play()
            end
        end
        obj.hit = true
    end

    GameObject.init(self, {
        x = x,
        y = y,
        texture = 'jump-blocks',
        frame = math.random(#JUMP_BLOCKS),
        width = 16,
        height = 16,
        solid = true,
        collidable = true,
        hit = false,
        onCollide = onCollide
    })
end
