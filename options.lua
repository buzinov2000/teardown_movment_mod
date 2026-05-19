local tabs = {
	{name = "Movement", settings = {
		{key = "sprint_multiplier", label = "Sprint multiplier", min = 1.0, max = 3.0, step = 0.1, default = 1.6, fmt = "%.2f"},
		{key = "air_wishspeed",     label = "Air wishspeed",     min = 0.5, max = 30.0, step = 0.5, default = 4.0, fmt = "%.1f"},
		{key = "air_accel",         label = "Air accel",         min = 1.0, max = 100.0, step = 1.0, default = 20.0, fmt = "%.0f"},
		{key = "air_max_turn_rate", label = "Air turn rate",     min = 1.0, max = 15.0, step = 0.5, default = 4.0, fmt = "%.1f"},
		{key = "slide_impulse_min",      label = "Slide impulse min",      min = 1.0, max = 20.0, step = 0.5, default = 8.0, fmt = "%.1f"},
		{key = "slide_speed_factor",     label = "Slide speed factor",     min = 0.5, max = 3.0, step = 0.1, default = 1.2, fmt = "%.1f"},
		{key = "slide_duration_base",    label = "Slide duration base",    min = 0.1, max = 2.0, step = 0.1, default = 0.7, fmt = "%.1f"},
		{key = "slide_duration_per_speed", label = "Slide dur/speed",      min = 0.0, max = 0.2, step = 0.01, default = 0.04, fmt = "%.2f"},
		{key = "slide_slope_accel", label = "Slide slope accel", min = 0.0, max = 40.0, step = 1.0, default = 15.0, fmt = "%.0f"},
		{key = "slide_cooldown",    label = "Slide cooldown",    min = 0.0, max = 2.0, step = 0.1, default = 0.6, fmt = "%.1f"},
	}},
	{name = "Jumping", settings = {
		{key = "enable_double_jump", label = "Double jump", min = 0, max = 1, step = 1, default = 1, fmt = "toggle"},
		{key = "double_jump_force",  label = "Double jump force",    min = 1.0, max = 10.0, step = 0.5, default = 5.0, fmt = "%.1f"},
		{key = "double_jump_cooldown", label = "Double jump cooldown", min = 0.1, max = 1.5, step = 0.1, default = 0.6, fmt = "%.1f"},
	}},
	{name = "Wall-bounce", settings = {
		{key = "bounce_force_max",   label = "Bounce force",       min = 3.0, max = 20.0, step = 0.5, default = 6.0, fmt = "%.1f"},
		{key = "bounce_upward_kick", label = "Bounce upward kick", min = 1.0, max = 8.0, step = 0.5, default = 4.5, fmt = "%.1f"},
		{key = "wall_check_distance",label = "Wall check distance",min = 0.5, max = 3.0, step = 0.1, default = 1.2, fmt = "%.1f"},
	}},
	{name = "Feel", settings = {
		{key = "fov_base",       label = "FOV base",       min = 70.0, max = 110.0, step = 1.0, default = 90.0, fmt = "%.0f"},
		{key = "fov_sprint",     label = "FOV sprint",     min = 80.0, max = 120.0, step = 1.0, default = 97.0, fmt = "%.0f"},
		{key = "fov_slide",      label = "FOV slide",      min = 85.0, max = 130.0, step = 1.0, default = 104.0, fmt = "%.0f"},
		{key = "bounce_shake",   label = "Bounce shake",   min = 0.0, max = 1.0, step = 0.05, default = 0.5, fmt = "%.2f"},
	}},
}

local activeTab = 1

local function getVal(s)
	local v = GetFloat("savegame.mod." .. s.key)
	if v == 0 then v = s.default end
	return v
end

function init()
end

function draw()
	-- Only host can change settings in multiplayer
	if not IsPlayerHost() then
		UiPush()
			UiTranslate(UiCenter(), UiMiddle())
			UiAlign("center middle")
			UiFont("regular.ttf", 26)
			UiColor(0.8, 0.8, 0.8)
			UiText("Settings are controlled by the host")
		UiPop()
		return
	end

	-- Title
	UiPush()
		UiTranslate(UiCenter(), 40)
		UiAlign("center top")
		UiFont("regular.ttf", 32)
		UiColor(1, 1, 1)
		UiText("Quake Movement")
	UiPop()

	-- Tab buttons
	local tabWidth = 140
	local totalWidth = #tabs * tabWidth
	local tabStartX = UiCenter() - totalWidth / 2

	for i = 1, #tabs do
		UiPush()
			UiTranslate(tabStartX + (i - 1) * tabWidth + tabWidth / 2, 90)
			UiAlign("center top")
			UiFont("regular.ttf", 22)
			if i == activeTab then
				UiColor(1, 1, 0.3)
			else
				UiColor(0.7, 0.7, 0.7)
			end
			if UiTextButton(tabs[i].name, tabWidth - 10, 30) then
				activeTab = i
			end
		UiPop()
	end

	-- Sprint mode selector (above sliders)
	local sprintModeNames = {"Hold", "Toggle", "Always on"}
	local currentMode = math.floor(GetFloat("savegame.mod.sprint_mode") + 0.5)
	-- Default to always_on (2) if unset
	if currentMode < 0 or currentMode > 2 then currentMode = 2 end

	UiPush()
		UiTranslate(UiCenter(), 130)
		UiAlign("center top")
		UiFont("regular.ttf", 20)
		UiColor(0.8, 0.8, 0.8)
		UiText("Sprint mode:")
	UiPop()

	local modeButtonW = 100
	local modeStartX = UiCenter() - (#sprintModeNames * modeButtonW) / 2
	for mi = 1, #sprintModeNames do
		UiPush()
			UiTranslate(modeStartX + (mi - 1) * modeButtonW + modeButtonW / 2, 155)
			UiAlign("center top")
			UiFont("regular.ttf", 20)
			if (mi - 1) == currentMode then
				UiColor(1, 1, 0.3)
			else
				UiColor(0.6, 0.6, 0.6)
			end
			if UiTextButton(sprintModeNames[mi], modeButtonW - 10, 28) then
				SetFloat("savegame.mod.sprint_mode", mi - 1)
			end
		UiPop()
	end

	-- Settings for active tab
	local settings = tabs[activeTab].settings
	local y = 200

	for i = 1, #settings do
		local s = settings[i]
		local val = getVal(s)

		if s.fmt == "toggle" then
			-- Toggle button: On / Off
			local isOn = val > 0.5
			UiPush()
				UiTranslate(UiCenter(), y)
				UiAlign("center top")
				UiFont("regular.ttf", 22)
				if isOn then UiColor(0.3, 1, 0.3) else UiColor(0.7, 0.3, 0.3) end
				if UiTextButton(s.label .. ": " .. (isOn and "ON" or "OFF"), 250, 30) then
					SetFloat("savegame.mod." .. s.key, isOn and 0 or 1)
				end
			UiPop()
			y = y + 45
		else
			-- Slider: label + value + buttons
			UiPush()
				UiTranslate(UiCenter(), y)
				UiAlign("center top")
				UiFont("regular.ttf", 22)
				UiColor(1, 1, 1)
				UiText(s.label .. ": " .. string.format(s.fmt, val))
			UiPop()

			UiPush()
				UiTranslate(UiCenter() - 100, y + 30)
				UiAlign("left top")
				UiFont("regular.ttf", 24)
				if UiTextButton("  -  ", 60, 35) then
					val = math.max(s.min, val - s.step)
					SetFloat("savegame.mod." .. s.key, val)
				end
			UiPop()

			UiPush()
				UiTranslate(UiCenter() + 40, y + 30)
				UiAlign("left top")
				UiFont("regular.ttf", 24)
				if UiTextButton("  +  ", 60, 35) then
					val = math.min(s.max, val + s.step)
					SetFloat("savegame.mod." .. s.key, val)
				end
			UiPop()

			y = y + 70
		end
	end

	-- Back button
	UiPush()
		UiTranslate(UiCenter(), UiHeight() - 80)
		UiAlign("center top")
		UiFont("regular.ttf", 26)
		if UiTextButton("Back", 120, 40) then
			Menu()
		end
	UiPop()
end
