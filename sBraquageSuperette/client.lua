local currentPed
local object = {}
local ESX = nil
soundid = GetSoundId()

Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(lib) ESX = lib end)
    while ESX == nil do Citizen.Wait(100) end
end)

RegisterNetEvent('peelo:msgPolice')
AddEventHandler('peelo:msgPolice', function(store, robber)
	ESX.ShowAdvancedNotification("Superette", 'Vol en cours', "J'me fais braquer mon êpicerie ! HELP", "CHAR_CALL911", 4)
    ESX.ShowNotification('~b~F3~s~ Accepter ~o~G~s~ Refuser')
    while true do
        if IsControlPressed(0, 170) then
            SetNewWaypoint(BrakConfig.shops[store].coords.x, BrakConfig.shops[store].coords.y)
            return
        elseif IsControlPressed(0, 47) then
            return
        end
        Wait(0)
    end
end)


peds = {}


function _CreatePed(hash, coords, heading)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(5)
    end
    local ped = CreatePed(4, hash, coords, false, false)
    SetEntityHeading(ped, heading)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedHearingRange(ped, 0.0)
    SetPedSeeingRange(ped, 0.0)
    SetEntityInvincible(ped, true)
    SetPedAlertness(ped, 0.0)
    FreezeEntityPosition(ped, true) 
    SetPedFleeAttributes(ped, 0, 0)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, 0)
    return ped
end

local holdup = false

Citizen.CreateThread(function()    
    for k, v in pairs(BrakConfig.shops) do
        peds[k] = _CreatePed(v.ped, v.coords, v.heading)
    end
	while true do
		Wait(500)
        local ped = PlayerPedId()
        local pos =  GetEntityCoords(ped)
		for k, v in pairs(peds) do
            currentPed = k
            local dist = Vdist(pos, GetEntityCoords(peds[k]))    
		    if dist < 5 and not IsPedDeadOrDying(peds[k]) then
                if BrakConfig.shops[k].rbs == false then 

                    if IsPedArmed(ped, 4) and not holdup then 
                        count = math.random(BrakConfig.shops[k].packet[1], BrakConfig.shops[k].packet[2])
                        holdup = true
                        TriggerServerEvent('policemess', k)
                        TriggerServerEvent("startholdup", "start", k) 
                        braquage(k)
                    end
                    
                    if IsPedArmed(ped, 1) and not holdup then 
                        local chance = math.random(BrakConfig.chance[1], BrakConfig.chance[2])

                        if chance == 1 then 
                            count = math.random(BrakConfig.shops[k].packet[1], BrakConfig.shops[k].packet[2])
                            holdup = true
                            TriggerServerEvent('policemess', k)
                            TriggerServerEvent("startholdup", "start", k)
                            braquage(k) 
                        else
                            TriggerServerEvent('policemess', k)
                            SetPedAccuracy(peds[k], BrakConfig.PedAccuracy)
                            local weapon  = GetHashKey("weapon_ceramicpistol")
                            SetPedVisualFieldPeripheralRange(peds[k], 6)
                            GiveWeaponToPed(peds[k], weapon, 8, false, true)
                            TaskShootAtEntity(peds[k], PlayerPedId(), 5000, 0x5EF9FEC4)
                            Wait(BrakConfig.timeinterval)
                            RemoveWeaponFromPed(peds[k], weapon)
                        end 
                    end
                end

            end 
		end 
	end
end)

Citizen.CreateThread(function()
    while true do 
        time = 500
        if holdup then 
            time = 0
            local pos =  GetEntityCoords(PlayerPedId())
            local dist = Vdist(pos, GetEntityCoords(peds[currentPed]))  
            if dist > 15 then 
                stopbraquage(currentPed)
            end 
        end 
        Wait(time)
    end 
end)

local objeto = {}
local objetos = {}

local moneypack = false

count = nil

function braquage(result) 
    if count ~= 0 and holdup then 
            PlaySoundFromCoord(soundid, "VEHICLES_HORNS_AMBULANCE_WARNING", BrakConfig.shops[result].coords)
            ESX.Streaming.RequestAnimDict("mp_am_hold_up", function()
                TaskPlayAnim(peds[result], "mp_am_hold_up","handsup_base", 8.0, -8.0, 19000, 19000, 0, false, false, false)
            end)
            Citizen.Wait(7000)
            ESX.Streaming.RequestAnimDict("mp_am_hold_up", function()
                TaskPlayAnim(peds[result], "mp_am_hold_up","handsup_base", 8.0, -8.0, 19000, 19000, 0, false, false, false)
            end)
            Citizen.Wait(9000)
            ClearPedTasks(peds[result])
            spawnmoneypack(result)
            

            moneypack = true
            count = count - 1 
            Citizen.CreateThread(function()    
                while true do
                    Wait(0)
                    if moneypack then
                        local pos = GetEntityCoords(PlayerPedId())
                        local dist = Vdist(pos, BrakConfig.shops[result].coords) 
                        if dist < 3 then 
                            ESX.ShowHelpNotification("Appuyez sur ~INPUT_TALK~ pour prendre ~r~l'argent")
                            if IsControlPressed(0, 51) then 
                                ESX.Streaming.RequestAnimDict("random@domestic", function()
                                    TaskPlayAnim(PlayerPedId(), "random@domestic", "pickup_low", 8.0, -8.0, -1, 0, 0.0, false, false, false)
                                end)
                                PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, -1)
                                for k, v in pairs(objetos) do
                                    DeleteObject(objetos[k].name)
                                end
                                moneypack = false
                                local pricemoney = math.random(BrakConfig.shops[result].money[1], BrakConfig.shops[result].money[2])
                                TriggerServerEvent('addsale', pricemoney)
                                drawsub('~r~Braquage~s~ : + ~b~'..pricemoney..'$~s~.', 2000)
                            end
                        end   
                    end
                end 
            end)
        braquage(result)
    else
        stopbraquage(result)
    end
end

RegisterNetEvent('allplayers_cldwn_cl')
AddEventHandler('allplayers_cldwn_cl', function(type, shop)
    if type == "start" then
        BrakConfig.shops[shop].rbs = true
    elseif type == "end" then 
        BrakConfig.shops[shop].rbs = false
    end
end)



function stopbraquage(result)
    TriggerServerEvent("startholdup", "end", result) 
    ESX.ShowNotification("~r~Braquage terminé")
    holdup = false
    StopSound(soundid)
    TriggerServerEvent("allplayers_cldwn", "end", result)
end

function spawnmoneypack(result)
    TaskPlayAnim(peds[result], "mp_am_hold_up","purchase_cigarette_shopkeeper", 8.0, -8.0, -1, 2, 0, false, false, false)
    objeto = CreateObject(GetHashKey("prop_anim_cash_pile_01"), BrakConfig.shops[result].coords, true, true, true)
    table.insert(objetos, {name = objeto})
    NetworkRegisterEntityAsNetworked(objeto) 
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(objeto, true))
    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(objeto, true))
    SetEntityAsMissionEntity(objeto)
    AttachEntityToEntity(objeto, peds[result], GetPedBoneIndex(peds[result],  28422), 0.0, -0.03, 0.0, 90.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    Wait(3000)
    DetachEntity(objeto, true, false)
end

function drawsub(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, true)
end