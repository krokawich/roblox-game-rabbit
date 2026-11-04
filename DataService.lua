-- DataService - сохранение и загрузка данных через DataStore
-- Обрабатывает все ошибки, повторные попытки, защиту от потери данных

local DataService = {}
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Настройки
local RETRY_COUNT = 3
local RETRY_DELAY = 2
local DATA_STORE_NAME = "BunnyWorldData_v1"

-- Структура данных игрока по умолчанию
local function GetDefaultPlayerData()
	return {
		Money = 100,
		Scoops = {}, -- {type = "Common", count = 1}
		Collection = {}, -- {rabbitType = "name", rarity = "Common", count = 1}
		BaseLevel = 1,
		PlayTime = 0,
		LastPlayed = os.time(),
	}
end

-- Получить DataStore с повторными попытками
local function GetDataStore()
	local success = false
	local dataStore = nil

	for i = 1, RETRY_COUNT do
		success, dataStore = pcall(function()
			return DataStoreService:GetDataStore(DATA_STORE_NAME)
		end)

		if success then
			return dataStore
		end

		if i < RETRY_COUNT then
			wait(RETRY_DELAY)
		end
	end

	warn("DataStore недоступен после " .. RETRY_COUNT .. " попыток")
	return nil
end

-- Безопасно загрузить данные игрока
function DataService:LoadPlayerData(userId)
	local dataStore = GetDataStore()
	if not dataStore then
		return GetDefaultPlayerData()
	end

	local success = false
	local data = nil

	for i = 1, RETRY_COUNT do
		success, data = pcall(function()
			return dataStore:GetAsync("Player_" .. userId)
		end)

		if success then
			-- Если данных нет - возвращаем дефолт
			if data == nil then
				return GetDefaultPlayerData()
			end

			-- Проверяем структуру (защита от битых данных)
			if type(data) == "table" and data.Money then
				return data
			end

			return GetDefaultPlayerData()
		end

		if i < RETRY_COUNT then
			wait(RETRY_DELAY)
		end
	end

	warn("Не удалось загрузить данные игрока " .. userId)
	return GetDefaultPlayerData()
end

-- Безопасно сохранить данные игрока
function DataService:SavePlayerData(userId, data)
	local dataStore = GetDataStore()
	if not dataStore then
		warn("DataStore недоступен, данные не сохранены")
		return false
	end

	local success = false

	for i = 1, RETRY_COUNT do
		success = pcall(function()
			dataStore:SetAsync("Player_" .. userId, data)
		end)

		if success then
			return true
		end

		if i < RETRY_COUNT then
			wait(RETRY_DELAY)
		end
	end

	warn("Не удалось сохранить данные игрока " .. userId)
	return false
end

-- Безопасно обновить одно поле
function DataService:UpdatePlayerField(userId, field, value)
	local data = self:LoadPlayerData(userId)
	data[field] = value
	return self:SavePlayerData(userId, data)
end

-- Безопасно увеличить число (защита от потери при конфликтах)
function DataService:IncrementPlayerValue(userId, field, amount)
	local dataStore = GetDataStore()
	if not dataStore then
		return false
	end

	local success = false

	for i = 1, RETRY_COUNT do
		success = pcall(function()
			dataStore:UpdateAsync("Player_" .. userId, function(previousData)
				if previousData == nil then
					previousData = GetDefaultPlayerData()
				end

				if type(previousData[field]) == "number" then
					previousData[field] = previousData[field] + amount
				end

				return previousData
			end)
		end)

		if success then
			return true
		end

		if i < RETRY_COUNT then
			wait(RETRY_DELAY)
		end
	end

	warn("Не удалось обновить " .. field .. " для игрока " .. userId)
	return false
end

return DataService
