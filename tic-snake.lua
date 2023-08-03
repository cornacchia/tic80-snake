solid = {[1] = true}
t = 0

state = {
  snake = { {x = 2, y = 2, dir = 3, new = false}, {x = 1, y = 2, dir = 3, new = false} },
  fruit = { x = -1, y = -1, spr = -1 },
  newDir = 3,
  score = 0,
  speed = 10
}

function takeInput ()
  if btnp(0) and state.snake[1].dir ~= 1 then
    state.newDir = 0
  end
  if btnp(1) and state.snake[1].dir ~= 0 then
    state.newDir = 1
  end
  if btnp(2) and state.snake[1].dir ~= 3 then
    state.newDir = 2
  end
  if btnp(3) and state.snake[1].dir ~= 2 then
    state.newDir = 3
  end
  state.snake[1].dir = state.newDir
end

function getNewX (x, dir)
  if dir == 2 then return x - 1 end
  if dir == 3 then return x + 1 end
  return x
end

function getNewY (y, dir)
  if dir == 0 then return y - 1 end
  if dir == 1 then return y + 1 end
  return y
end

function updatePosition ()
  -- check head collision
  hNextX = getNewX(state.snake[1].x, state.newDir)
  hNextY = getNewY(state.snake[1].y, state.newDir)
  -- reset game if collision
  if solid[mget(hNextX, hNextY)] or checkSnake(hNextX, hNextY) then
    reset()
  end
  if hNextX == state.fruit.x and hNextY == state.fruit.y then
    state.score = state.score + 1
    if (state.score % 2 == 0) then state.speed = state.speed - 1 end
    state.fruit.x = -1
    state.fruit.y = -1
    state.snake[1].new = true
  end
  state.snake[1].x = hNextX
  state.snake[1].y = hNextY

  -- update rest of snake
  for i = 2, #state.snake do
    state.snake[i].x = getNewX(state.snake[i].x, state.snake[i].dir)
    state.snake[i].y = getNewY(state.snake[i].y, state.snake[i].dir)
  end
end

function getRotation ()
  if state.snake[1].dir == 0 then return 0 end
  if state.snake[1].dir == 1 then return 2 end
  if state.snake[1].dir == 2 then return 3 end
  if state.snake[1].dir == 3 then return 1 end
end

function drawSnake ()
  local headRotation = getRotation()
  spr(272, state.snake[1].x * 8, state.snake[1].y * 8, -1, 1, 0, headRotation)
  for i = 2, #state.snake do
    spr(256, state.snake[i].x * 8, state.snake[i].y * 8)
  end
end

function updateDir ()
  for i = #state.snake, 2, -1 do
    state.snake[i].dir = state.snake[i - 1].dir
    if state.snake[i - 1].new then
      state.snake[i - 1].new = false
      state.snake[i].new = true
    end
  end
end

function addTail (tail)
  local newTail = {
    x = tail.x,
    y = tail.y,
    dir = -1,
    new = false
  }

  table.insert(state.snake, newTail)
end

function updateTail ()
  if state.snake[#state.snake].new then
    state.snake[#state.snake].new = false
    addTail(state.snake[#state.snake])
  end
end

function checkSnake (x, y)
  for i = 1, #state.snake do
    if state.snake[i].x == x and state.snake[i].y == y then
      return true
    end
  end
  return false
end

function drawFruit()
  if state.fruit.x < 0 then
    math.randomseed( time() )
    state.fruit.x = math.random(1, 29)
    state.fruit.y = math.random(1, 16)
    state.fruit.spr = 257 + (time() % 3)
    while solid[mget(state.fruit.x, state.fruit.y)] or
          checkSnake(state.fruit.x, state.fruit.y)
    do
      state.fruit.x = math.random(1, 29)
      state.fruit.y = math.random(1, 16)
    end
  end
  spr(state.fruit.spr, state.fruit.x * 8, state.fruit.y * 8, 15)
end

function TIC ()
  cls()
  map(0,0)
  takeInput()
  if (t % state.speed == 0) then
    updatePosition()
    updateDir()
    updateTail()
  end
  drawSnake()
  drawFruit()
  print("Score: " .. state.score, 0, 0, 12)
  t = t + 1
end