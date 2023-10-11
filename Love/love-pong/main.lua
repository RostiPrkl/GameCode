push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle("Löve Pong")

	math.randomseed(os.time())

	smallFont = love.graphics.newFont('font.ttf', 8)
	largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)

	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/blip.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/blop.wav', 'static'),
		['score'] = love.audio.newSource('sounds/goal.wav', 'static'),
		['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
		['start'] = love.audio.newSource('sounds/start.wav', 'static')
	}
	
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH -10, VIRTUAL_HEIGHT -30, 5, 20)

	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1Score = 0
    player2Score = 0
	
	servingPlayer = 1

    gameState = 'start'

end


function love.resize(w, h)
	push:resize(w, h)
end


function love.update(dt)
	if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end

	--ball collision logic
	--player 1 collision
	elseif gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
			sounds['paddle_hit']:play()
        end
		--player2 collision
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
			sounds['paddle_hit']:play()
        end
		--edge collision
		if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
			sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
			sounds['wall_hit']:play()
        end

		--scorekeeping
	if ball.x < 0 then
		servingPlayer = 1
		player2Score = player2Score + 1
		sounds['score']:play()

		if player2Score == 10 then
			winningPlayer = 2
			gameState = 'done'
			sounds['victory']:play()
		else
			gameState = 'serve'
			
			ball:reset()
		end
	end

	if ball.x > VIRTUAL_WIDTH then
		servingPlayer = 2
		player1Score = player1Score + 1
		sounds['score']:play()

		if player1Score == 10 then
			winningPlayer = 1
			gameState = 'done'
			sounds['victory']:play()
		else
			gameState = 'serve'
			
			ball:reset()
		end
	end
	end

	--player 1 movement
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	--player 2 movement
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	if gameState == 'play' then
		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
			sounds['start']:play()
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'
			ball:reset()
			player1Score = 0
			player2Score = 0

			if winningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayer = 1
			end
		end
	end
end

function love.draw()
	push:apply('start')

	love.graphics.clear(38/255, 38/255, 38/255, 255/255)
	
	love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Love Pong', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        --nothing
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
	--player score
	displayScore()
	
    -- left paddle player 1
    player1:render()

    --right paddle player 2
    player2:render()

	--ball
	ball:render()

	displayFPS()

	push:apply('end')
end

function displayFPS ()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0/255, 255/255, 0/255, 255/255)
	love.graphics.print("FPS " .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2.5)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 2.5)
	love.graphics.setFont(smallFont)
	love.graphics.printf('Player 1', -40, 70, VIRTUAL_WIDTH, 'center')
	love.graphics.printf('Player 2', 40, 70, VIRTUAL_WIDTH, 'center')
end

