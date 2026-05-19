-- Config: loads mod parameters from registry into shared.config
-- In multiplayer, server.* runs on host machine, so registry = host's values.
-- shared.config is visible to all clients.

local CONFIG_DEFAULTS = {
	sprint_multiplier    = 1.6,
	sprint_mode          = 2,    -- 0=hold, 1=toggle, 2=always_on
	air_wishspeed        = 4.0,
	air_accel            = 20.0,
	air_max_turn_rate    = 4.0,
	slide_impulse_min    = 8.0,
	slide_speed_factor   = 1.2,
	slide_duration_base  = 0.7,
	slide_duration_per_speed = 0.04,
	slide_slope_accel    = 15.0,
	slide_cooldown       = 0.6,
	enable_double_jump   = 1,    -- 0=off, 1=on
	double_jump_force    = 7.0,
	double_jump_cooldown = 0.1,
	bounce_force_max     = 6.0,
	bounce_upward_kick   = 4.5,
	wall_check_distance  = 1.2,
	fov_base             = 90.0,
	fov_sprint           = 90.0,
	fov_slide            = 95.0,
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
