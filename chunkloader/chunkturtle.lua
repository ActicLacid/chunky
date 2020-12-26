local SLOT_COUNT = 16

function getItemIndex(name)
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] == name) then
                return slot
            end
        end
    end
    return nil
end
function getEnderType(count)
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] == "enderstorage:ender_storage" and item["count"] == count) then
                return slot
            end
        end
    end
    return nil
end
function checkFuel()
    turtle.select(1)
    
    if(turtle.getFuelLevel() < 50) then
        local index = getEnderType(3)
        if (index ~= nil) then
            turtle.select(index)
            if(turtle.detectUp()) then
				turtle.digUp()
			end
            turtle.placeUp()
            turtle.suckUp()
            turtle.select(getItemIndex("minecraft:lava_bucket"))
            turtle.refuel()
            turtle.dropUp()
			turtle.select(index)
            turtle.digUp()
            return true
        end
        return false
    else
        return true
    end
end
function openEnder(index)
	turtle.select(index)
    if(turtle.detectUp()) then
		turtle.digUp()
	end
    turtle.placeUp()
    turtle.suckUp(1)
	turtle.digUp()
end
function depositEnder(index, itemIndex)
	turtle.select(index)
    if(turtle.detectUp()) then
		turtle.digUp()
	end
    turtle.placeUp()
    turtle.select(itemIndex)
    turtle.dropUp()
    turtle.select(index)
	turtle.digUp()
end
function placeChest()
	local index = getEnderType(2)
	if(index ~= nil) then
		openEnder(index)
		turtle.select(getItemIndex("minecraft:chest"))
		turtle.place()
	end
end
function placeHopper()
	local index = getEnderType(1)
	if(index ~= nil) then
		openEnder(index)
		turtle.select(getItemIndex("minecraft:hopper"))
		turtle.place()
	end
end
function loadChunk()
	checkFuel()
	placeChest()
	turtle.back()
	placeHopper()
	turtle.up()
	turtle.up()
	turtle.forward()
	turtle.forward()
	turtle.down()
	turtle.digDown()
	local index = getItemIndex("minecraft:chest")
	if(index ~= nil) then
		local item = getItemDetail(index)
		if (item["count"] >= 5) then
		depositEnder(getEnderType(2), index)
		end
	end
	index = getItemIndex("minecraft:hopper")
	if(index ~= nil) then
		item = getItemDetail(index)
		if (item["count"] >= 5) then
		depositEnder(getEnderType(1), index)
		end
	end
	turtle.down()
end
function getOrientation()
    loc1 = vector.new(gps.locate(2, false))
    if not turtle.forward() then
        for j=1,6 do
            if not turtle.forward() then
            	checkFuel()
                turtle.dig()
            else 
                break 
            end
        end
    end
    loc2 = vector.new(gps.locate(2, false))
    heading = loc2 - loc1
    turtle.down()
    turtle.down()
    return ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
    end
 
 
function turnToFaceHeading(heading, destinationHeading)
    if(heading > destinationHeading) then
        for t = 1, math.abs(destinationHeading - heading), 1 do 
            turtle.turnLeft()
        end
    elseif(heading < destinationHeading) then
        for t = 1, math.abs(destinationHeading - heading), 1 do 
            turtle.turnRight()
        end
    end
end
 
function setHeadingZ(zDiff, heading)
    local destinationHeading = heading
    if(zDiff < 0) then
        destinationHeading = 2
    elseif(zDiff > 0) then
        destinationHeading = 4
    end
    turnToFaceHeading(heading, destinationHeading)
 
    return destinationHeading
end
 
function setHeadingX(xDiff, heading)
    local destinationHeading = heading
    if(xDiff < 0) then
        destinationHeading = 1
    elseif(xDiff > 0) then
        destinationHeading = 3
    end
 
    turnToFaceHeading(heading, destinationHeading)
    return destinationHeading
end
 
function digAndMove(n, heading)
    for x = 1, n, 1 do
    	local xpos, ypos, zpos = gps.locate()
        while(turtle.detect()) do
           turtle.dig()
        end
        if(heading%2 == 1) then
        	if((heading - 2 < 0)  and (xpos%16 == 0)) then
        		loadChunk()
        	elseif((heading - 2 > 0) and (xpos%16 == 15)) then
        		loadChunk()
        	end
        else
        	if(heading - 3 < 0 and zpos%16 == 0) then
        		loadChunk()
        	elseif(heading - 3 > 0 and zpos%16==0) then
        		loadChunk()
        	end
        end
        turtle.forward()
        checkFuel()
    end
end
function digAndReturn(n)
    for x = 1, n, 1 do
    	local xpos, ypos, zpos = gps.locate()
        while(turtle.detect()) do
           	turtle.dig()
           	local index = getItemIndex("minecraft:hopper")
           	if (index ~= nil) then
           		local item = turtle.getItemDetail(index)
           		if (item["count"] >= 20) then
           			depositEnder(getEnderType(1), index)
           		end
            end
        end
        turtle.forward()
        checkFuel()
    end
end
function parseParams(data)
    coords = {}
    params = split(data, " ")
    
    coords[1] = vector.new(params[1], params[2], params[3])
    coords[2] = vector.new(params[4], params[5], params[6])
    coords[3] = vector.new(params[7], params[8], params[9])
 
    return (coords)
end
function moveTo(coords, heading)
	print(heading)
	startcoords = vector.new(gps.locate())
    local currX, currY, currZ = gps.locate()
    local xDiff, yDiff, zDiff = coords.x - currX, coords.y - currY, coords.z - currZ
    print(string.format("Distances from start: %d %d %d", xDiff, yDiff, zDiff))
 
    --    -x = 1
    --    -z = 2
    --    +x = 3
    --    +z = 4
    
    -- Move to X start
    heading = setHeadingX(xDiff, heading)
    print(heading)
    digAndMove(math.abs(xDiff), heading)
 
    -- Move to Z start
    heading = setHeadingZ(zDiff, heading)
    digAndMove(math.abs(zDiff), heading)

 
    return heading
end

function returnTo(coords, heading)
    local currX, currY, currZ = gps.locate()
    local xDiff, yDiff, zDiff = coords.x - currX, coords.y - currY, coords.z - currZ
    print(string.format("Distances from end: %d %d %d", xDiff, yDiff, zDiff))
    
    -- Move to Z start
    heading = setHeadingZ(zDiff, heading)
    digAndReturn(math.abs(zDiff))
    -- Move to X start
    heading = setHeadingX(xDiff, heading)
    digAndReturn(math.abs(xDiff))

    
    
    

    return heading
end
startcoords = vector.new(gps.locate())
local finalHeading = moveTo(vector.new(-91,162,232), getOrientation())
turtle.turnLeft()
turtle.turnLeft()
returnTo(startcoords, getOrientation())
local hoppers = getItemIndex("minecraft:hopper")
if(hoppers ~= nil) then
	depositEnder(getEnderType(1), hoppers)
end
-- pastebin run wPtGKMam acticlacid chunky / /chunkloader/ .
