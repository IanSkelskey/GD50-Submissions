CustomizationState = Class{__includes = BaseState}

require 'Paddle'
require 'Ball'

function CustomizationState:init()
    row_selection = 1
    col_selection = 1

    round_ball = Ball(VIRTUAL_WIDTH/2 - 20, 85, 4, 4)
    square_ball = Ball(VIRTUAL_WIDTH/2 + 18, 87, 4, 4)
    square_ball.shape = 'circle'

    green_dummy = Paddle(VIRTUAL_WIDTH/2 - 35, 135, 20, 5)
    green_dummy.color = 'green'
    blue_dummy = Paddle(VIRTUAL_WIDTH/2 - 35, 150, 20, 5)
    blue_dummy.color = 'blue'
    red_dummy = Paddle(VIRTUAL_WIDTH/2 - 35, 165, 20, 5)
    red_dummy.color = 'red'

    green_dummy2 = Paddle(VIRTUAL_WIDTH/2 + 15, 135, 20, 5)
    green_dummy2.color = 'green'
    blue_dummy2 = Paddle(VIRTUAL_WIDTH/2 + 15, 150, 20, 5)
    blue_dummy2.color = 'blue'
    red_dummy2 = Paddle(VIRTUAL_WIDTH/2 + 15, 165, 20, 5)
    red_dummy2.color = 'red'

end

function CustomizationState:update(dt)

    if love.keyboard.wasPressed('up') then
        if selection1 == 1 then
            selection1 = 4
        else
            selection1 = selection1 - 1
        end
    elseif love.keyboard.wasPressed('down') then
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


    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
      gStateMachine:change('settings')
    end

    if love.keyboard.wasPressed('backspace') then
      gStateMachine:change('settings')
    end
end

function CustomizationState:render()
	-- UI messages
    love.graphics.setFont(scoreFont)
    love.graphics.printf('Customization', 0, 20, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(smallFont)
    love.graphics.printf('Choose your ball shape!', 0, 65, VIRTUAL_WIDTH, 'center')

    round_ball:render()
    square_ball:render()


    love.graphics.setFont(smallFont)
    love.graphics.printf('Choose your paddle color!', 0, 115, VIRTUAL_WIDTH, 'center')

    green_dummy:render()
    blue_dummy:render()
    red_dummy:render()

    green_dummy2:render()
    blue_dummy2:render()
    red_dummy2:render()

end

function CustomizationState:exit()

end
