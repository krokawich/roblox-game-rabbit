-- Bunny World Game Configuration
-- Все константы и настройки игры в одном месте

local Config = {}

-- ИГРОК И БАЗЫ
Config.Player = {
	StartingMoney = 100,
	MaxPlayersPerServer = 10,
	BaseSize = {x = 40, y = 30, z = 40},
	SpawnProtectionRadius = 5,
}

-- КРОЛИКИ - РЕДКОСТЬ И ХАРАКТЕРИСТИКИ
Config.RabbitRarities = {
	Common = {
		color = Color3.fromRGB(139, 69, 19),
		spawnChance = 0.50,
		catchDifficulty = 1.0,
		productivityMultiplier = 1.0,
		rarePoopChance = 0.05,
	},
	Uncommon = {
		color = Color3.fromRGB(0, 128, 0),
		spawnChance = 0.30,
		catchDifficulty = 1.5,
		productivityMultiplier = 1.5,
		rarePoopChance = 0.10,
	},
	Rare = {
		color = Color3.fromRGB(0, 0, 255),
		spawnChance = 0.12,
		catchDifficulty = 2.0,
		productivityMultiplier = 2.0,
		rarePoopChance = 0.15,
	},
	Epic = {
		color = Color3.fromRGB(128, 0, 128),
		spawnChance = 0.05,
		catchDifficulty = 2.5,
		productivityMultiplier = 2.5,
		rarePoopChance = 0.20,
	},
	Legendary = {
		color = Color3.fromRGB(255, 215, 0),
		spawnChance = 0.02,
		catchDifficulty = 3.0,
		productivityMultiplier = 3.0,
		rarePoopChance = 0.30,
	},
	Mythic = {
		color = Color3.fromRGB(255, 0, 255),
		spawnChance = 0.01,
		catchDifficulty = 4.0,
		productivityMultiplier = 4.0,
		rarePoopChance = 0.50,
	},
}

-- КАКАШКИ - ТИПЫ И ЦЕНЫ
Config.PoopTypes = {
	Brown = {
		price = 10,
		appearance = 0.70,
		color = Color3.fromRGB(139, 69, 19),
	},
	Silver = {
		price = 50,
		appearance = 0.20,
		color = Color3.fromRGB(192, 192, 192),
	},
	Golden = {
		price = 150,
		appearance = 0.07,
		color = Color3.fromRGB(255, 215, 0),
	},
	Rainbow = {
		price = 500,
		appearance = 0.02,
		color = Color3.fromRGB(255, 0, 255),
	},
	Diamond = {
		price = 2000,
		appearance = 0.01,
		color = Color3.fromRGB(173, 216, 230),
	},
}

-- СОВКИ - РЕДКОСТЬ И ЦЕНЫ
Config.Scoops = {
	Common = {
		price = 500,
		catchChance = 0.70,
		canCatch = {"Common"},
	},
	Uncommon = {
		price = 2000,
		catchChance = 0.75,
		canCatch = {"Common", "Uncommon"},
	},
	Rare = {
		price = 10000,
		catchChance = 0.80,
		canCatch = {"Common", "Uncommon", "Rare"},
	},
	Epic = {
		price = 50000,
		catchChance = 0.85,
		canCatch = {"Common", "Uncommon", "Rare", "Epic"},
	},
	Legendary = {
		price = 250000,
		catchChance = 0.90,
		canCatch = {"Common", "Uncommon", "Rare", "Epic", "Legendary"},
	},
	Mythic = {
		price = 1000000,
		catchChance = 0.95,
		canCatch = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
	},
}

-- ТЕРРАРИУМЫ
Config.Terrariums = {
	Basic = {
		price = 1000,
		capacity = 5,
		productionRate = 1.0,
		foodCapacity = 100,
		waterCapacity = 100,
	},
	Advanced = {
		price = 5000,
		capacity = 10,
		productionRate = 1.5,
		foodCapacity = 200,
		waterCapacity = 200,
	},
	Premium = {
		price = 25000,
		capacity = 20,
		productionRate = 2.0,
		foodCapacity = 500,
		waterCapacity = 500,
	},
}

-- ДЕНЬ И НОЧЬ
Config.DayNight = {
	dayLength = 600, -- 10 минут
	nightLength = 300, -- 5 минут
	transitionTime = 30,
}

-- ВОЛКИ
Config.Wolves = {
	spawnCount = 3,
	speed = 25,
	detectionRadius = 50,
	damage = 10,
	health = 50,
}

-- ДРУГОЕ
Config.UI = {
	updateRate = 0.1, -- обновление UI каждые 0.1 сек
}

Config.Optimization = {
	poopPoolSize = 500, -- макс какашек одновременно
	maxObjectsPerPlayer = 100,
}

return Config
