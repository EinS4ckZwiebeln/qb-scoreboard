local QBCore = exports['qb-core']:GetCoreObject()
local connectedPlayers = {}

QBCore.Functions.CreateCallback('qb-scoreboard:getConnectedPlayers', function(source, cb)
	cb(connectedPlayers)
end)

RegisterNetEvent('QBCore:ToggleDuty')
AddEventHandler('QBCore:ToggleDuty', function()
	source = tonumber(source)
	local Player = QBCore.Functions.GetPlayer(source)
	local duty = Player.PlayerData.job.onduty
	if duty then
		connectedPlayers[source].job = Player.PlayerData.job.name
	else
		connectedPlayers[source].job = "offduty"
	end

	TriggerClientEvent('qb-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
end)

RegisterNetEvent('QBCore:Server:OnJobUpdate')
AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
	source = tonumber(source)
	local Player = QBCore.Functions.GetPlayer(source)
	local duty = Player.PlayerData.job.onduty
	if duty then
		connectedPlayers[source].job = Player.PlayerData.job.name
	else
		connectedPlayers[source].job = "offduty"
	end

	TriggerClientEvent('qb-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
end)

RegisterNetEvent('qb-scoreboard:spawned')
AddEventHandler('qb-scoreboard:spawned', function(source)
	Citizen.Wait(5000)
	source = tonumber(source)
	AddPlayerToScoreboard(source, true)
end)

AddEventHandler('playerDropped', function()
	Citizen.Wait(5000)
	source = tonumber(source)
	if connectedPlayers[source] then
		connectedPlayers[source] = nil
		TriggerClientEvent('qb-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		UpdatePing()
	end
end)

AddEventHandler('onResourceStart', function(name)
	if GetCurrentResourceName() == name then
		Citizen.CreateThread(function()
			Citizen.Wait(1000)
			AddPlayersToScoreboard()
		end)
	end
end)

function AddPlayerToScoreboard(source, update)
	source = tonumber(source)
	local Player = QBCore.Functions.GetPlayer(source)

	connectedPlayers[source] = {}
	connectedPlayers[source].ping = GetPlayerPing(source)
	connectedPlayers[source].id = source
	connectedPlayers[source].name = Player.PlayerData.name

	local duty = Player.PlayerData.job.onduty
	if duty then
		connectedPlayers[source].job = Player.PlayerData.job.name
	else
		connectedPlayers[source].job = "offduty"
	end

	if update then
		TriggerClientEvent('qb-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
	end
end

function AddPlayersToScoreboard()
	local players = GetPlayers()

	if #players > 0 then
		for i=1, #players, 1 do
			AddPlayerToScoreboard(players[i], false)
		end
		TriggerClientEvent('qb-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
	end
end

function UpdatePing()
	for k,v in pairs(connectedPlayers) do
		v.ping = GetPlayerPing(k)
	end
	TriggerClientEvent('qb-scoreboard:updatePing', -1, connectedPlayers)
end
