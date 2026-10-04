-- Setup round module
nzRound = nzRound or AddNZModule("Round")

if SERVER then

	nzConfig.RoundData = {}
	--nzConfig.RoundData[1] = {["nz_zombie_walker"] = 100}

	--[[
	-- EXAMPLE of a round zombie config:
	nzConfig.RoundData[ROUNDNUMBER] = {
		-- define normal zombies and theri spawn chances
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
		-- (optional) how many normal zombies will spawn this wil overwrite the default curves
		normalCount = 50,

		-- (optional) modify teh count witha  function ratehr than a fixed amount
		-- if both normalCount and normalCountMod are set the gamemode will ignore normalCount
		normalCountMod = function(original) return orignal / 2 end,

		-- (optional) spawn delay
		-- this will spawn the zombies in a 3 second intervall
		normalDelay = 3,

		-- special zombies (different spawnpoint usually in front of barricades)
		-- this will spawn 10 hellhounds in additon to the normal zombies
		specialTypes = {
			["nz_zombie_special_dog"] = {
				chance = 100,
			},

		},
		-- (optional) not required but recommended if this is not set teh zombie amount will be doubled
		specialCount = 10
		-- (optional) flag this round as special (this will trigger fog etc.)
		special = true
	}
	]]--
	
	--[[
	nzConfig.RoundData[1] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nzConfig.RoundData[2] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nzConfig.RoundData[13] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nzConfig.RoundData[14] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nzConfig.RoundData[23] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	]]

	-- Player Class
	nzConfig.BaseStartingWeapons = {"weapon_pistol"} -- "fas2_p226", "fas2_ots33", "fas2_glock20" "weapon_pistol"
	-- nzConfig.CustomConfigStartingWeps = true -- If this is set to false, the gamemode will avoid using custom weapons in configs

end
