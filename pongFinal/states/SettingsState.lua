SettingsState = Class{__includes = BaseState}

function SettingsState:init()
    selection1 = 1
    selection2 = 1

    prevX1 = player1.x
    prevY1 = player1.y
    prevX2 = player2.x
    prevY2 = player2.y

    player1.x = VIRTUAL_WIDTH/4
    player1.y = VIRTUAL_HEIGHT/2 - player1.height
    player2.x = 3*VIRTUAL_WIDTH/4
    player2.y = VIRTUAL_HEIGHT/2 - player2.height
end

function SettingsState:update(dt)
    
    if love.keyboard.wasPressed('left') then
        if selection1 == 1 then
            selection1 = 4
        else
            selection1 = selection1 - 1
        end
    elseif love.keyboard.wasPressed('right') then
        if selection1 == 4 then
            selection1 = 1
        else
            selection1 = selection1 + 1
        end
    end

    if love.keyboard.wasPressed('a') then
        if selection2 == 1 then
            selection2 = 4
        else
            selection2 = selection2 - 1
        end
    elseif love.keyboard.wasPressed('d') then
        if selection2 == 4 then
            selection2 = 1
        else
            selection2 = selection2 + 1
        end
    end

    if selection2 == 1 then
        player1.color = 'white'
    elseif selection2 == 2 then
        player1.color = 'red'
    elseif selection2 == 3 then
        player1.color = 'green'
    elseif selection2 == 4 then
        player1.color = 'blue'
    end

    if selection1 == 1 then
        player2.color = 'white'
    elseif selection1 == 2 then
        player2.color = 'red'
    elseif selection1 == 3 then
        player2.color = 'green'
    elseif selection1 == 4 then
        player2.color = 'blue'
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('title')
    end
end

function SettingsState:render()
	-- UI messages
    love.graphics.setFont(scoreFont)
    love.graphics.printf('Settings', 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf('Choose your paddle color!', 0, 10, VIRTUAL_WIDTH, 'center')

    --Paddle Choices
    love.graphics.printf('>>', VIRTUAL_WIDTH/4 - 10, VIRTUAL_HEIGHT/2 - player1.height/2, VIRTUAL_WIDTH, 'left')

    player1:render()
    player2:render()
end

function SettingsState:exit()
    player1.x = prevX1
    player1.y = prevY1
    player2.x = prevX2
    player2.y = prevY2
end