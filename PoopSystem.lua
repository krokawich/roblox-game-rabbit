-- PoopSystem - появление какашек от кроликов и их сбор
-- Кролики оставляют какашки, игроки их собирают и продают

local PoopSystem = {}
local Config = require(script.Parent:WaitForChild("Config"))

-- Папка для какашек
local POOP_FOLDER_NAME = "Poop"

-- Получить папку для какашек
local function GetPoopFolder()
	local workspace = game:GetService("Workspace")
	local folder = workspace:FindFirstChild(POOP_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = POOP_FOLDER_NAME
		folder.Parent = workspace
	end
	return folder
end

-- Определить тип какашки по вероятности
local function GetRandomPoopType(rabbitRarity)
	local rarityData = Config.RabbitRarities[rabbitRarity]
	if not rarityData then
		rarityData = Config.RabbitRarities.Common
	end

	-- Вероятность редких какашек зависит от редкости кролика
	local rand = math.random()
	local threshold = rarityData.rarePoopChance

	if rand < threshold * 0.01 then -- Diamond - самая редкая
		return "Diamond"
	elseif rand < threshold * 0.05 then -- Rainbow
		return "Rainbow"
	elseif rand < threshold * 0.2 then -- Golden
		return "Golden"
	elseif rand < threshold * 0.5 then -- Silver
		return "Silver"
	else -- Brown - обычная
		return "Brown"
	end
end

-- Создать одну какашку
local function CreatePoop(position, poopType)
	local poopFolder = GetPoopFolder()

	-- Part для какашки (маленький коричневый шарик)
	local poop = Instance.new("Part")
	poop.Name = "Poop_" .. poopType
	poop.Shape = Enum.PartType.Ball
	poop.Size = Vector3.new(0.3, 0.3, 0.3)
	poop.TopSurface = Enum.SurfaceType.Smooth
	poop.BottomSurface = Enum.SurfaceType.Smooth
	poop.CanCollide = true
	poop.CFrame = CFrame.new(position + Vector3.new(0, 1, 0)) -- спаунить выше земли

	-- Установить цвет по типу какашки
	local poopData = Config.PoopTypes[poopType]
	if poopData then
		poop.Color = poopData.color
	else
		poop.Color = Color3.fromRGB(139, 69, 19)
	end

	-- Сохранить тип какашки
	local typeValue = Instance.new("StringValue")
	typeValue.Name = "PoopType"
	typeValue.Value = poopType
	typeValue.Parent = poop

	-- Добавить TouchInterest для детекции касания
	poop.TopSurface = Enum.SurfaceType.Smooth
	poop.BottomSurface = Enum.SurfaceType.Smooth

	poop.Parent = poopFolder

	-- Удалить какашку через 5 минут если её никто не собрал
	spawn(function()
		wait(300)
		if poop.Parent then
			poop:Destroy()
		end
	end)

	return poop
end

-- Кролик оставляет какашку
function PoopSystem:RabbitPoops(rabbit, rabbitRarity)
	if not rabbit or not rabbit.Parent then return end

	-- Определить тип какашки
	local poopType = GetRandomPoopType(rabbitRarity)

	-- Создать какашку рядом с кроликом
	local offset = Vector3.new(
		math.random(-2, 2),
		0,
		math.random(-2, 2)
	)
	local poopPosition = rabbit.Position + offset

	CreatePoop(poopPosition, poopType)
end

-- Собрать какашку (при касании игроком)
function PoopSystem:CollectPoop(poop, player)
	if not poop or not poop.Parent then return false end

	local typeValue = poop:FindFirstChild("PoopType")
	if not typeValue then return false end

	local poopType = typeValue.Value
	local poopData = Config.PoopTypes[poopType]

	if not poopData then return false end

	-- Удалить какашку
	poop:Destroy()

	-- Вернуть стоимость
	return poopData.price, poopType
end

-- Запустить автоматическое производство какашек от кролика
function PoopSystem:StartRabbitProduction(rabbit, rabbitRarity)
	if not rabbit or not rabbit.Parent then return end

	spawn(function()
		while rabbit.Parent and rabbit.Parent:IsDescendantOf(game) do
			-- Кролик оставляет какашку каждые 5-10 секунд
			local interval = math.random(5, 10)
			wait(interval)

			if rabbit.Parent then
				self:RabbitPoops(rabbit, rabbitRarity)
			end
		end
	end)
end

-- Получить все какашки на карте
function PoopSystem:GetAllPoop()
	local folder = GetPoopFolder()
	if folder then
		return folder:GetChildren()
	end
	return {}
end

-- Инициализировать систему
function PoopSystem:Init()
	print("[PoopSystem] Инициализирована")
end

return PoopSystem
