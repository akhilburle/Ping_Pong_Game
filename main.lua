WINDOW_WIDTH = 800
WINDOW_HEIGHT = 560
player_dy = 300;

function round_rectangle(x, y, width, height, radius)
	--RECTANGLES
	love.graphics.rectangle("fill", x + radius, y + radius, width - (radius * 2), height - radius * 2)
	love.graphics.rectangle("fill", x + radius, y, width - (radius * 2), radius)
	love.graphics.rectangle("fill", x + radius, y + height - radius, width - (radius * 2), radius)
	love.graphics.rectangle("fill", x, y + radius, radius, height - (radius * 2))
	love.graphics.rectangle("fill", x + (width - radius), y + radius, radius, height - (radius * 2))
	
	--ARCS
	love.graphics.arc("fill", x + radius, y + radius, radius, math.rad(-180), math.rad(-90))
	love.graphics.arc("fill", x + width - radius , y + radius, radius, math.rad(-90), math.rad(0))
	love.graphics.arc("fill", x + radius, y + height - radius, radius, math.rad(-180), math.rad(-270))
	love.graphics.arc("fill", x + width - radius , y + height - radius, radius, math.rad(0), math.rad(90))
end

function love.load()
    font = love.graphics.newFont('fonts/slant.ttf', 30)
    old_font = love.graphics.getFont()
    love.graphics.setFont(font)
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    left_player_y = WINDOW_HEIGHT/8
    right_player_y = 6 * WINDOW_HEIGHT / 8
    ball_x = WINDOW_WIDTH/2
    ball_y = WINDOW_HEIGHT/2
    game_state = 'start'
    math.randomseed(os.time())
    ball_dx = math.random(2) == 1 and -200 or 200
    ball_dy = math.random(-150, 150)
    score_left = 0
    score_right = 0;
    powerup = love.audio.newSource("sounds/Powerup.wav", 'static')
    hitsound = love.audio.newSource("sounds/Hit_Hurt.wav", 'static')
    background = love.audio.newSource("sounds/background.mp3", 'static')
    background:setVolume(0.3)
    background:setLooping(true)
    background:play()

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if game_state == 'start' then
            game_state = 'game'
        else
            game_state = 'start'
            left_player_y = WINDOW_HEIGHT/8
            right_player_y = 6 * WINDOW_HEIGHT / 8
            ball_x = WINDOW_WIDTH/2
            ball_y = WINDOW_HEIGHT/2
        end

    end
end

function love.update(dl)
    if love.keyboard.isDown('w') then
        left_player_y = (left_player_y - player_dy * dl) < 0 and 0 or (left_player_y - player_dy * dl)
    elseif love.keyboard.isDown('s') then
        left_player_y = (left_player_y + 60 + player_dy * dl) > WINDOW_HEIGHT and (WINDOW_HEIGHT - 60) or left_player_y + player_dy * dl
    end

    if love.keyboard.isDown('up') then
        right_player_y = (right_player_y - player_dy * dl) < 0 and 0 or (right_player_y - player_dy * dl)
    elseif love.keyboard.isDown('down') then
        right_player_y = (right_player_y + 60 + player_dy * dl) > WINDOW_HEIGHT and (WINDOW_HEIGHT - 60) or right_player_y + player_dy * dl
    end
    
    remember_dx = ball_dx
    remember_dy = ball_dy

    if game_state == 'game' then
        ball_x = ball_x + ball_dx * dl
        ball_y = ball_y + ball_dy * dl
        -- if ball_x - 8 < 0 then
        --     ball_x = 16 - ball_x
        --     ball_dx = -ball_dx
        -- end
        if ball_y - 8 < 0 then
            ball_y = 16 - ball_y
            ball_dy = -ball_dy
        end

        if ball_y + 8 >= WINDOW_HEIGHT then
            ball_y = 2 * WINDOW_HEIGHT - ball_y - 16
            ball_dy = -ball_dy
        end

        if ball_x + 8 > (WINDOW_WIDTH - 20) and ball_x < (WINDOW_WIDTH - 10) and ball_y >= right_player_y and ball_y < (right_player_y + 60) then
            ball_x = 2 * (WINDOW_WIDTH - 20) - ball_x - 16
            ball_dx = -ball_dx
            if love.keyboard.isDown('down') then
                ball_dy = ball_dy + 50
            elseif love.keyboard.isDown('up') then
                ball_dy = ball_dy - 50
            end
        end

        if ball_x - 8 < 20 and ball_x > 10 and ball_y >= left_player_y and ball_y < (left_player_y + 60) then
            ball_x = 40 - (ball_x - 8) + 8
            ball_dx = -ball_dx
            if love.keyboard.isDown('s') then
                ball_dy = ball_dy + 50
            elseif love.keyboard.isDown('w') then
                ball_dy = ball_dy - 50
            end
        end

        if ball_x - 8 > WINDOW_WIDTH then
            score_left = score_left + 1
            powerup:play()
            ball_x = WINDOW_WIDTH/2
            ball_y = WINDOW_HEIGHT/2
            math.randomseed(os.time())
            ball_dx = math.random(2) == 1 and -200 or 200
            ball_dy = math.random(-150, 150)
        end

        if ball_x + 8 < 0 then
            score_right = score_right + 1
            powerup:play()
            ball_x = WINDOW_WIDTH/2
            ball_y = WINDOW_HEIGHT/2
            math.randomseed(os.time())
            ball_dx = math.random(2) == 1 and -200 or 200
            ball_dy = math.random(-150, 150)
        end
    end

    if (remember_dx == ball_dx) and (remember_dy == ball_dy) then
        
    else
        hitsound:play()
    end
end

function love.draw()
    love.graphics.clear(0, 0, 0, 255)
    love.graphics.setColor(0, 255, 0, 50)
    love.graphics.setFont(old_font)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.printf("Press ESC to leave game", WINDOW_WIDTH - 150, 10, 150, 'center')
    love.graphics.setFont(font)
    love.graphics.setColor(255, 255, 255, 255)
    if game_state == 'start' then
        love.graphics.printf("WeLcOmE tO pInG pOnG 1\n\nPress Enter to begin", 0, WINDOW_HEIGHT/8, WINDOW_WIDTH, 'center')
    else
        -- love.graphics.setColor(0, 255, 0, 50) 
        love.graphics.printf(tostring(score_left), 0, 15, WINDOW_WIDTH/2, 'center')
        love.graphics.printf(tostring(score_right), WINDOW_WIDTH/2, 15, WINDOW_WIDTH/2, 'center')
        -- love.graphics.setColor(255, 255, 255, 255) 
    end
    -- love.graphics.rectangle("fill", 10, left_player_y, 10, 60)
    round_rectangle(10, left_player_y, 10, 60, 3)
    love.graphics.circle("fill", ball_x, ball_y, 8)
    -- love.graphics.rectangle("fill", WINDOW_WIDTH - 20, right_player_y, 10, 60)
    round_rectangle(WINDOW_WIDTH - 20, right_player_y, 10, 60, 3
)
end