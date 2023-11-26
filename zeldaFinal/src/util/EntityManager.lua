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
    self:checkPlayerObjectCollision()
end

function EntityManager:updateEntity(entity, dt, index)
    -- Check if the entity's health is zero and it's not already marked as dead
    if entity.health <= 0 and not entity.dead then
        -- Mark the entity as dead
        entity.dead = true

        -- Heart drop logic
        local CHANCE_TO_DROP_HEART = 0.5 -- 50% chance to drop a heart
        if math.random() < CHANCE_TO_DROP_HEART then
            local heart = GameObject(GAME_OBJECT_DEFS['heart-drop'], math.ceil(entity.x), math.ceil(entity.y))
            table.insert(self.room.objects, heart) -- Add heart to the room objects
            gSounds['heart-reveal']:play()
            print("Heart object right after creation:")
            print_r(heart)
        end
    elseif not entity.dead then
        -- Process AI and update entity if it's not dead
        entity:processAI({
            room = self.room
        }, dt)
        entity:update(dt)
    end

    -- Check collision with the player
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

function EntityManager:checkPlayerObjectCollision()
    -- New logic for checking collision with consumable objects like hearts
    for i = #self.room.objects, 1, -1 do
        local object = self.room.objects[i]
        if object.type == 'heart-drop' and self.room.player:collides(object) then
            gSounds['heart-pickup']:play()
            print("heart object right before onConsume:")
            print_r(object)
            object.onConsume(self.room.player, object) -- Consume the heart
            table.remove(self.room.objects, i) -- Remove the heart
            break -- Assuming only one heart can be consumed at a time
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
