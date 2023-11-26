-- EntityManager.lua
EntityManager = Class {}

function EntityManager:init(room)
    self.room = room
    self.entities = {}
    self:generateEntities()
end

function EntityManager:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}
    for i = 1, 10 do
        local type = types[math.random(#types)]
        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE, VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),
            width = 16,
            height = 16,
            health = 1
        })

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function()
                return EntityWalkState(self.entities[i])
            end,
            ['idle'] = function()
                return EntityIdleState(self.entities[i])
            end
        }

        self.entities[i]:changeState('walk')
    end
end

function EntityManager:update(dt)
    for i, entity in ipairs(self.entities) do
        self:updateEntity(entity, dt, i)
    end
end

function EntityManager:updateEntity(entity, dt, index)
    if entity.health <= 0 then
        entity.dead = true
        -- Heart drop logic
        local CHANCE_TO_DROP_HEART = 0.5 -- 50% chance to drop a heart
        if math.random() < CHANCE_TO_DROP_HEART then
            local heart = GameObject(GAME_OBJECT_DEFS['heart-drop'], entity.x, entity.y)
            table.insert(self.room.objects, heart) -- Add heart to the room objects
        end
    elseif not entity.dead then
        entity:processAI({
            room = self.room
        }, dt)
        entity:update(dt)
    end
    self:checkPlayerEntityCollision(entity)
end

function EntityManager:checkPlayerEntityCollision(entity)
    if not entity.dead and self.room.player:collides(entity) and not self.room.player.invulnerable then
        gSounds['hit-player']:play()
        self.room.player:damage(1)
        self.room.player:goInvulnerable(1.5)

        if self.room.player.health == 0 then
            gStateMachine:change('game-over')
        end
    end
end

function EntityManager:render()
    for k, entity in pairs(self.entities) do
        if not entity.dead then
            entity:render(self.room.adjacentOffsetX, self.room.adjacentOffsetY)
        end
    end
end
