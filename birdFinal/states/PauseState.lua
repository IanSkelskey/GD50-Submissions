--[[
    PauseState Class
    Author: Ian Skelskey
    iskelske@asu.edu

    The PauseState class offers a break for marathon players. Pauses all game animation and mutes music.
]]

PauseState = Class{__includes = BaseState}

require 'states/PlayState'

function PauseState:init()
    fromStart = false
    
    sounds['music']:setVolume(0.5)
end

function PauseState:update(dt)
     if love.keyboard.wasPressed('p') then
        sounds['pause']:stop()
        sounds['pause']:play()
        gStateMachine:change('countdown')
    end

end

function PauseState:render()
    for k, pair in pairs(pipePairs) do
        pair:render()
    end
    bird:render()
    love.graphics.setColor( 0.2, 0.2, 0.2, .35 )
    love.graphics.rectangle( "fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor( 1, 1, 1, 1 )
    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(score), 8, 8)
    love.graphics.printf('PAUSE', 0, VIRTUAL_HEIGHT/2 - 32 , VIRTUAL_WIDTH, 'center')  

end

function PauseState:enter()
    sounds['pause']:play()
    -- if we're coming from death, restart scrolling
    scrolling = false
end

--[[
    Called when this state changes to another state.
]]
function PauseState:exit()
    sounds['music']:setVolume(1)
    -- stop scrolling for the death/score screen
    scrolling = true
    
end