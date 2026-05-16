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
		bounce_force_max     = cfgFloat("savegame.mod.bounce_force_max", 6.0),
		bounce_upward_kick   = cfgFloat("savegame.mod.bounce_upward_kick", 4.5),
		wall_check_distance  = cfgFloat("savegame.mod.wall_check_distance", 1.2),
		-- feel
		fov_base             = cfgFloat("savegame.mod.fov_base", 90.0),
		fov_sprint           = cfgFloat("savegame.mod.fov_sprint", 97.0),
		fov_slide            = cfgFloat("savegame.mod.fov_slide", 104.0),
		bounce_shake         = cfgFloat("savegame.mod.bounce_shake", 0.5),
	}
end
