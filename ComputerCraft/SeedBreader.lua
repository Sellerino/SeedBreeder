----------------------------------------------------
------------------SOME VARIABLES--------------------
----------------------------------------------------

t = turtle
dataF = "sbdata/data"
redstoneSleep = 0.9

seed = {g = 0, y = 0, s = 0, name=""}

slot = {fuel = 1, sticks1 = 2, sticks2 = 3, seed = 4, extra = 5}
pos={x = 1, z = 0, seed={} , actv={}}
pos.seed[0] = {x = -1, z = 0}
pos.actv[0] = {x = -1, z = -1}

pos.seed[1] = {x = 0, z = 1}
pos.actv[1] = {x = 1, z = 1}

pos.seed[2] = {x = 0, z = 0}
pos.actv[2] = {x = 0, z = -1}

pos.anlzer = {x=1,z=0}
pos.chest = {x=-1,z=1}
pos.bin = {x=1,z=-1}

seedSlot = 4

data={}


if not fs.exists("UpdatedSB1") then
	print("Updating sb program")
	fs.delete("sb")
	shell.run("pastebin get gF0Tsbhg sb")
	
	local file = fs.open("UpdatedSB1","w")
	file.close()
end


----------------------------------------------------
-----------------LANG VARIABLES---------------------
----------------------------------------------------
lang_noFuel = "Please insert a valid fuel in slot "..slot.fuel.."!"
lang_noSticks = "Please insert Crop Sticks in slot "..slot.sticks1.." or "..slot.sticks2.."!"
--lang_noRake = "Please insert a Hand Rake in slot "..slot.rake.."!"
lang_noSeed = "Please insert a valid seeds in slot "..slot.seed.."!"
lang_manySeeds = "There are too many seeds! Use 1 or 2 only."
lang_maxedOut = "This seed is now 10/10/10!"
lang_line = "---------------------------------------"
lang_placingStick = "Placing sticks"
lang_placingSeedsInAcv = "Placing seeds in Autonomous Activator"
lang_placingSticksInAcv = "Placing sticks in Autonomous Activator"


CCSA = "Computer Controlled Seed Analyzer"
TRSHC = "Trash Can"
CRPSTCK = "Crop Sticks without seeds"
----------------------------------------------------
----------------------------------------------------
----------------------------------------------------

function loadData()
   if fs.exists(dataF) then
    local file = fs.open(dataF,"r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
   else
    data = {x = 0, z = 0, state = 0, weedState = 0, seed = "",Gm = 0, Ym = 0, Sm = 0, seedRepl = 0,}
    fs.makeDir("sbdata")
    local file = fs.open(dataF,"w")
    file.write(textutils.serialize(data))
    file.close()
    return data
   end
end
function saveData()
   local file = fs.open(dataF,"w")
   file.write(textutils.serialize(data))
   file.close()
end
function setState(id)
   data.state = id
	saveData()
end
function setWState(id)
    data.weedState = id
    saveData()
end
function stateRange(min,max)
    if data.state >= min and data.state < max then
        return true
    else
        return false
    end
end

----------------------------------------------------
---------------BASIC TURTLE COMMANDS----------------
----------------------------------------------------
function resetScreen()
   term.clear()
   term.setCursorPos(1,1)
end

function putInAnlzer()
  if checkCount(slot.seed,1) then
    lastSl = select(slot.seed)
  elseif checkCount(slot.sticks2,1) then
    lastSl = select(slot.sticks2)
  end
  succes = t.dropDown()
  select(lastSl)
  return succes
end
function wrapAnlzer()
  return peripheral.wrap("bottom")
end
function takeFromAnlzer()
  lastSl = select(slot.seed)
  succes = suckDown(64)
  select(lastSl)
  return succes
end
function isMaxedOut()
  if seed.g == 10 and seed.y == 10 and seed.s == 10 then
    return true
  end
  return false
end
function updateSeedMaxData(letEqualUpdate)
  local anl = wrapAnlzer()
  local g, y, s = anl.getSpecimenStats()
    if (seed.g+seed.s+seed.y)/3 < (g+y+s)/3 and not letEqualUpdate then
      seed.g = g
      seed.y = y
      seed.s = s
      return true
    elseif (seed.g+seed.s+seed.y)/3 <= (g+y+s)/3 and letEqualUpdate then
      seed.g = g
      seed.y = y
      seed.s = s
      return true
    end
  return false
end
function analyze(letEqualUpdate)
  move(pos.anlzer)
  print("Analyzing")
  if putInAnlzer() then
    local anl = wrapAnlzer()
    anl.analyze()
    while not anl.isAnalyzed() do
		os.sleep(0.2)
	end
    isUpdated = updateSeedMaxData(letEqualUpdate)
    if isMaxedOut()then
      takeFromAnlzer()
      left()
      seedMaxedOut()
    end
    takeFromAnlzer()
    return isUpdated
  end
  return false
end
function redstoneOn()
  return redstone.setOutput("bottom",true)
end
function redstoneOff()
  return redstone.setOutput("bottom",false)
end


function placeSticks(tablePos)
  move(tablePos)
  print("Placing sticks")
  if sticks() then
      print(lang_placingStick) 
      lastSelected = select(slot.sticks1)
      t.placeDown()
      select(lastSelected)
  end
end
function breakStick(tablePos)
  move(tablePos)
  print("Breaking sticks")
  t.digDown()
end
function placeSticksInActv(tablePos,doubleSticks)
  print("Placing sticks in right clicky machine")
  move(tablePos)
    if doubleSticks then
      sticks()
      dropDownFromSlot(slot.sticks1,1)
    end
    sticks()
    dropDownFromSlot(slot.sticks1,1)
    redstoneOn()
    sleep(redstoneSleep)
  redstoneOff()
end

function dropSeedsInActv(tablePos)
  move(tablePos)
  print("Placing seeds in right clicky machine")
  redstoneOn()
    --------dropDownFromSlot(slot.rake,64)
    --------sleep(redstoneSleep)
    --------suckDownInSlot(slot.rake,64)
    dropDownFromSlot(slot.seed,1)
    sleep(redstoneSleep)
  redstoneOff()
  suckDownInSlot(12,64)
  if checkCount(12,1) then
    transferItem(12,slot.seed)
    print("Weeds detected ")
    return false
  end
  return true
end

function placeSeeds(seedPosTbl,actvPosTbl)
  placeSticks(seedPosTbl,false)
  while not dropSeedsInActv(actvPosTbl) do
    breakStick(seedPosTbl)
    placeSticks(seedPosTbl,false)
  end
end

function waitForSeedToGrow()
  move(pos.anlzer)
  print("Waiting for seeds to grow")
  local anl = wrapAnlzer()
  while not anl.hasPlant("WEST") do
    if anl.hasWeeds("WEST") then
      print("Removing weeds")
      breakStick(pos.seed[2])
      placeSticksInActv(pos.actv[2],true)
      move(pos.anlzer)
    end
    sleep(1)
  end
  breakStick(pos.seed[2])
  return true
end

function trashSeed()
  move(pos.bin)
  print("Trashing seeds")
  --print(lang_)
  if compareItemInSlot(seed.name,slot.extra) then
    dropDownFromSlot(slot.extra,64)
  elseif compareItemInSlot(seed.name,slot.sticks2) then
    dropDownFromSlot(slot.sticks2,64)
  else
    dropDownFromSlot(slot.seed,64)
  end
end
function trashItem(slot)
  move(pos.bin)
  print("Trashing item")
  dropDownFromSlot(slot,64)
end
function storeYeld()
  move(pos.chest)
  print("Storing yeld")
  if not compareItemInSlot(seed.name,slot.extra) then
    dropDownFromSlot(slot.extra,64)
  elseif not compareItemInSlot("AgriCraft:cropsItem",slot.sticks2) then
    dropDownFromSlot(slot.sticks2,64)
  else
    dropDownFromSlot(slot.extra,64)
  end
end

----------------------------------------------------
--------------INVENTORY CONTROLLLER-----------------
----------------------------------------------------
function select(slot)
  lastSl = t.getSelectedSlot()
  t.select(slot)
  return lastSl
end
function count(slot)
    return t.getItemCount(slot)
end
function checkCount(slot,number)
  if count(slot) >= number then
    return true
  end
  return false
end
function dropDown(number)
    return t.dropDown(number)
end
function dropDownFromSlot(slot,number)
    lastSelected = select(slot)
    if dropDown(number) then
        select(lastSelected)
        return true
    end
    select(lastSelected)
    return false
end
function suckDown(number)
    return t.suckDown(number)
end
function suckDownInSlot(slot,number)
    lastSelected = select(slot)
    if suckDown(number) then
        t.select(lastSelected)
        return true
    end
    select(lastSelected)
    return false
end
-----------------------------------------------
function transferItem(fromSlot,toSlot)
  lastSl = select(fromSlot)
  t.transferTo(toSlot,64)
  select(lastSl)
end
function compareItemInSlot(item,slot)
  local itemInfo = t.getItemDetail(slot)
  if itemInfo ~= nil then
    --print("Comparing: "..item.." AND: "..itemInfo.name)
    if item == itemInfo.name then
      return true
    end
  end
  return false
end
function matchItemInSlot(item,slot)
  itemInfo = turtle.getItemDetail(slot)
  if itemInfo.name == item then
   return true
  end
  return false
end
------------------------------------------------------
------------------TURTLE CHECKS-----------------------
------------------------------------------------------

function fuel()
   lastSelected = 	t.getSelectedSlot()
   if t.getFuelLevel() < 70 then
        lastSelected = select(slot.fuel)
       if t.refuel(slot.fuel) then
        select(lastSelected)
        return true
       else
        noFuel()
        t.select(lastSelected)
       end
   end
    return true
end

function tidySticks()
  if compareItemInSlot("AgriCraft:cropsItem",slot.sticks1) then
    return true
  else
    if compareItemInSlot("AgriCraft:cropsItem",slot.sticks2) then
      transferItem(slot.sticks2,slot.sticks1)
      return true
    end
  end
  return false
end
function sticks()
  if tidySticks() then
    return true
  end
  noSticks()
  return true
end
function seeds()
  local seedCount = count(slot.seed)
  if seedCount > 2 then
    tooManySeeds()
  elseif seedCount == 2 or seedCount == 1 then
    if analyze() then
      local lastSelected = select(slot.seed)
      local seedInfo = t.getItemDetail()
      select(lastSelected)
      seed.name = seedInfo.name
      print("Seed set to: "..seed.name)
      return seedCount
    end
  end
  return 0
end
function rake()
  if compareItemInSlot("AgriCraft:handRake",slot.rake) then
    return true
  end
  noRake()
  return true
end
------------------------------------------------
-------------------MESSAGES---------------------
------------------------------------------------
function noFuel()
    while not t.refuel(slot.fuel) do
      resetScreen()
      print (lang_noFuel)
      sleep(1)
    end
end
function noSticks()
    while not tidySticks() do
      resetScreen()
      print (lang_noSticks)
      sleep(1)
    end
end
function noRake()
  while not compareItemInSlot("AgriCraft:handRake",slot.rake) do
    resetScreen()
    print(lang_noRake)
    sleep(1)
  end
  return true
end
function noSeeds()
  while not checkCount(slot.seed,1) do
    resetScreen()
    print(lang_noSeed)
    sleep(1)
  end
  if seeds() >= 1 then
    resetScreen()
    return count(slot.seed)
  else
    noSeeds()
  end
end
function tooManySeeds()
    while checkCount(slot.seed,3) do
      resetScreen()
      print (lang_manySeeds)
      sleep(1)
    end
    return true
end

function seedMaxedOut()
  print(lang_maxedOut)
  error()
end

------------------------------------------------------
-----------------TURTLE MOVEMENT----------------------
------------------------------------------------------
function forward(n)
  for i = 1,n do
   fuel()
   t.forward()
  end
end
function back(n)
  for i = 1,n do
   fuel()
   t.back()
  end
end
function left(n)
   fuel()
   t.turnLeft()
  for i = 1,n do
   fuel()
   t.forward()
  end
   t.turnRight()
end
function right(n)
   fuel()
   t.turnRight()
  for i = 1,n do
   fuel()
   t.forward()
  end
   t.turnLeft()
end

function move(x,z)
  if z == nil then
    tbl = x
    --print("tbl "..tbl.x.." "..tbl.y.." "..tbl.z.." " )
    --print("tbl pos "..pos.x.." "..pos.y.." "..pos.z.." " )
    x = tbl.x - pos.x
    z = tbl.z - pos.z
    --print("tbl AFTER "..tbl.x.." "..tbl.y.." "..tbl.z.." " )
  else
    --print("not tbl "..x.." "..y.." "..z.." " )
    --print("not tbl pos "..pos.x.." "..pos.y.." "..pos.z.." " )
    x = x - pos.x
    z = z - pos.z
    --print("not tbl AFTER "..x.." "..y.." "..z.." " )
    --print("------------------------------------" )
  end
  if x > 0 then
    right(x)
    sleep(0.1)
  end
  if x < 0 then
    left(math.abs(x))
    sleep(0.1)
  end
  if z > 0 then
    back(z)
    sleep(0.1)
  end
  if z < 0 then
    forward(math.abs(z))
    sleep(0.1)
  end
  pos.x = pos.x + x
  pos.z = pos.z + z
  --savePos()
end
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------


resetScreen()
seedRepl = 0
select(1)
function main()
  resetScreen()
  if fuel() and sticks() then
    numOfSeeds = seeds()
    --seedName = getSeedName()
    --print("Seed set to: "..seedName)
    if numOfSeeds == 0 then
      numOfSeeds = noSeeds()
    end
    if numOfSeeds == 1 then
      placeSeeds(pos.seed[0],pos.actv[0])
      placeSticksInActv(pos.actv[2],true)
      waitForSeedToGrow()
      analyze(true)
      placeSeeds(pos.seed[1],pos.actv[1])
    end
    if numOfSeeds == 2 then
      placeSeeds(pos.seed[0],pos.actv[0])
      placeSeeds(pos.seed[1],pos.actv[1])
    end
    while not isMaxedOut() do
      --removeWeedsLoop(posTable)
      placeSticksInActv(pos.actv[2],true)
      waitForSeedToGrow()
      breakStick(pos.seed[2])
      if analyze() then
        if seedRepl > 1 then
          seedRepl = 0
        end
        breakStick(pos.seed[seedRepl])
        placeSeeds(pos.seed[seedRepl],pos.actv[seedRepl])
        trashSeed()
        storeYeld()
        seedRepl = seedRepl + 1
      else
        trashSeed()
      end
    end
  end
end --MAIN END
--replaceSticks(pos.seed[2])
--trashSeed()
--storeYeld()
main()
