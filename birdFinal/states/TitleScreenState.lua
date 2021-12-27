--[[
    TitleScreenState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The TitleScreenState is the starting screen of the game, shown on startup. It should
    display "Press Enter" and also our highest score.
]]

TitleScreenState = Class{__includes = BaseState}

function TitleScreenState:enter(params)
    self.highScores = params.highScores
    score = 0
    self.selection = 0
end

function TitleScreenState:update(dt)
    -- transition to countdown when enter/return are pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.mouse.wasPressed(1) then
      sounds['pause']:play()
      if self.selection == 0 then
        gStateMachine:change('countdown', {
          highScores = self.highScores,
          score = self.score
        })
      else
        gStateMachine:change('high-scores', {
          highScores = self.highScores,
          score = self.score
        })
      end
    end

    if love.keyboard.wasPressed('up') then
      sounds['score']:play()
      if self.selection == 1 then
        self.selection = 0
      else
        self.selection = self.selection + 1
      end

    elseif love.keyboard.wasPressed('down') then
      sounds['score']:play()
      if self.selection == 0 then
        self.selection = 1
      else
        self.selection = self.selection - 1
      end
    end
end

function TitleScreenState:render()

  function PlayState:enter(params)
      self.highScores = params.highScores
  end

    -- simple UI code
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Fifty Bird', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press Enter', 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Start', 0, VIRTUAL_HEIGHT - 64, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('High Scores', 0, VIRTUAL_HEIGHT - 44, VIRTUAL_WIDTH, 'center')

    if self.selection == 0 then
        love.graphics.printf('>>', 180, VIRTUAL_HEIGHT - 64, VIRTUAL_WIDTH, 'left')
    else
      love.graphics.printf('>>', 180, VIRTUAL_HEIGHT - 44, VIRTUAL_WIDTH, 'left')
    end
end
