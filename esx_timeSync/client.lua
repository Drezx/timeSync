local newWeather = 'EXTRASUNNY'
local timeOffset = 0
local defBase = 0
local hour = 0
local minute = 0



AddEventHandler('playerSpawned', function()
    TriggerServerEvent('esx_timeSync:update')
end)


RegisterNetEvent('esx_timeSync:weather')
AddEventHandler('esx_timeSync:weather', function(status)
    Config.Weather = status
end)

RegisterNetEvent('esx_timeSync:time')
AddEventHandler('esx_timeSync:time', function(base, offset, freeze)
    Config.stopedTime = freeze
    timeOffset = offset
    Config.Time = base
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if newWeather ~= Config.Weather then
            newWeather = Config.Weather
            SetWeatherTypeOverTime(Config.Weather, 15.0)
            Citizen.Wait(15000)
        end
       
        if newWeather == 'XMAS' then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
        ClearOverrideWeather()
        SetWeatherTypeNow(newWeather)
        SetWeatherTypeNowPersist(newWeather)
        ClearWeatherTypePersist()
        SetWeatherTypePersist(newWeather)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local newBaseTime = Config.Time
        if Config.stopedTime then
            timeOffset = timeOffset - newBaseTime + Config.Time	
        end
        if GetGameTimer() - 3500  > defBase then
            newBaseTime = newBaseTime + 0.25
            defBase = GetGameTimer()
        end
        Config.Time = newBaseTime
        hour = math.floor(((Config.Time+timeOffset)/60)%24)
        minute = math.floor((Config.Time+timeOffset)%60)
        NetworkOverrideClockTime(hour, minute, 0)
    end
end)
