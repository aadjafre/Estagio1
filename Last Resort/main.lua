display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning
local physics = require ("physics") --Require physics
physics.start(); physics.setGravity( 0, 0 ) --Start physics
-----------------------------------------------
--*** Set up our variables and group ***
-----------------------------------------------
local levelGroup = display.newGroup()
local enemyGroup = display.newGroup()
local weaponGroup = display.newGroup()

local _W = display.contentWidth
local _H = display.contentHeight
local mr = math.random --Localise math.random

local stars1, stars2 --Background moving stars
local gameIsActive = true 
local spawnInt = 0 --Gameloop spawn control
local spawnIntMax = 30 --Gameloop max spawn
local spawned = 0 --Keep track of enemies
local spawnedMax = 10 --Max allowed per level
local score = 0
local pregPercent = 0
local enemySpeed = -8 --How fast the enemies are
local scoreText; local percentText; local ship; local wave=5;

local function levelSetup()
 stars1 = display.newImageRect("images/bg.png", 628,280)
 stars1.x = _W*0.5; stars1.y = _H*0.5
 levelGroup:insert(stars1)
 stars2 = display.newImageRect("images/bg.png", 628,280)
 stars2.x = _W*0.5; stars2.y = _H*0.5
 levelGroup:insert(stars2)
 scoreText = display.newText("Score: "..score, 0,0,"Helvetica",18)
 scoreText:setTextColor(225, 225, 225)
 scoreText.x = _W*0.5; scoreText.y = 10
 levelGroup:insert(scoreText)
 percentText = display.newText("Percent: "..pregPercent, 0,0,"Helvetica",18)
 percentText:setTextColor(255, 255, 255)
 percentText.x = 0; percentText.y = 10
 levelGroup:insert(percentText)

 --Move Uterus.
 stars1:translate(0,2); stars2:translate(0,2)
 if stars1.y >= (_H*0.5)+280 then
  stars1.y = (_H*0.5)-280
 end
 if stars2.y >= (_H*0.5)+280 then
  stars2.y = (_H*0.5)-280
 end


 local function moveShip( event )
  local t = event.target; local phase = event.phase
  if "began" == phase then
   display.getCurrentStage():setFocus( t )
   t.isFocus = true
   t.y0 = event.y - t.y
   elseif t.isFocus then
   if "moved" == phase then
    t.y = event.y - t.y0
    if t.y >= 270 then t.y = 270 end
    if t.y <= 50 then t.y = 50 end
    elseif "ended" == phase or "cancelled" == phase then
    display.getCurrentStage():setFocus( nil )
    t.isFocus = false
   end
  end
  return true
 end
 ship = display.newImageRect("images/ship.png", 100, 60)
 ship.x = -80; ship.y = _H*0.5; ship.name = "ship"
 physics.addBody( ship, { isSensor = true } )
 ship:addEventListener("touch",moveShip)
 levelGroup:insert(ship)
 transition.to(ship, {time = 600, x = 0})

 local screenBlock = display.newRect(0, _H*0.5, 1, _H)
 screenBlock.name = "blocker"
 physics.addBody( screenBlock, { isSensor = true } )
-- screenBlock.isVisible = false
 levelGroup:insert(screenBlock)
end
levelSetup()

local function spawnEnemy()
    spermSpritesheetData = { width=32, height=32, numFrames=3 }
    mySpermSheet = graphics.newImageSheet( "images/Sperm.png", spermSpritesheetData )
    spermSequenceData = {
                        {name = "normalRun", start=1, count=3, time=800}
                       }
    spermMoving = display.newSprite( mySpermSheet, spermSequenceData )
    spermMoving:play()


        --local enemy = display.newImageSheet("images/Sperm.png",50,54)
 spermMoving.x = 600; spermMoving.y = mr( 30, 280 )
 spermMoving.name = "enemy"; physics.addBody( spermMoving, { isSensor = true } )
 enemyGroup:insert( spermMoving )

 if spawned == spawnedMax then 
 wave = wave + 1 --Increase the wave.
    if wave <= 18 then --Limit max speed/spawn
    enemySpeed = enemySpeed - 1
    spawnIntMax = math.round(spawnIntMax * 0.9)
    end
    spawned = 0 --Reset so that the next wave starts from 0
    end
 spawnInt = 0
end

local function gameLoop(event)
  if gameIsActive == true then
  --Increase the int until it spawns an enemy..
  spawnInt = spawnInt + 1

 --change spawnIntMax if you want enemies to spawn
 --faster or slower.
  if spawnInt == spawnIntMax then
  spawnEnemy()
  spawned = spawned + 1
  end

 --Set score and level text here..
  scoreText.text = "Score: "..score
  percentText.text = "Percent: "..pregPercent
  score = score +5

  --Move the enemies down each frame!
  local i
  for i = enemyGroup.numChildren,1,-1 do
  local enemy = enemyGroup[i]
  if enemy ~= nil and enemy.y ~= nil then
   enemy:translate( enemySpeed, 0)
  end
  end

 end
end
Runtime:addEventListener ("enterFrame", gameLoop)

local function onCollision(event)
 if event.phase == "began" and gameIsActive == true then
 local obj1 = event.object1; 
 local obj2 = event.object2; 

  if obj1.name == "ship" and obj2.name == "enemy" or obj2.name == "ship" and obj1.name == "enemy" then
   if obj1.name == "enemy" then
    display.remove( obj1 ); obj1 = nil
   elseif obj2.name == "enemy" then
    display.remove( obj2 ); obj2 = nil
   end
   score = score + 100 --Yay points!

  end
  if obj1.name == "enemy" and obj2.name == "blocker" or obj1.name == "blocker" and obj2.name == "enemy" then
   pregPercent = pregPercent + 5
   if pregPercent == 100 then gameOver()
   end
  end
 end
end
Runtime:addEventListener( "collision", onCollision )

local function gameOver()
 gameIsActive = false --Stop the loops from running
 local function restartGame( event ) 
 if event.phase == "ended" then
 --Loop through the groups deleting everyting
-- local i
-- for i = levelGroup.numChildren,1,-1 do
-- local child = levelGroup[i]
-- child.parent:remove( child )
-- child = nil
-- end
-- for i = enemyGroup.numChildren,1,-1 do
-- local child = enemyGroup[i]
-- child.parent:remove( child )
-- child = nil
-- end
 --Now reset the vars and create everything again.
 gameIsActive = true
 enemySpeed = 15
 spawnInt = 0; spawnIntMax = 30
 spawned = 0; spawnedMax = 10
 score = 0
 wave = 1
 levelSetup()
 end
 return true
 end
 --Show game over text and restart text.
 local gameOverText = display.newText("Ohuh! You died", 0,0, "Helvetica", 20)
 gameOverText.x = _W*0.5; gameOverText.y = _H*0.4;
 levelGroup:insert(gameOverText)
 local gameOverScore = display.newText("With a score of "..score, 0,0, "Helvetica", 20)
 gameOverScore.x = _W*0.5; gameOverScore.y = gameOverText.y + 30;
 levelGroup:insert(gameOverScore)
 local tryAgainText = display.newText("Click me to try again!", 0,0, "Helvetica", 20)
 tryAgainText.x = _W*0.5; tryAgainText.y = gameOverScore.y + 50;
 levelGroup:insert(tryAgainText)
 tryAgainText:addEventListener("touch", restartGame)
end
