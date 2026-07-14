local Buttons = require("library/buttons")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Buttons.load({
        opacity = 0.65,
        theme = "default",
        controls = {
            Up = {"w", "up"}, -- W or Arrow-Up
            Down = {"s", "down"}, -- S or Arrow-Down
            Left = {"a", "left"}, -- A or Arrow-Left
            Right = {"d", "right"} -- D or Arrow-Right
        }
    })

    -- Create on-screen controls (touch + mouse work automatically!)
    Buttons.createDPad()
    Buttons.createABXY()
    Buttons.createMenu()

    anim8 = require 'library/anim8'
    sti = require "library/sti"
    camera = require "library/camera"
    wf = require "library/windfield"

    world = wf.newWorld(0, 0)
    speed = 50

    cam = camera()
    zoom = 2.5

    cam:zoomTo(zoom)
    spritesheet = love.graphics.newImage("sprites/player-sheet.png")

    player = {
        x = 100,
        y = 80,
        collider = world:newBSGRectangleCollider(40, 25, 10, 20, 10),
        spritesheet = spritesheet
    }

    player.collider:setFixedRotation(true)
    player.grid = anim8.newGrid(12, 18, player.spritesheet:getWidth(), player.spritesheet:getHeight())

    player.animations = {
        down = anim8.newAnimation(player.grid("1-4", 1), 0.2),
        left = anim8.newAnimation(player.grid("1-4", 2), 0.2),
        right = anim8.newAnimation(player.grid("1-4", 3), 0.2),
        up = anim8.newAnimation(player.grid("1-4", 4), 0.2)
    }

    -- Load map
    gameMap = sti("maps/city2.lua")

    player.anim = player.animations.down

    pressed = {
        left = false,
        right = false,
        up = false,
        down = false
    }

    local h = love.graphics.getHeight()

    walls = {}
    if gameMap.layers["colisionss"] then
        for i, obj in pairs(gameMap.layers["colisionss"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

    -- local wall = world:newRectangleCollider(50,50,50,50)
    -- wall:setType('static')

    walls = {}

    if gameMap.layers["collision"] then
        for _, obj in ipairs(gameMap.layers["collision"].objects) do

            -- Rectangle
            if obj.shape == "rectangle" or obj.rectangle then
                if obj.width > 0 and obj.height > 0 then
                    local wall = world:newRectangleCollider(obj.x + obj.width / 2, obj.y + obj.height / 2, obj.width,
                        obj.height)
                    wall:setType("static")
                    table.insert(walls, wall)
                end

                -- Polygon
            elseif obj.shape == "polygon" and obj.polygon then
                local vertices = {}

                for _, v in ipairs(obj.polygon) do
                    table.insert(vertices, obj.x + v.x)
                    table.insert(vertices, obj.y + v.y)
                end

                local wall = world:newPolygonCollider(vertices)
                wall:setType("static")
                table.insert(walls, wall)

                -- Ellipse
            elseif obj.shape == "ellipse" then
                local wall = world:newCircleCollider(obj.x + obj.width / 2, obj.y + obj.height / 2,
                    math.min(obj.width, obj.height) / 2)
                wall:setType("static")
                table.insert(walls, wall)
            end
        end
    end

end

function love.update(dt)
    Buttons.update(dt)

    local isMoving = false
    local vx = 0
    local vy = 0

    if Buttons.down("Left") then
        vx = speed * -1
        player.anim = player.animations.left
        isMoving = true
    end
    if Buttons.down("Right") then
        vx = speed 
        player.anim = player.animations.right
        isMoving = true

    end
    if Buttons.down("Up") then
        vx = speed * -1
        player.anim = player.animations.up
        isMoving = true

    end
    if Buttons.down("Down") then
        vx = speed 
        player.anim = player.animations.down
        isMoving = true

    end

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    if vx ~= 0 and vy ~= 0 then
        local length = math.sqrt(vx * vx + vy * vy)

        vx = (vx / length) * speed
        vy = (vy / length) * speed
    end

    player.collider:setLinearVelocity(vx, vy)

    -- player.x = player.collider:getX()
    -- player.y = player.collider:getY()

    player.anim:update(dt)

    world:update(dt)
    gameMap:update(dt)

    -- Update player position
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    -- Camera follow player
    cam:lookAt(player.x, player.y)

    -- Camera bounds with zoom

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    local halfW = love.graphics.getWidth() / (2 * zoom)
    local halfH = love.graphics.getHeight() / (2 * zoom)

    cam.x = math.max(halfW, math.min(cam.x, mapW - halfW))
    cam.y = math.max(halfH, math.min(cam.y, mapH - halfH))

    -- cam:lookAt(player.x, player.y)

    -- local mapW = gameMap.width * gameMap.tilewidth
    -- local mapH = gameMap.height * gameMap.tileheight

    -- local wt = love.graphics.getWidth() / 2
    -- local ht = love.graphics.getHeight() / 2

    -- if cam.x < wt then
    --     cam.x = wt
    -- end

    -- if cam.y < ht then
    --     cam.y = ht
    -- end

    -- if cam.x > mapW - wt then
    --     cam.x = mapW - wt
    -- end

    -- if cam.y > mapH - ht then
    --     cam.y = mapH - ht
    -- end

end

function love.draw()
    Buttons.draw()

    cam:attach()

    gameMap:drawLayer(gameMap.layers["base"])
    gameMap:drawLayer(gameMap.layers["sea"])
    gameMap:drawLayer(gameMap.layers["house"])
    gameMap:drawLayer(gameMap.layers["plantbase"])
    gameMap:drawLayer(gameMap.layers["plant-1"])
    gameMap:drawLayer(gameMap.layers["plant-2"])
    gameMap:drawLayer(gameMap.layers["treeborder"])
    gameMap:drawLayer(gameMap.layers["flowers"])

    player.anim:draw(player.spritesheet, player.x, player.y, nill, 1.5, nill, 6, 9)
    -- world:draw()

    cam:detach()

end

-- Forward input callbacks (REQUIRED)
function love.keypressed(key)
    Buttons.keypressed(key)
end
function love.keyreleased(key)
    Buttons.keyreleased(key)
end
function love.mousepressed(x, y, b)
    Buttons.mousepressed(x, y, b)
end
function love.mousereleased(x, y, b)
    Buttons.mousereleased(x, y, b)
end
function love.touchpressed(id, x, y)
    Buttons.touchpressed(id, x, y)
end
function love.touchmoved(id, x, y)
    Buttons.touchmoved(id, x, y)
end
function love.touchreleased(id)
    Buttons.touchreleased(id)
end

