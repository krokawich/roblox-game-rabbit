-- PlayerManager - управление игроками, их спауном и базами
-- Назначает каждому игроку свою базу, загружает данные

local PlayerManager = {}
local Players = game:GetService("Players")
local DataService = require(script.Parent:WaitForChild("DataService"))
local CurrencySystem = require(script.Parent:WaitForChild("CurrencySystem"))
local Config = require(script.Parent:WaitForChild("Config"))

-- Список занятых баз
local occupiedBases = {}
local playerBases = {} -- {userId = baseNumber}

-- Спаун точки для баз (будут созданы в Studio вручную)
local BASE_SPAWN_POINTS = {
	Vector3.new(0, 5, 50),
	Vector3.new(50, 5, 50),
	Vector3.new(100, 5, 50),
	Vector3.new(-50, 5, 50),
	Vector3.new(0, 5, 100),
	Vector3.new(50, 5, 100),
	Vector3.new(100, 5, 100),
	Vector3.new(-50, 5, 100),
	Vector3.new(0, 5, -50),
	Vector3.new(50, 5, -50),
}

-- Назначить свободную базу игроку
local function AssignBase(player)
	for baseNum = 1, #BASE_SPAWN_POINTS do
		if not occupiedBases[baseNum] then
			occupiedBases[baseNum] = player.UserId
			playerBases[player.UserId] = baseNum
			return baseNum, BASE_SPAWN_POINTS[baseNum]
		end
	end

	warn("Нет свободных баз для игрока " .. player.Name)
	return nil, nil
end

-- Освободить базу при выходе
local function ReleaseBase(player)
	local baseNum = playerBases[player.UserId]
	if baseNum then
		occupiedBases[baseNum] = nil
		playerBases[player.UserId] = nil
	end
end

-- Инициализировать игрока при входе
function PlayerManager:OnPlayerAdded(player)
	print("Игрок присоединился: " .. player.Name)

	-- Загружаем данные из DataStore
	local playerData = DataService:LoadPlayerData(player.UserId)
	print("Загруженные данные: " .. playerData.Money .. " денег")

	-- Инициализируем валюту
	CurrencySystem:InitializePlayer(player, playerData.Money)

	-- Назначаем базу
	local baseNum, spawnPoint = AssignBase(player)
	if not spawnPoint then
		player:Kick("Сервер переполнен, нет свободных баз")
		return
	end

	print("Игроку " .. player.Name .. " назначена база #" .. baseNum)

	-- Спаун персонажа в центральной площади (перед назначением базы)
	-- В будущем можно телепортировать на свою базу после первого входа
	if player.Character then
		player.Character:MoveTo(Vector3.new(0, 10, 0))
	end

	-- Сохраняем информацию о базе в метаданные
	player:SetAttribute("BaseNumber", baseNum)
	player:SetAttribute("SpawnPoint", spawnPoint)
end

-- Очистить при выходе и сохранить данные
function PlayerManager:OnPlayerRemoved(player)
	print("Игрок вышел: " .. player.Name)

	-- Сохраняем деньги
	local money = CurrencySystem:GetMoney(player)
	DataService:SavePlayerData(player.UserId, {
		Money = money,
		LastPlayed = os.time(),
	})

	-- Освобождаем базу
	ReleaseBase(player)

	-- Очищаем валюту из памяти
	CurrencySystem:ClearPlayer(player)
end

-- Получить номер базы игрока
function PlayerManager:GetPlayerBase(player)
	return playerBases[player.UserId]
end

-- Получить спаун точку базы игрока
function PlayerManager:GetPlayerSpawnPoint(player)
	local baseNum = playerBases[player.UserId]
	if baseNum then
		return BASE_SPAWN_POINTS[baseNum]
	end
	return nil
end

-- Инициализировать систему
function PlayerManager:Init()
	print("Инициализация PlayerManager...")

	-- Слушаем входящих игроков
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
	end)

	-- Слушаем выходящих игроков
	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerRemoved(player)
	end)

	-- Обработаем уже подключённых игроков (на случай перезагрузки скрипта)
	for _, player in pairs(Players:GetPlayers()) do
		self:OnPlayerAdded(player)
	end

	print("PlayerManager инициализирован")
end

return PlayerManager
