
RegisterServerEvent("game:receiveSync")
AddEventHandler("game:receiveSync", function(angle, playerX, playerY)
	TriggerClientEvent("game:sendSync", -1, source, angle, playerX, playerY)
	-- print (source)
end)