-- GameInit.lua - главный скрипт инициализации всей игры
-- Запускается один раз при старте сервера
-- Инициализирует все системы в правильном порядке

local GameInit = {}

-- Импортируем все системы
local Config = require(script.Parent:WaitForChild("Config"))
local DataService = require(script.Parent:WaitForChild("DataService"))
local CurrencySystem = require(script.Parent:WaitForChild("CurrencySystem"))
local PlayerManager = require(script.Parent:WaitForChild("PlayerManager"))
local RabbitSystem = require(script.Parent:WaitForChild("RabbitSystem"))
local PoopSystem = require(script.Parent:WaitForChild("PoopSystem"))

print("=" .. string.rep("=", 48) .. "=")
print("BUNNY WORLD - ИНИЦИАЛИЗАЦИЯ СЕРВЕРА")
print("=" .. string.rep("=", 48) .. "=")

-- Инициализируем системы по порядку
function GameInit:Start()
	print("[GameInit] Проверка конфигурации...")
	if not Config then
		error("Config не загружена!")
	end
	print("[GameInit] Config загружена ✓")

	print("[GameInit] Инициализация PlayerManager...")
	PlayerManager:Init()
	print("[GameInit] PlayerManager готов ✓")

	print("[GameInit] Инициализация RabbitSystem...")
	RabbitSystem:Init()
	print("[GameInit] RabbitSystem готов ✓")

	print("[GameInit] Инициализация PoopSystem...")
	PoopSystem:Init()
	print("[GameInit] PoopSystem готов ✓")

	print("[GameInit] Спаунинг диких кроликов...")
	-- Спаунить 20 кроликов в лесной зоне (временно в центре)
	local forestZone = {
		Position = Vector3.new(0, 0, -100),
		x = 200,
		z = 200
	}
	RabbitSystem:SpawnRabbits(forestZone, 20)
	print("[GameInit] 20 кроликов спауннены ✓")

	print("[GameInit] Сервер полностью инициализирован ✓")
	print("=" .. string.rep("=", 48) .. "=")
	print("ИГРА ГОТОВА К ИГРЕ")
	print("=" .. string.rep("=", 48) .. "=")
end

-- Запускаем инициализацию
GameInit:Start()

return GameInit
