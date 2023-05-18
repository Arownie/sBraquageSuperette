local ESX

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('addsale')
AddEventHandler('addsale', function(price) 
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addMoney(price)
end)

print("[^1Auteur^0] : ^4Sly Zapesti#9737^0")

RegisterServerEvent('startholdup')
AddEventHandler('startholdup', function(type, shop)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if type == "end" then 
			local time = BrakConfig.shops[shop].cooldownseconds * 1000
        	Citizen.Wait(time) 
		end
		TriggerClientEvent('allplayers_cldwn_cl', xPlayers[i], type, shop)
	end
	TriggerEvent('Ise_Logs3', 'https://discord.com/api/webhooks/930540777371742269/j7lp5fqABtO4BUUZgzM3q1YH88AXXov4bZwrjLpwDnpiwg7IP8QYWZYTYqzbXGzYd86s', 3447003, "Gestion Braquage", xPlayer.getName().." est en train de braquer la supérette")
end)


RegisterServerEvent('policemess')
AddEventHandler('policemess', function(store) 
	local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
			TriggerClientEvent('peelo:msgPolice', xPlayer.source, store, source)
		end
	end
end)