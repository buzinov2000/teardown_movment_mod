-- Config: loads mod parameters from registry into shared.config

function configLoad()
	shared.config = {
		-- sprint
		sprint_multiplier    = cfgFloat("savegame.mod.sprint_multiplier", 1.6),
		-- air-strafe
		air_wishspeed        = cfgFloat("savegame.mod.air_wishspeed", 7.5),
		air_accel            = cfgFloat("savegame.mod.air_accel", 30.0),
		-- slide
		slide_impulse        = cfgFloat("savegame.mod.slide_impulse", 8.0),
		slide_duration       = cfgFloat("savegame.mod.slide_duration", 0.7),
		slide_slope_accel    = cfgFloat("savegame.mod.slide_slope_accel", 15.0),
		slide_cooldown       = cfgFloat("savegame.mod.slide_cooldown", 0.6),
		-- wall-bounce
		bounce_dot_threshold = cfgFloat("savegame.mod.bounce_dot_threshold", 0.7),
		bounce_force_min     = cfgFloat("savegame.mod.bounce_force_min", 4.0),
		bounce_force_max     = cfgFloat("savegame.mod.bounce_force_max", 9.0),
		bounce_upward_kick   = cfgFloat("savegame.mod.bounce_upward_kick", 3.0),
		wall_check_distance  = cfgFloat("savegame.mod.wall_check_distance", 1.2),
	}
end
