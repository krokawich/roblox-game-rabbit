-- CurrencySystem - управление деньгами игрока
-- Все операции с деньгами проходят через сервер
-- Защита от эксплойтов на клиенте

local CurrencySystem = {}
local Players = game:GetService("Players")

-- Хранилище денег в памяти (для быстрого доступа)
local playerMoney = {}

-- Инициализировать деньги игрока при входе
function CurrencySystem:InitializePlayer(player, startingMoney)
	playerMoney[player.UserId] = startingMoney or 100
	return playerMoney[player.UserId]
end

-- Получить текущие деньги (только для сервера)
function CurrencySystem:GetMoney(player)
	if not playerMoney[player.UserId] then
		self:InitializePlayer(player, 100)
	end
	return playerMoney[player.UserId]
end

-- Добавить деньги (безопасно, с проверками)
function CurrencySystem:AddMoney(player, amount)
	if not player or not amount then return false end
	if amount < 0 then
		warn("Попытка добавить отрицательное количество денег")
		return false
	end

	if not playerMoney[player.UserId] then
		self:InitializePlayer(player, 100)
	end

	playerMoney[player.UserId] = playerMoney[player.UserId] + amount
	return true
end

-- Вычесть деньги (с проверкой баланса)
function CurrencySystem:RemoveMoney(player, amount)
	if not player or not amount then return false end
	if amount < 0 then
		warn("Попытка вычесть отрицательное количество денег")
		return false
	end

	if not playerMoney[player.UserId] then
		self:InitializePlayer(player, 100)
	end

	-- Проверка баланса
	if playerMoney[player.UserId] < amount then
		warn(player.Name .. " пытается потратить больше денег чем есть")
		return false
	end

	playerMoney[player.UserId] = playerMoney[player.UserId] - amount
	return true
end

-- Установить деньги (только для администраторов/системы)
function CurrencySystem:SetMoney(player, amount)
	if not player or amount < 0 then return false end
	playerMoney[player.UserId] = amount
	return true
end

-- Очистить данные при выходе
function CurrencySystem:ClearPlayer(player)
	playerMoney[player.UserId] = nil
end

return CurrencySystem
