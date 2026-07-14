function love.load()
    -- Initial rectangle position and size
    rect = {
        x = 100,
        y = 100,
        width = 200,
        height = 150,
        color = {1, 0.4, 0.4} -- light red (RGB, 0-1 range)
    }
end

function love.update(dt)
    -- Move rectangle with arrow keys
    local speed = 200
    if love.keyboard.isDown("left") then
        rect.x = rect.x - speed * dt
    end
    if love.keyboard.isDown("right") then
        rect.x = rect.x + speed * dt
    end
    if love.keyboard.isDown("up") then
        rect.y = rect.y - speed * dt
    end
    if love.keyboard.isDown("down") then
        rect.y = rect.y + speed * dt
    end
end

function love.draw()
    -- Set color and draw rectangle
    love.graphics.setColor(rect.color)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height)

    -- Draw border outline
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height)

    -- Draw instructions text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Use arrow keys to move the rectangle", 10, 10)
end
