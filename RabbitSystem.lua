-- RabbitSystem - управление дикими кроликами
-- Кролики ходят, прыгают, оставляют какашки, убегают от игрока

local RabbitSystem = {}
local Config = require(script.Parent:WaitForChild("Config"))
local Players = game:GetService("Players")

-- Папка для кроликов
local RABBIT_FOLDER_NAME = "WildRabbits"

-- Получить папку для кроликов
local function GetRabbitFolder()
	local workspace = game:GetService("Workspace")
	local folder = workspace:FindFirstChild(RABBIT_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = RABBIT_FOLDER_NAME
		folder.Parent = workspace
	end
	return folder
end

-- Создать одного дикого кролика
local function CreateWildRabbit(spawnPosition, rarity)
	local rabbitFolder = GetRabbitFolder()

	-- Создаём Part (временная модель)
	local rabbit = Instance.new("Part")
	rabbit.Name = "Rabbit_" .. rarity
	rabbit.Shape = Enum.PartType.Ball
	rabbit.Size = Vector3.new(1, 1, 1)
	rabbit.TopSurface = Enum.SurfaceType.Smooth
	rabbit.BottomSurface = Enum.SurfaceType.Smooth
	rabbit.CanCollide = true
	rabbit.CFrame = CFrame.new(spawnPosition)

	-- Установить цвет по редкости
	local rarityData = Config.RabbitRarities[rarity]
	if rarityData then
		rabbit.Color = rarityData.color
	else
		rabbit.Color = Color3.fromRGB(100, 100, 100)
	end

	-- Добавить физику (Humanoid для симуляции поведения)
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = rabbit
	humanoid.MaxHealth = 100
	humanoid.Health = 100

	-- Сохранить информацию о кролике
	local info = Instance.new("StringValue")
	info.Name = "RabbitInfo"
	info.Value = rarity
	info.Parent = rabbit

	rabbit.Parent = rabbitFolder

	-- Запустить поведение кролика
	SpawnRabbitBehavior(rabbit, rarity)

	return rabbit
end

-- Поведение кролика (прыжки, ходьба, побег)
function SpawnRabbitBehavior(rabbit, rarity)
	local rarityData = Config.RabbitRarities[rarity]
	if not rarityData then return end

	-- Параметры поведения зависят от редкости
	local speed = 15 + (rarityData.catchDifficulty * 5) -- чем выше редкость, тем быстрее
	local jumpHeight = 20 + (rarityData.catchDifficulty * 5)
	local detectionRadius = 30 + (rarityData.catchDifficulty * 10)
	local changeDirectionInterval = 3 - (rarityData.catchDifficulty * 0.3) -- редкие быстрее меняют направление

	spawn(function()
		while rabbit.Parent and rabbit.Parent:IsDescendantOf(game) do
			-- Случайное направление
			local randomDirection = Vector3.new(
				math.random(-1, 1),
				0,
				math.random(-1, 1)
			).Unit

			-- Движение в течение интервала
			local moveStartTime = tick()
			while tick() - moveStartTime < changeDirectionInterval and rabbit.Parent do
				-- Проверяем близость игрока
				local nearestPlayer = nil
				local nearestDistance = math.huge

				for _, player in pairs(Players:GetPlayers()) do
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local playerPos = player.Character.HumanoidRootPart.Position
						local distance = (rabbit.Position - playerPos).Magnitude

						if distance < detectionRadius and distance < nearestDistance then
							nearestPlayer = player
							nearestDistance = distance
						end
					end
				end

				-- Если игрок близко - убегаем
				if nearestPlayer and nearestDistance < detectionRadius then
					local playerPos = nearestPlayer.Character.HumanoidRootPart.Position
					local escapeDirection = (rabbit.Position - playerPos).Unit
					randomDirection = escapeDirection
				end

				-- Применяем движение
				if rabbit:FindFirstChild("BodyVelocity") == nil then
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
					bodyVelocity.Velocity = randomDirection * speed
					bodyVelocity.Parent = rabbit
				else
					rabbit.BodyVelocity.Velocity = randomDirection * speed
				end

				wait(0.1)
			end

			-- Прыжок
			if rabbit:FindFirstChild("BodyVelocity") then
				rabbit.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				rabbit.BodyVelocity.Velocity = rabbit.BodyVelocity.Velocity + Vector3.new(0, jumpHeight, 0)
				wait(0.3)
				rabbit.BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
			end

			wait(0.5)
		end
	end)
end

-- Спаунить кроликов на карте
function RabbitSystem:SpawnRabbits(spawnZone, count)
	for i = 1, count do
		-- Случайная редкость
		local rarity = self:GetRandomRarity()

		-- Случайная позиция в зоне
		local randomOffset = Vector3.new(
			math.random(-spawnZone.x/2, spawnZone.x/2),
			0,
			math.random(-spawnZone.z/2, spawnZone.z/2)
		)
		local spawnPos = spawnZone.Position + randomOffset

		CreateWildRabbit(spawnPos, rarity)
		wait(0.1)
	end
end

-- Получить случайную редкость по вероятности
function RabbitSystem:GetRandomRarity()
	local rand = math.random()
	local accumulated = 0

	for rarity, data in pairs(Config.RabbitRarities) do
		accumulated = accumulated + data.spawnChance
		if rand <= accumulated then
			return rarity
		end
	end

	return "Common"
end

-- Получить все живых кроликов
function RabbitSystem:GetAllRabbits()
	local folder = GetRabbitFolder()
	if folder then
		return folder:GetChildren()
	end
	return {}
end

-- Инициализировать систему
function RabbitSystem:Init()
	print("[RabbitSystem] Инициализирована")
end

return RabbitSystem
