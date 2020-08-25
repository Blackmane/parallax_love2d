--
-- @file    main.lua
-- @brief   
-- @project parallax_love2d
-- 
-- @author  Niccolò Pieretti
-- @date    24 Aug 2020
-- @todo    boundary check
-- 
-----------------------------------------------------------------------------
--                                              
--             _  _   o   __  __   __    _  o   _   ,_    _  
--            / |/ |  |  /   /    /  \_|/ \_|  |/  /  |  |/  
--              |  |_/|_/\__/\___/\__/ |__/ |_/|__/   |_/|__/
--                                    /|                     
--                                    \|     
----------------------------------------------------------------------------/

-- ##### ##### Constants & variables ##### #####

-- Screen dimensions
local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 600

local GAME_TITLE = "Parallax LOVE2d"

local PLAYER_MOVE_OFFSET = 10

local MOUNTAINS1_SPACE = 100
local MOUNTAINS1_HEIGHT_HIGH = 20
local MOUNTAINS1_HEIGHT_LOW = 90
local MOUNTAINS1_MAX_OFFSET = { x = 100, y = 120 }

local MOUNTAINS2_SPACE = 80
local MOUNTAINS2_HEIGHT_HIGH = 70
local MOUNTAINS2_HEIGHT_LOW = 170
local MOUNTAINS2_MAX_OFFSET = { x = 80, y = 100 }

local MOUNTAINS3_SPACE = 80
local MOUNTAINS3_HEIGHT_HIGH = 150
local MOUNTAINS3_HEIGHT_LOW = 260
local MOUNTAINS3_MAX_OFFSET = { x = 120, y = 80}


-- Used for mountains
local COLORS = {
  { 186, 180, 218 }, 
  { 109, 102, 170 }, 
  {  53,  44, 133 }, 
}

-- ##### ##### Game objects ##### #####
local mountains_1 = {}
local mountains_2 = {}
local mountains_3 = {}

local offset = {
  {velocity = { x = 20, y = 0}, position = { x = 0, y = 0}},
  {velocity = { x = 60, y = 0}, position = { x = 0, y = 0}},
  {velocity = { x = 120, y = 0}, position = { x = 0, y = 0}},
}

local player = {
  velocity = { x = 100, y = 0},
  position = { x = 0, y = 0},
  size = { w = 30, h = 50},
}

-- ##### ##### Support functions ##### ##### 

-- Create a line of mountains
local function createMountainsLine (mountains, start, size, step, height_high, height_low, offset)
  next_x = start
  next_y = height_low
  mountains[0] = {x = next_x, y = next_y}
  for i = 1, size -1 do
    mountains[i] = {x = next_x + offset.x * math.random(), y = next_y}
    next_x = next_x + step
    if next_y > height_high then
      next_y = height_low + offset.y * math.random()
    else
      next_y = height_high + offset.y * math.random()
    end
  end
  mountains[size -1] = {x = next_x, y = next_y}
end

-- Create all line of mountains
local function createAllMountains ()
  start1 = - (SCREEN_WIDTH / 2)
  start2 = start1 * (offset[2].velocity.x / offset[1].velocity.x)
  start3 = start1 * (offset[3].velocity.x / offset[1].velocity.x)

  size1 = SCREEN_WIDTH / MOUNTAINS1_SPACE * ( 1 +1)
  size2 = SCREEN_WIDTH / MOUNTAINS2_SPACE * ((offset[2].velocity.x / offset[1].velocity.x) +1)
  size3 = SCREEN_WIDTH / MOUNTAINS3_SPACE * ((offset[3].velocity.x / offset[1].velocity.x) +1)

  createMountainsLine (mountains_1, start1, size1, MOUNTAINS1_SPACE, MOUNTAINS1_HEIGHT_HIGH, MOUNTAINS1_HEIGHT_LOW, MOUNTAINS1_MAX_OFFSET)
  createMountainsLine (mountains_2, start2, size2, MOUNTAINS2_SPACE, MOUNTAINS2_HEIGHT_HIGH, MOUNTAINS2_HEIGHT_LOW, MOUNTAINS2_MAX_OFFSET)
  createMountainsLine (mountains_3, start3, size3, MOUNTAINS3_SPACE, MOUNTAINS3_HEIGHT_HIGH, MOUNTAINS3_HEIGHT_LOW, MOUNTAINS3_MAX_OFFSET)
end

-- Draw mountains
local function drawMountains (mountains, offset, r, g, b, a)
  love.graphics.setColor(r, g, b, a)

  for i = 0, #mountains - 1 do
    love.graphics.polygon('fill', 
        mountains[i].x + offset.x, mountains[i].y + offset.y, 
        mountains[i+1].x + offset.x, mountains[i+1].y + offset.y, 
        mountains[i+1].x + offset.x, SCREEN_HEIGHT, 
        mountains[i].x + offset.x, SCREEN_HEIGHT)
  end
end


-- ##### ##### LOVE2D callbacks ##### ##### 

function love.load()
  -- Set window
  love.window.setTitle(GAME_TITLE)
  love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {
    fullscreen = false,
    resizable = false,
  })

  math.randomseed(os.time())

  -- Init background
  createAllMountains()

  -- Init player
  player.position.x = (SCREEN_WIDTH - player.size.w) / 2;
  player.position.y = (SCREEN_HEIGHT - player.size.h);
end


function love.update(dt)
  -- Move player and background
  if love.keyboard.isDown ('left') then
    player.position.x = player.position.x - player.velocity.x * dt
    player.position.x = math.max(SCREEN_WIDTH / 2 - PLAYER_MOVE_OFFSET, player.position.x )
    offset[1].position.x = offset[1].position.x + offset[1].velocity.x * dt
    offset[2].position.x = offset[2].position.x + offset[2].velocity.x * dt
    offset[3].position.x = offset[3].position.x + offset[3].velocity.x * dt
  end
  if love.keyboard.isDown ('right') then
    player.position.x = player.position.x + player.velocity.x * dt
    player.position.x = math.min(SCREEN_WIDTH / 2 + PLAYER_MOVE_OFFSET, player.position.x )
    offset[1].position.x = offset[1].position.x - offset[1].velocity.x * dt
    offset[2].position.x = offset[2].position.x - offset[2].velocity.x * dt
    offset[3].position.x = offset[3].position.x - offset[3].velocity.x * dt
  end

end


function love.mousepressed(x, y, button)
    -- Test mountains line
    createAllMountains ()
end


function love.draw()
  -- Draw Mountains
  drawMountains(mountains_1, offset[1].position, COLORS[1][1], COLORS[1][2], COLORS[1][3], 255)
  drawMountains(mountains_2, offset[2].position, COLORS[2][1], COLORS[2][2], COLORS[2][3], 255)
  drawMountains(mountains_3, offset[3].position, COLORS[3][1], COLORS[3][2], COLORS[3][3], 255)

  -- Color white
  love.graphics.setColor(255, 255, 255, 255)
  -- Draw player
  love.graphics.rectangle('fill', player.position.x, player.position.y, player.size.w, player.size.h)
end
