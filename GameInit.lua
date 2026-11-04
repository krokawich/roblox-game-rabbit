-- GameInit.lua - главный скрипт инициализации всей игры
-- Запускается один раз при старте сервера
-- Инициализирует все системы в правильном порядке

local GameInit = {}

-- Импортируем все системы
local Config = require(script.Parent:WaitForChild("Config"))
local DataService = require(script.Parent:WaitForChild("DataService"))
local CurrencySystem = require(script.Parent:WaitForChild("CurrencySystem"))
local PlayerManager = require(script.Parent:WaitForChild("PlayerManager"))

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

	print("[GameInit] Сервер полностью инициализирован ✓")
	print("=" .. string.rep("=", 48) .. "=")
	print("ИГРА ГОТОВА К ИГРЕ")
	print("=" .. string.rep("=", 48) .. "=")
end

-- Запускаем инициализацию
GameInit:Start()

return GameInit
