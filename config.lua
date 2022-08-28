Config                 = {}
Config.DrawDistance    = 100.0
Config.MaxErrors       = 5
Config.SpeedMultiplier = 3.6
Config.Locale          = 'es'

Config.Prices = {
	pmv  = 35000,
	aircraft = 50000,
	helicopter = 40000,
}

Config.VehicleModels = {
	aircraft      = 'velum',
	helicopter  = 'havok',
}

Config.Zones = {

	DMVSchool = {
		Pos   = {x = -941.57, y = -2955.22, z = 12.95},
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1
	},

	VehicleSpawnPoint = {
		Pos   = {x = -979.37, y = -2996.94, z = 12.95, h = 59.43},
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = -1
	}

}

Config.CheckPoints = {

	{
		Pos = {x = -1131.34, y = -2903.53, z = 25.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('next_point_speed'), 5000)
		end
	},

	{
		Pos = {x = -1313.07, y = -2796.63, z = 35.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = {x = -1366.59, y = -2424.62, z = 45.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},

	{
		Pos = {x = -1269.94, y = -2201.03, z = 45.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = {x = -1576.39, y = -2246.26, z = 45.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},

	-- {
	-- 	Pos = {x = -1770.27, y = -2635.12, z = 40.537},
	-- 	Action = function(playerPed, vehicle, setCurrentZoneType)
	-- 		DrawMissionText(_U('go_next_point'), 5000)
	-- 	end
	-- },

	{
		Pos = {x = -1639.32, y = -2602.2, z = 40.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},

	{
		Pos = {x = -1402.32, y = -2875.2, z = 36.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},

	{
		Pos = {x = -988.37, y = -2994.88, z = 15.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			ESX.Game.DeleteVehicle(vehicle)
		end
	},
}
