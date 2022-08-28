ESX                     = nil
local CurrentAction     = nil
local CurrentActionMsg  = nil
local CurrentActionData = nil
local Licenses          = {}
local CurrentTest       = nil
local CurrentTestType   = nil
local CurrentVehicle    = nil
local CurrentCheckPoint, DriveErrors = 0, 0
local LastCheckPoint    = -1
local CurrentBlip       = nil
local CurrentZoneType   = nil
local IsAboveSpeedLimit = false
local LastVehicleHealth = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function DrawMissionText(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, true)
end

function StartTheoryTest()
	CurrentTest = 'theory'

	SendNUIMessage({
		openQuestion = true
	})

	ESX.SetTimeout(200, function()
		SetNuiFocus(true, true)
	end)

	
end

function StopTheoryTest(success)
	CurrentTest = nil

	SendNUIMessage({
		openQuestion = false
	})

	SetNuiFocus(false)

	if success then
		TriggerServerEvent('xex_pilotschool:addLicense', 'pmv')
		ESX.ShowNotification(_U('passed_test'))
	else
		ESX.ShowNotification(_U('failed_test'))
	end
end

function StartDriveTest(type)
	ESX.TriggerServerCallback('xex_pilotschool:payLicense', function(paid)
		if paid == true then
			ESX.Game.SpawnVehicle(Config.VehicleModels[type], Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Pos.h, function(vehicle)
				CurrentTest       = 'drive'
				CurrentTestType   = type
				CurrentCheckPoint = 0
				LastCheckPoint    = -1
				CurrentZoneType   = 'residence'
				DriveErrors       = 0
				IsAboveSpeedLimit = false
				CurrentVehicle    = vehicle
				LastVehicleHealth = GetEntityHealth(vehicle)
		
				local playerPed   = PlayerPedId()
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleFuelLevel(vehicle, 100 + 0.0)
				SetVehicleCustomPrimaryColour(vehicle, 255, 255, 255)
				DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
			end)
			ESX.ShowNotification(_U('exam_paid'))
		else
			ESX.ShowNotification(_U('no_money'))
		end
	end, Config.Prices[type])

end

function StopDriveTest(success)
	if success then
		TriggerServerEvent('xex_pilotschool:addLicense', CurrentTestType)
		ESX.ShowNotification(_U('passed_test'))
	else
		ESX.ShowNotification(_U('failed_test'))
	end

	CurrentTest     = nil
	CurrentTestType = nil
end

function SetCurrentZoneType(type)
CurrentZoneType = type
end

function OpenDMVSchoolMenu()
	local ownedLicenses = {}

	for i=1, #Licenses, 1 do
		ownedLicenses[Licenses[i].type] = true
	end

	local elements = {}

	if not ownedLicenses['pmv'] then
		table.insert(elements, {
			label = (('%s: <span style="color:green;">%s</span>'):format(_U('theory_test'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['pmv'])))),
			value = 'theory_test'
		})
	end

	if ownedLicenses['pmv'] then
		if not ownedLicenses['aircraft'] then
			table.insert(elements, {
				label = (('%s: <span style="color:green;">%s</span>'):format(_U('road_test_aircraft'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['aircraft'])))),
				value = 'drive_test',
				type = 'aircraft'
			})
		end

		if not ownedLicenses['helicopter'] then
			table.insert(elements, {
				label = (('%s: <span style="color:green;">%s</span>'):format(_U('road_test_heli'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['helicopter'])))),
				value = 'drive_test',
				type = 'helicopter'
			})
		end

	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dmvschool_actions', {
		title    = _U('driving_school'),
		elements = elements,
		align    = 'bottom-right',
	}, function(data, menu)
		if data.current.value == 'theory_test' then
			menu.close()
			StartTheoryTest()
		elseif data.current.value == 'drive_test' then
			menu.close()
			StartDriveTest(data.current.type)
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'dmvschool_menu'
		CurrentActionMsg  = _U('press_open_menu')
		CurrentActionData = {}
	end)
end

RegisterNUICallback('question', function(data, cb)
	TriggerServerEvent('xex_pilotschool:pay', Config.Prices['pmv'])
	SendNUIMessage({
		openSection = 'question'
	})

	cb()
end)

RegisterNUICallback('close', function(data, cb)
	StopTheoryTest(true)
	cb()
end)

RegisterNUICallback('kick', function(data, cb)
	StopTheoryTest(false)
	cb()
end)

AddEventHandler('xex_pilotschool:hasEnteredMarker', function(zone)
	if zone == 'DMVSchool' then
		CurrentAction     = 'dmvschool_menu'
		CurrentActionMsg  = _U('press_open_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('xex_pilotschool:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

RegisterNetEvent('xex_pilotschool:loadLicenses')
AddEventHandler('xex_pilotschool:loadLicenses', function(licenses)
	Licenses = licenses
end)

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)
    SetBlipSprite(blip, 251)
    SetBlipColour(blip,  4)
	SetBlipScale  (blip, 1.1)
	SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_U('driving_school'))
    EndTextCommandSetBlipName(blip)

end)

-- Display markers
Citizen.CreateThread(function()
	local awaitBucle = false
	while true do
		Citizen.Wait(0)
		if not awaitBucle then
			local coincidencia = false
			local coords = GetEntityCoords(PlayerPedId())

			for k,v in pairs(Config.Zones) do
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					coincidencia = true
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
			if coincidencia == false then
				awaitBucle = true
			end
		else
			Citizen.Wait(2500)
			awaitBucle = false
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	local awaitBucle = false
	while true do

		Citizen.Wait(100)
		if not awaitBucle then
			local coincidencia = false

			local coords      = GetEntityCoords(PlayerPedId())
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					coincidencia = true
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('xex_pilotschool:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('xex_pilotschool:hasExitedMarker', LastZone)
			end
			if coincidencia == false then
				awaitBucle = true
			end
		else
			Citizen.Wait(2500)
			awaitBucle = false
		end
	end
end)

-- Block UI
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		if CurrentTest == 'theory' then
			local playerPed = PlayerPedId()

			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisablePlayerFiring(playerPed, true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		else
			Citizen.Wait(2500)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'dmvschool_menu' then
					OpenDMVSchoolMenu()
				end

				CurrentAction = nil
			end
		else
			Citizen.Wait(1500)
		end
	end
end)

-- Drive test
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentTest == 'drive' then
			local playerPed      = PlayerPedId()
			local coords         = GetEntityCoords(playerPed)
			local nextCheckPoint = CurrentCheckPoint + 1

			if Config.CheckPoints[nextCheckPoint] == nil then
				if DoesBlipExist(CurrentBlip) then
					RemoveBlip(CurrentBlip)
				end

				CurrentTest = nil

				ESX.ShowNotification(_U('driving_test_complete'))

				if DriveErrors < Config.MaxErrors then
					StopDriveTest(true)
				else
					StopDriveTest(false)
				end
			else

				if CurrentCheckPoint ~= LastCheckPoint then
					if DoesBlipExist(CurrentBlip) then
						RemoveBlip(CurrentBlip)
					end

					CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
					SetBlipRoute(CurrentBlip, 1)

					LastCheckPoint = CurrentCheckPoint
				end

				local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)

				if distance <= 250.0 then
					DrawMarker(6, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 7.5, 7.5, 4.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
				end

				if distance <= 7.0 then
					Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
					CurrentCheckPoint = CurrentCheckPoint + 1
				end

				local firstErrorDistance = true
				if distance > 450.0 and firstErrorDistance == true then
					firstErrorDistance = false
					ESX.ShowNotification(_U('air_zone'))
					DriveErrors = DriveErrors + 1
				end

				if distance > 575.0 then
					ESX.ShowNotification(_U('air_zone_exited'))
					endTest()
				end
			end
		else
			-- not currently taking driver test
			Citizen.Wait(2500)
		end
	end
end)

-- Speed / Damage control
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if CurrentTest == 'drive' then

			local playerPed = PlayerPedId()

			if IsPedInAnyVehicle(playerPed, false) then

				local vehicle      = GetVehiclePedIsIn(playerPed, false)
				local speed        = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
				local tooMuchSpeed = false

				if not tooMuchSpeed then
					IsAboveSpeedLimit = false
				end

				local health = GetEntityHealth(vehicle)
				if health < LastVehicleHealth then

					DriveErrors = DriveErrors + 1

					ESX.ShowNotification(_U('you_damaged_veh'))
					ESX.ShowNotification(_U('errors', DriveErrors, Config.MaxErrors))

					-- avoid stacking faults
					LastVehicleHealth = health
					Citizen.Wait(1500)
				end
			end
		else
			-- not currently taking driver test
			Citizen.Wait(2500)
		end
	end
end)

function endTest()

	local playerPed = PlayerPedId()
	local vehicle      = GetVehiclePedIsIn(playerPed, false)
	DoScreenFadeOut(1000)
	while not IsScreenFadedOut() do
		Citizen.Wait(500)
	end
	ESX.Game.DeleteVehicle(vehicle)
	ESX.Game.Teleport(playerPed, { x = -952.59, y= -2961.2, z= 12.95 })
	DoScreenFadeIn(800)
	ESX.ShowNotification(_U('failed_test'))
	if DoesBlipExist(CurrentBlip) then
		RemoveBlip(CurrentBlip)
	end
	CurrentAction     = nil
	CurrentActionMsg  = nil
	CurrentActionData = nil
	CurrentTest       = nil
	CurrentTestType   = nil
	CurrentVehicle    = nil
	CurrentCheckPoint, DriveErrors = 0, 0
	LastCheckPoint    = -1
	CurrentBlip       = nil
	CurrentZoneType   = nil

end
