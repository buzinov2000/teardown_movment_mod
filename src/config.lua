-- Config: loads mod parameters from registry into shared.config
-- In multiplayer, server.* runs on host machine, so registry = host's values.
-- shared.config is visible to all clients.

local CONFIG_DEFAULTS = {
	sprint_multiplier    = 1.6,
	air_wishspeed        = 7.5,
	air_accel            = 30.0,
	slide_impulse        = 8.0,
	slide_duration       = 0.7,
	slide_slope_accel    = 15.0,
	slide_cooldown       = 0.6,
	bounce_force_max     = 6.0,
	bounce_upward_kick   = 4.5,
	wall_check_distance  = 1.2,
	fov_base             = 90.0,
	fov_sprint           = 97.0,
	fov_slide            = 104.0,
	bounce_shake         = 0.5,
}

function configLoad()
	shared.config = {}
	for key, default in pairs(CONFIG_DEFAULTS) do
		shared.config[key] = cfgFloat("savegame.mod." .. key, default)
	end
end

-- RPC: update a single setting (host-only, called via ServerCall)
function configUpdateSetting(senderId, key, value)
	if not IsPlayerHost(senderId) then return end
	if CONFIG_DEFAULTS[key] == nil then return end  -- reject unknown keys
	shared.config[key] = value
	-- Persist to host registry so it survives restart
	SetFloat("savegame.mod." .. key, value)
end
