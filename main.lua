 --
 -- @file    main.lua
 -- @brief   
 -- @project breakout_love2d_demo
 -- 
 -- @author  Niccolò Pieretti
 -- @date    20 May 2020
 -- @bug     some collision edge cases during movement
 -- @todo    add music
 -- @todo    score and game over
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
local SCREEN_OFFSET = 8

local GAME_TITLE = "Breakout LOVE2d Demo"
local BALL_MAX_VELOCITY_X = 200
local BALL_MAX_VELOCITY_Y = 300

local BLOCK_AREA_OFFSET_TOP = 60
local BLOCK_AREA_LINES = 6
local BLOCK_AREA_COLUMNS = 8
local BLOCK_SIZE_W = 97
local BLOCK_SIZE_H = 19
local BLOCK_BORDER = 1

-- Used for blocks
local COLORS = {
  { 235,  78,  70 }, -- Red
  { 255, 160,   0 }, -- Ocher
  { 243, 177,  83 }, -- Orange
  { 252, 238,  91 }, -- Yellow
  { 110, 220,  79 }, -- Green fluo
  {  93, 173, 249 }, -- Cyan
}

-- Handle start ball
local isStart = false

-- ##### ##### Game objects ##### #####

local BLOCKS = {}

local ball = {
  velocity = { x = 0, y = 0},
  position = { x = 0, y = 0},
  size = { w = 10, h = 10},
}

local paddle = {
  velocity = { x = 300, y = 0},
  position = { x = 0, y = 0},
  size = { w = 120, h = 16},
}

-- ##### ##### Support functions ##### ##### 

-- Check collision between two rectangle
local function aabb( a, b )
  return (
    a.position.x <= b.position.x + b.size.w and
    a.position.x + a.size.w >= b.position.x and
    a.position.y <= b.position.y + b.size.h and
    a.position.y + a.size.h >= b.position.y
  )
end

local function movePaddle (dt)
  -- Handle keyboard
  if love.keyboard.isDown ('left') then
    paddle.position.x = paddle.position.x - paddle.velocity.x * dt
  end
  if love.keyboard.isDown ('right') then
    paddle.position.x = paddle.position.x + paddle.velocity.x * dt
  end
  
  -- Check boundaries collision
  if paddle.position.x < SCREEN_OFFSET then
    paddle.position.x = SCREEN_OFFSET
  end
  if paddle.position.x + paddle.size.w > SCREEN_WIDTH - SCREEN_OFFSET then
    paddle.position.x = SCREEN_WIDTH - SCREEN_OFFSET - paddle.size.w
  end
end

local function moveBall (dt)
  ball.position.x = ball.position.x + ball.velocity.x * dt
  ball.position.y = ball.position.y + ball.velocity.y * dt
end

local function checkBallBlockCollision ()
  -- Check Blocks collision
  for i, block in pairs(BLOCKS) do
    if ( aabb(ball, block) ) then
      table.remove ( BLOCKS, i )
      ball.velocity.y = -ball.velocity.y
    end
  end
end

local function checkBallCollision ()
  -- Check paddle collision
  if ( aabb(ball, paddle) ) then
    ball.velocity.y = -ball.velocity.y 
    -- Handle like "spin effect"
    ball.velocity.x = (ball.position.x - paddle.position.x) * BALL_MAX_VELOCITY_X * 2 / paddle.size.w - BALL_MAX_VELOCITY_X
  end
  -- Check boundaries collision
  if ball.position.x < SCREEN_OFFSET or 
    ball.position.x + ball.size.w > SCREEN_WIDTH - SCREEN_OFFSET then
    ball.velocity.x = -ball.velocity.x 
  end
  if ball.position.y < SCREEN_OFFSET or 
    ball.position.y + ball.size.h > SCREEN_HEIGHT - SCREEN_OFFSET then
    ball.velocity.y = -ball.velocity.y -- TODO: game over
  end
end

-- Check all ball collision
local function checkCollisions ()
  checkBallCollision ()
  checkBallBlockCollision ()
end

-- ##### ##### LOVE2D callbacks ##### ##### 

function love.load()
  -- Set window
  love.window.setTitle(GAME_TITLE)
  love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {
    fullscreen = false,
    resizable = false,
  })

  -- Init paddle
  paddle.position.y = SCREEN_HEIGHT - paddle.size.h - SCREEN_OFFSET * 2
  paddle.position.x = SCREEN_WIDTH /2 - paddle.size.w /2

  -- Init ball
  ball.position.y = SCREEN_HEIGHT * 3/4
  ball.position.x = SCREEN_WIDTH /2 - ball.size.w /2

  -- Init blocks
  for i = 0, BLOCK_AREA_COLUMNS - 1 do
    local x = (i * (BLOCK_SIZE_W + BLOCK_BORDER)) + SCREEN_OFFSET
    for j = 0, BLOCK_AREA_LINES - 1 do
      local y = (j * (BLOCK_SIZE_H + BLOCK_BORDER)) + SCREEN_OFFSET + BLOCK_AREA_OFFSET_TOP
      table.insert(BLOCKS, {
        color = COLORS[j + 1],
        position = {x = x, y = y},
        size = {w = BLOCK_SIZE_W, h = BLOCK_SIZE_H}
      })
    end
  end
  
end

function love.update(dt)
  checkCollisions ()
  movePaddle (dt)
  if isStart then
    moveBall (dt)
  else
    -- Start ball if space key is down
    if love.keyboard.isDown (' ') then
      ball.velocity.y = BALL_MAX_VELOCITY_Y
      isStart = true
    end
  end
end

function love.draw()
  -- Color white
  love.graphics.setColor(255, 255, 255, 255)
  -- Draw paddle
  love.graphics.rectangle('fill', paddle.position.x, paddle.position.y, paddle.size.w, paddle.size.h)
  -- Draw ball
  love.graphics.rectangle('fill', ball.position.x, ball.position.y, ball.size.w, ball.size.h)

  -- Draw coloured blocks
  for _, block in pairs(BLOCKS) do
    love.graphics.setColor(block.color[1], block.color[2], block.color[3], 255)
    love.graphics.rectangle('fill', block.position.x, block.position.y, block.size.w, block.size.h)
  end
  
end
