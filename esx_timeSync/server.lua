local timeState = 0
local newWeatherTimer = 15
RegisterServerEvent('esx_timeSync:update')
AddEventHandler('esx_timeSync:update', function()
    print("\n[^5TimeSync^0] ^2" .. Config.Weather .. "\n")
    TriggerClientEvent('esx_timeSync:weather', -1, Config.Weather)
    TriggerClientEvent('esx_timeSync:time', -1, Config.Time, timeState, Config.stopedTime)
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local newBaseTime = os.time(os.date("!*t"))/8 + 720
        if Config.stopedTime then
            timeState = timeState + Config.Time - newBaseTime			
        end
        Config.Time = newBaseTime
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(15000)
        TriggerClientEvent('esx_timeSync:time', -1, Config.Time, timeState, Config.stopedTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(150000)
        TriggerClientEvent('esx_timeSync:weather', -1, Config.Weather)
    end
end)

Citizen.CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        Citizen.Wait(60000)
        if newWeatherTimer == 0 then
            if Config.stopedWeather then
                NewWeather()
            end
            newWeatherTimer = 10
        end
    end
end)

TriggerEvent('es:addGroupCommand', 'stoptime', Config.Permissions, function (source, args, user)
    Config.stopedTime = not Config.stopedTime
    if Config.stopedTime then
        TriggerClientEvent('esx:showNotification', source, 'Time is now ~y~freezed')
    else
        TriggerClientEvent('esx:showNotification', source, 'Time is now ~g~unfreezed')
    end
  end, function(source, args, user)
	  TriggerClientEvent('chat:addMessage', source, { args = { '^1TimeSync', 'No perms' } })
  end, {help = 'Stop/Start Time'})



TriggerEvent('es:addGroupCommand', 'stopweather', Config.Permissions, function (source, args, user)
    Config.stopedWeather = not Config.stopedWeather
    if not Config.stopedWeather then
        TriggerClientEvent('esx:showNotification', source, 'Freeze weather is now ~g~enabled')
    else
        TriggerClientEvent('esx:showNotification', source, 'Freeze weather is now ~r~disabled')
    end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1TimeSync', 'No perms' } })
end, {help = 'Stop/Start Weather'})
  

TriggerEvent('es:addGroupCommand', 'weather', Config.Permissions, function (source, args, user)
    if args[1] then
        for i,wtype in ipairs(Config.Weathers) do
            if wtype == string.upper(args[1]) then
                validWeatherType = true
            end
        end
        if validWeatherType then
            TriggerClientEvent('esx:showNotification', source, 'Changed to ~y~' .. string.lower(args[1]))
            Config.Weather = string.upper(args[1])
            newWeatherTimer = 10
            TriggerEvent('esx_timeSync:update')
        else
            TriggerClientEvent('chatMessage', source, 'TimeSync', {3,119,250}, '^1Invalid weather^0, type:^3 EXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN')
        end
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Invalid ~s~weather type')
    end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1TimeSync', 'No perms' } })
end, {help = 'Change Weather', params = {{name = "type", help = 'extrasunny/clear/neutral/smog/foggy/overcast/clouds/clearing/rain/thunder/snow/blizzard/snowlight/xmas/halloween'}}})
  
TriggerEvent('es:addGroupCommand', 'time', Config.Permissions, function (source, args, user)
    if tonumber(args[1]) ~= nil then
        local hours = tonumber(args[1])
        if hours < 24 then
            tsHour(hours)
        else
            tsHour(0)
        end
        local newtime = math.floor(((Config.Time+timeState)/60)%24) .. ":00"
        TriggerClientEvent('esx:showNotification', source, "New time is ~y~"..newtime)
        TriggerEvent('esx_timeSync:update')
    else
        TriggerClientEvent('chatMessage', source, 'TimeSync', {3,119,250}, '^1Invalid time^0, usage: ^3/time <1-23>')
    end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1TimeSync', 'No perms' } })
end, {help = 'Set new Time', params = {{name = "time", help = '1-23'}}})
  


function NewWeather()
    if Config.Weather == "CLEAR" or Config.Weather == "CLOUDS" or Config.Weather == "EXTRASUNNY"  then
        local new = math.random(1,2)
        if new == 1 then
            Config.Weather = "EXTRASUNNY"
        else
            Config.Weather = "CLEAR"
        end
    elseif Config.Weather == "CLEARING" or Config.Weather == "OVERCAST" then
        local new = math.random(1,5)
        if new == 1 then
            if Config.Weather == "CLEARING" then 
                Config.Weather = "FOGGY"
            else 
                Config.Weather = "RAIN" 
                newWeatherTimer = 10
            end
        elseif new == 2 then
            Config.Weather = "CLOUDS"
        elseif new == 3 then
            Config.Weather = "CLEAR"
        elseif new == 4 then
            Config.Weather = "EXTRASUNNY"
        else
            Config.Weather = "FOGGY"
        end
    elseif Config.Weather == "THUNDER" or Config.Weather == "RAIN" then
        Config.Weather = "CLEARING"
    elseif Config.Weather == "SMOG" or Config.Weather == "FOGGY" then
        Config.Weather = "CLEAR"
    end
    TriggerEvent("esx_timeSync:update")
    print("\n[^5TimeSync^0] " .. Config.Weather .. "\n")
end



function tsMin(minute)
    timeState = timeState - ( ( (Config.Time+timeState) % 60 ) - minute )
end

function tsHour(hour)
    timeState = timeState - ( ( ((Config.Time+timeState)/60) % 24 ) - hour ) * 60
end
