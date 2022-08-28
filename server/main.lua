ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('esx:playerLoaded', function(source)
	TriggerEvent('esx_license:getLicenses', source, function(licenses)
		TriggerClientEvent('xex_pilotschool:loadLicenses', source, licenses)
	end)
end)

RegisterNetEvent('xex_pilotschool:addLicense')
AddEventHandler('xex_pilotschool:addLicense', function(type)
	local _source = source

	TriggerEvent('esx_license:addLicense', _source, type, function()
		TriggerEvent('esx_license:getLicenses', _source, function(licenses)
			TriggerClientEvent('xex_pilotschool:loadLicenses', _source, licenses)
		end)
	end)
end)

RegisterNetEvent('xex_pilotschool:pay')
AddEventHandler('xex_pilotschool:pay', function(price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeMoney(price)
	TriggerClientEvent('esx:showNotification', _source, _U('you_paid', ESX.Math.GroupDigits(price)))
end)

ESX.RegisterServerCallback('xex_pilotschool:payLicense', function(source, cb, price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if xPlayer.getMoney() > price then
		xPlayer.removeMoney(price)
		cb(true)
	elseif xPlayer.getAccount('bank').money > price then
		xPlayer.removeAccountMoney('bank', price)
		cb(true)
	else
		cb(false)
	end

end)
