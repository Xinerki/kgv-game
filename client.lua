
local turnSpeedMult = 5.0
local offset = 0.0
local angle = 0.0 + offset
local gameX = 0.5
local gameY = 0.5
-- RequestStreamedTextureDict("kgvgame") -- TODO: fix.
RequestStreamedTextureDict("helicopterhud")
function translateAngle(x1, y1, ang, offset)
  x1 = x1 + math.sin(ang) * offset
  y1 = y1 + math.cos(ang) * offset
  return {x1, y1}
end
map = {}
players = {}
-- players[1] = {
	-- angle = 0.0,
	-- gameX = 0.15,
	-- gameY = 0.55,
-- }

--[[

	Task list:
	[x] Simple map
	[ ] Collision detection (round)
	[x] Collision detection (square)
	[ ] Texture loading
	[ ] Sync

]]

testMap = {
	testBox = {
		objectType = "rectangle",
		position = vector2(0.25, 0.25),
		size = vector2(0.2, 0.1),
		colorR = 255,
		colorG = 100,
		colorB = 200,
	},
	
	testBox2 = {
		objectType = "rectangle",
		position = vector2(0.75, 0.25),
		size = vector2(0.1, 0.3),
		colorR = 100,
		colorG = 255,
		colorB = 200,
	},
	
	testCircle = {
		objectType = "circle",
		position = vector2(0.75, 0.75),
		size = 0.1,
		colorR = 255,
		colorG = 25,
		colorB = 255,
	},
	
	testWarning = {
		objectType = "errorTest",
		position = vector2(0.5, 0.5),
	},
}

arena = {
	leftBox = {
		objectType = "rectangle",
		position = vector2(0.05, 0.5),
		size = vector2(0.1, 1.0),
		colorR = 155,
		colorG = 155,
		colorB = 155,
	},
	
	rightBox = {
		objectType = "rectangle",
		position = vector2(1.0-0.05, 0.5),
		size = vector2(0.1, 1.0),
		colorR = 155,
		colorG = 155,
		colorB = 155,
	},
}

RegisterNetEvent("game:sendSync")
AddEventHandler("game:sendSync", function(playerId, angle, posX, posY)
	if playerId == GetPlayerServerId(PlayerId()) then return end
	players[playerId] = {
		angle = angle,
		gameX = posX,
		gameY = posY,
	}
end)

Citizen.CreateThread(function()
	while true do
		TriggerServerEvent("game:receiveSync", angle, gameX, gameY)
		Citizen.Wait(50)
	end
end)

function LoadMap(theMap)
	for i,v in pairs(theMap) do
		if v.objectType == "rectangle" or v.objectType == "circle" then
			if type(v.position) == "vector2" then
				if type(v.size) == "vector2" then
					Citizen.Trace("NeXbox: Loaded object "..i)
				elseif type(v.size) == "number" then
					Citizen.Trace("NeXbox: Loaded object "..i.." as unimplemeneted circle, ignoring.")
					-- Citizen.Trace(type(v.size))
				end
			end
		else
			Citizen.Trace("NeXbox: Unknown object "..i.." type \""..v.objectType.."\", ignoring.")
		end
	end
	return theMap
end

function ProcessGameplay()
	local upSpeed = GetControlNormal(0, 172) / -50.0
	local downSpeed = GetControlNormal(0, 173) / -50.0
	local forwardSpeed = upSpeed - downSpeed
	local leftSpeed = GetControlNormal(0, 174)
	local rightSpeed = GetControlNormal(0, 175)
	
	local turnSpeed = 0.0 - leftSpeed + rightSpeed
	angle = angle + (turnSpeed * turnSpeedMult)
	
	gameX, gameY = table.unpack(translateAngle(gameX, gameY, math.rad(-angle+offset), forwardSpeed))
	
	SetTextFont(2)
	SetTextProportional(1)
	SetTextScale(0.0, 0.75)
	SetTextColour(170, 82, 255, 255)
	SetTextEntry("STRING")
	SetTextCentre(1)
	-- AddTextComponentString(tostring(angle..'\n'..math.floor(gameX*20)/20 ..' '..math.floor(gameY*20)/20 ..'\n'..forwardSpeed))
	AddTextComponentString("DEGENATRON")
	DrawText(0.5, 0.15)	
	SetTextFont(2)
	SetTextProportional(1)
	SetTextScale(0.0, 0.75)
	SetTextColour(240, 151, 63, 255)
	SetTextEntry("STRING")
	SetTextCentre(1)
	-- AddTextComponentString(tostring(angle..'\n'..math.floor(gameX*20)/20 ..' '..math.floor(gameY*20)/20 ..'\n'..forwardSpeed))
	AddTextComponentString("DEGENATRON")
	DrawText(0.5+0.005, 0.15+0.005)
	
	if angle >= 360.0 then angle = 0.0 end
	if angle <= -360.0 then angle = 0.0 end
	if gameX > 1.0 then gameX = 0.0 end
	if gameX < 0.0 then gameX = 1.0 end
	if gameY > 1.0 then gameY = 0.0 end
	if gameY < 0.0 then gameY = 1.0 end
	
	for i,v in pairs(map) do
		if v.objectType == "rectangle" then
			DrawRect(v.position, v.size, v.colorR, v.colorG, v.colorB, 255)
			
			local ox, oy = table.unpack(v.position)
			local sx, sy = table.unpack(v.size)
			if gameX > (ox - (sx/2)) and gameX < (ox + (sx/2)) then
				if gameY > (oy - (sy/2)) and gameY < (oy + (sy/2)) then
				
					if gameX < (ox + (sx/4)) and gameY > (oy + (sy/4)) == false and gameY < (oy - (sy/4)) == false then
						-- HIT LEFT SIDE
						gameX = (ox - (sx/2))
					elseif gameX > (ox - (sx/4)) and gameY > (oy + (sy/4)) == false and gameY < (oy - (sy/4)) == false then
						-- HIT RIGHT SIDE
						gameX = (ox + (sx/2))
					end
					
					if gameY > (oy + (sy/4)) then
						-- HIT BOTTOM
						gameY = (oy + (sy/2))
					elseif gameY < (oy - (sy/4)) then
						-- HIT TOP
						gameY = (oy - (sy/2))
					end
					
				end
			end
			
		elseif v.objectType == "circle" then
			--NOT IMPLEMENTED YET
		end
	end
	
	for i,v in pairs(players) do
		DrawSprite( "helicopterhud", "hudarrow", v.gameX, v.gameY, 0.05, 0.05, v.angle, 255, 155, 155, 255 )
	
		-- SetTextFont(0)
		-- SetTextProportional(1)
		-- SetTextScale(0.0, 0.25)
		-- SetTextColour(255, 255, 255, 255)
		-- SetTextDropshadow(0, 0, 0, 0, 255)
		-- SetTextEdge(2, 0, 0, 0, 150)
		-- SetTextDropShadow()
		-- SetTextOutline()
		-- SetTextEntry("STRING")
		-- SetTextCentre(1)
		-- AddTextComponentString(tostring(v))
		-- DrawText(0.25, 0.5)
	end

	-- if HasStreamedTextureDictLoaded("kgvgame") then
		DrawSprite( "helicopterhud", "hudarrow", gameX, gameY, 0.05, 0.05, angle, 155, 155, 255, 255 )
		DrawSprite( "helicopterhud", "hudarrow", gameX+1.0, gameY, 0.05, 0.05, angle, 155, 155, 255, 255 )
		DrawSprite( "helicopterhud", "hudarrow", gameX, gameY+1.0, 0.05, 0.05, angle, 155, 155, 255, 255 )
		DrawSprite( "helicopterhud", "hudarrow", gameX-1.0, gameY, 0.05, 0.05, angle, 155, 155, 255, 255 )
		DrawSprite( "helicopterhud", "hudarrow", gameX, gameY-1.0, 0.05, 0.05, angle, 155, 155, 255, 255 )
	-- end
end

Citizen.CreateThread(function()
	map = LoadMap(testMap)
	while true do
		iVar0 = 608950395
		if (not IsNamedRendertargetRegistered("ex_tvscreen")) then
			RegisterNamedRendertarget("ex_tvscreen", 0)
			LinkNamedRendertarget(iVar0)
			if (not IsNamedRendertargetLinked(iVar0)) then
				-- ReleaseNamedRendertarget("ex_tvscreen")
				-- return false
			end
		end
		iLocal_186 = GetNamedRendertargetRenderId("ex_tvscreen")
		SetTextRenderId(iLocal_186)
		ProcessGameplay()
		SetTextRenderId(GetDefaultScriptRendertargetRenderId())
		Citizen.Wait(0)
	end
end)