QBCore = exports["qb-core"]:GetCoreObject()
load(LoadResourceFile(GetCurrentResourceName(), "config.lua"))()

local zones = false
local time = 0000
local zonesLeaders = {}
local zonesData = {}
local zoneStatus = {}

function checkJson()
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "zoneData.json")
    local extract = json.decode(loadFile)
    for i=1,#Config.Zones,1 do 
        if extract[i] == nil then
            table.insert(extract, i, ({title = Config.Zones[i].Biliptitle, owner = "none", case = 0, lastUpdate = os.time(os.date("!*t"))}))
        end
    end
    SaveResourceFile(GetCurrentResourceName(), "zoneData.json", json.encode(extract), -1)
end

Citizen.CreateThread(function()
    while true do
        time = tonumber(os.date("%H%M"))
        if Config.zStart < Config.zEnd then
            if time > Config.zStart and time < Config.zEnd then
                zones = true
            else
                if zones then
                    TriggerClientEvent("bolge:RemoveZone", -1)
                end
                zonesLeaders = {}
                zonesData = {}
                zoneStatus = {}
                zones = false
            end
        else
            if (time < Config.zStart and time < Config.zEnd) or time > Config.zStart then
                zones = true
            else
                if zones then
                    TriggerClientEvent("bolge:RemoveZone", -1)
                end
                zonesLeaders = {}
                zonesData = {}
                zoneStatus = {}
                zones = false
            end
        end
        Citizen.Wait(60000)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        checkJson()
        local loadFile = LoadResourceFile(GetCurrentResourceName(), "zoneData.json")
        local extract = json.decode(loadFile)
        for k,v in pairs(zonesLeaders) do
            local player = QBCore.Functions.GetPlayer(v.leader)
            if player ~= nil then
                if extract[k].owner ~= player.PlayerData.job.name then
                    extract[k].case = 0
                    extract[k].lastUpdate = os.time(os.date("!*t"))
                end
                extract[k].owner = player.PlayerData.job.name
            end
        end
        for i=1,#extract,1 do 
            if extract[i].owner ~= "none" then
                if (os.time(os.date("!*t")) - extract[i].lastUpdate) > Config.updateZoneCaseTime then
                    extract[i].case = extract[i].case + Config.updateZoneCaseAmount
                    extract[i].lastUpdate = os.time(os.date("!*t"))
                end
                TriggerClientEvent("bolge:UpdateZone", -1, i, Config.JobColours[extract[i].owner])
            end
        end
        SaveResourceFile(GetCurrentResourceName(), "zoneData.json", json.encode(extract), -1)
    end
end)

Citizen.CreateThread(function()
    while true do
        if zones then
            for k,v in pairs(zonesData) do
                if zonesData[k]["jobs"] == nil then 
                    zonesData[k]["jobs"] = {} 
                end
                for __k, __v in pairs(zonesData[k]["jobs"]) do
                    if #__v >= Config.playerNeeded then
                        zoneStatus[k] = true
                    else
                        zoneStatus[k] = false
                    end
                end
                for _k,_v in pairs(v) do
                    if zonesLeaders[k] == nil then zonesLeaders[k] = {} end
                    if DoesPlayerExist(_k) == false then
                        zonesData[k][_k] = nil
                    else
                        if zonesLeaders[k].leader == _k and GetGameTimer() - _v > zonesLeaders[k].leaderTime then
                            zonesLeaders[k].leaderTime = GetGameTimer() - _v
                        end
                        if _v < (zonesData[k][zonesLeaders[k].leader] or GetGameTimer()) and GetGameTimer() - _v > Config.takeTime then
                            zonesLeaders[k].leader = _k
                            zonesLeaders[k].leaderTime = GetGameTimer() - _v
                        end
                    end
                end
            end
        end
        Citizen.Wait(5000)
    end
end)

AddEventHandler('bolge:GetZone')
RegisterNetEvent('bolge:GetZone', function()
    local src = source
    if zones then
        local player = QBCore.Functions.GetPlayer(src)
        if player ~= nil then
            for k,v in pairs(Config.WhiteJobs) do
                if v == player.PlayerData.job.name then
                    TriggerClientEvent("bolge:AddZone", src)
                    TriggerClientEvent("bolge:ZoneStatus", src, zoneStatus)
                    return
                end
            end
            TriggerClientEvent("bolge:RemoveZone", src)
        end
    end
end)

AddEventHandler('bolge:InZone')
RegisterNetEvent('bolge:InZone', function(zoneId)
    local src = source
    if zones then
        if zonesLeaders[zoneId] ~= nil and zonesLeaders[zoneId].leaderTime ~= nil then
            TriggerClientEvent("bolge:ZoneTimeInfo", src, zonesLeaders[zoneId].leaderTime)
        end
        if zonesData[zoneId] == nil or zonesData[zoneId][src] == nil then
            if zonesData[zoneId] == nil then zonesData[zoneId] = {} end
            zonesData[zoneId][src] = GetGameTimer()
        end
        local player = QBCore.Functions.GetPlayer(src)
        if player ~= nil then
            if zonesData[zoneId]["jobs"] == nil then zonesData[zoneId]["jobs"] = {} end
            if zonesData[zoneId]["jobs"][player.PlayerData.job.name] == nil then zonesData[zoneId]["jobs"][player.PlayerData.job.name] = {} end
            zonesData[zoneId]["jobs"][player.PlayerData.job.name][src] = true
        end
    end
end)

AddEventHandler('bolge:LeftZone')
RegisterNetEvent('bolge:LeftZone', function()
    local src = source
    if zones then
        for k,v in pairs(zonesData) do
            zonesData[k][src] = nil
            local player = QBCore.Functions.GetPlayer(src)
            if zonesData[k]["jobs"] == nil then return end
            if zonesData[k]["jobs"][player.PlayerData.job.name] == nil then return end
            if zonesData[k]["jobs"][player.PlayerData.job.name][src] and player ~= nil then
                zonesData[k]["jobs"][player.PlayerData.job.name][src] = nil
            end
        end
    end
end)

AddEventHandler('bolge:caseStatus')
RegisterNetEvent('bolge:caseStatus', function(zone)
    local src = source
    if zonesData[zone][src] then
        local loadFile = LoadResourceFile(GetCurrentResourceName(), "zoneData.json")
        local extract = json.decode(loadFile)
        local player2 = QBCore.Functions.GetPlayer(src)
        if extract[zone].owner == player2.PlayerData.job.name then
            TriggerClientEvent("bolge:OpenMenu", src, extract[zone].case, zone)
        end
    end
end)

AddEventHandler('bolge:TakeMoney')
RegisterNetEvent('bolge:TakeMoney', function(zone, amount)
    local src = source
    if zonesData[zone][src] then
        local loadFile = LoadResourceFile(GetCurrentResourceName(), "zoneData.json")
        local extract = json.decode(loadFile)
        local player2 = QBCore.Functions.GetPlayer(src)
        if extract[zone].owner == player2.PlayerData.job.name then
            if amount > extract[zone].case then return end
            extract[zone].case = extract[zone].case - amount
            local bank = player2.PlayerData.money
            player2.Functions.SetMoney('cash', bank["cash"] + amount)
            SaveResourceFile(GetCurrentResourceName(), "zoneData.json", json.encode(extract), -1)
        end
    end
end)
