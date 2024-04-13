QBCore = exports["qb-core"]:GetCoreObject()

local blips = {}
local zoneState = false
local ZoneLeader = {}
local outside = GetGameTimer()
local willChange = false
local inZone = false
local Polys = {}
local Combos = {}

function DrawTimerBar2(title, text, barIndex)
	local width = 0.13
	local hTextMargin = 0.003
	local rectHeight = 0.038
	local textMargin = 0.008
	
	local rectX = GetSafeZoneSize() - width + width / 2
	local rectY = GetSafeZoneSize() - rectHeight + rectHeight / 2 - (barIndex - 1) * (rectHeight + 0.005)
	
	DrawSprite("timerbars", "all_black_bg", rectX, rectY, width, 0.038, 0, 0, 0, 0, 128)
	
	DrawTimerBarText(title, GetSafeZoneSize() - width + hTextMargin, rectY - textMargin, 0.32)
	DrawTimerBarText(string.upper(text), GetSafeZoneSize() - hTextMargin, rectY - 0.0175, 0.5, true, width / 2)
end

function DrawTimerBarText(text, x, y, scale, right, width)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(254, 254, 254, 255)

	if right then
		SetTextWrap(x - width, x)
		SetTextRightJustify(true)
	end
	
	BeginTextCommandDisplayText("STRING")	
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y)
end

function saniyeToDakika(saniye)
    local dakika = math.floor(saniye / 60)
    local saniye_kalan = math.floor(saniye % 60)
    return string.format("%d:%02d", dakika, saniye_kalan)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        if NetworkGetEntityOwner(PlayerPedId()) and IsPedAPlayer(PlayerPedId()) then
            TriggerServerEvent("bolge:GetZone")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if zoneState then
            willChange = true
            for k,v in pairs(Combos) do
                local isInside, insideZone = v:isPointInside(GetEntityCoords(PlayerPedId()))
                if isInside then
                    inZone = k
                    TriggerServerEvent("bolge:InZone", k)
                    willChange = false
                    break
                end
            end
            if willChange == true then
                TriggerServerEvent("bolge:LeftZone")
                inZone = false
                ZoneLeader = {}
                outside = GetGameTimer()
            end
        else
            inZone = false
            ZoneLeader = {}
            outside = GetGameTimer()
        end
        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(10000)
    while true do
        if inZone then
            DrawTimerBar2("Süre", saniyeToDakika(math.floor(GetGameTimer() - outside) / 1000), 1)
            if ZoneLeader[inZone] then
                if math.floor(GetGameTimer() - outside) < ZoneLeader[inZone] then
                    DrawTimerBar2("Hedef Süre", saniyeToDakika(ZoneLeader[inZone] / 1000), 2)
                end
            else
                DrawTimerBar2("Hedef Süre", saniyeToDakika(Config.takeTime / 1000), 2)
            end
        end
        Citizen.Wait(1)
    end
end)

RegisterCommand('testmenu', function()
    if inZone then
        TriggerServerEvent("bolge:caseStatus", inZone)
    end
end)

RegisterNetEvent('bolge:AddZone')
AddEventHandler('bolge:AddZone', function()
    if zoneState == false then
        for k,v in pairs(Config.Zones) do

            for _k, _v in pairs(v.Poly) do
                if Polys[k] == nil then Polys[k] = {} end
                if blips[k] == nil then blips[k] = {} end
                table.insert(Polys[k], _k, BoxZone:Create(_v.center, _v.lenght, _v.width, {
                    name = _v.name,
                    heading = _v.rotation,
                    debugPoly = _v.debugPoly,
                }))

                local radius = AddBlipForArea(_v.center, _v.width, _v.lenght)
        
                SetBlipAlpha(radius, 128)
                SetBlipHighDetail(radius, true)
                SetBlipColour(radius, v.radiusColour)
                SetBlipRotation(radius, _v.rotation)
                SetBlipAsShortRange(radius, true)
    
                table.insert(blips[k], _k, radius)
            end

            if #Polys[k] > 1 then
                Combos[k] = ComboZone:Create(Polys[k], {name=v.Biliptitle, debugPoly=true})
            end
        end
        zoneState = true
        willChange = false
        outside = GetGameTimer()
        inZone = false
        ZoneLeader = {}
    end
end)

RegisterNetEvent('bolge:OpenMenu')
AddEventHandler('bolge:OpenMenu', function(money, zone)
    if inZone then
        lib.registerMenu({
            id = 'some_menu_id',
            title = 'Bölge Kasası',
            position = 'top-right',
            options = {
                {label = 'Kasa: '..tostring(money)..'$'},
                {label = 'Para Çek: ?'},
            }
        }, function(selected, scrollIndex, args)
            if selected == 2 then
                local input = lib.inputDialog('Bölge kasası', {
                    {type = 'number', label = 'Ne kadar çekmek istiyorsun ?', description = 'Miktarı gir.', required = true, min = 1, max = money},
                })
                if not input then return end
                TriggerServerEvent("bolge:TakeMoney", zone, tonumber(json.encode(input[1])))
            end
        end)
        
        lib.showMenu('some_menu_id')
    end
end)

RegisterNetEvent('bolge:UpdateZone')
AddEventHandler('bolge:UpdateZone', function(zoneId, data)
    if blips[zoneId] ~= nil then
        for k,v in pairs(blips[zoneId]) do
            SetBlipColour(v, data.colour)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(data.title)
            EndTextCommandSetBlipName(v)
        end
    end
end)

RegisterNetEvent('bolge:ZoneStatus')
AddEventHandler('bolge:ZoneStatus', function(status)
    for k,v in pairs(status) do
        if v == true then
            for _k,_v in pairs(blips[k]) do
                Citizen.CreateThread(function ()
                    SetBlipColour(_v, 25)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 1)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 25)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 1)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 25)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 1)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 25)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 1)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 25)
                    Citizen.Wait(1000)
                    SetBlipColour(_v, 1)
                end)
            end
        end
    end
end)

RegisterNetEvent('bolge:RemoveZone')
AddEventHandler('bolge:RemoveZone', function()
    if zoneState then
        for k,v in pairs(blips) do
            for _k,_v in pairs(v) do
                RemoveBlip(_v)
            end
        end
        for k,v in pairs(Combos) do
            v:destroy()
        end
        blips = {}
        zoneState = false
        willChange = false
        outside = GetGameTimer()
        inZone = false
        ZoneLeader = {}
        Polys = {}
        Combos = {}
        TriggerServerEvent("bolge:LeftZone", inZone)
    end
end)

RegisterNetEvent('bolge:ZoneTimeInfo')
AddEventHandler('bolge:ZoneTimeInfo', function(timer)
    ZoneLeader[inZone] = timer
end)