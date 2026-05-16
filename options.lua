local settings = {
	{key = "sprint_multiplier", label = "Sprint multiplier", min = 1.0, max = 3.0, step = 0.1, default = 1.6, fmt = "%.2f"},
	{key = "air_wishspeed",     label = "Air wishspeed",     min = 0.5, max = 30.0, step = 0.5, default = 7.5, fmt = "%.1f"},
	{key = "air_accel",         label = "Air accel",         min = 1.0, max = 100.0, step = 1.0, default = 30.0, fmt = "%.0f"},
	{key = "slide_impulse",     label = "Slide impulse",     min = 1.0, max = 20.0, step = 0.5, default = 8.0, fmt = "%.1f"},
	{key = "slide_duration",    label = "Slide duration",    min = 0.1, max = 2.0, step = 0.1, default = 0.7, fmt = "%.1f"},
	{key = "slide_slope_accel", label = "Slide slope accel", min = 0.0, max = 40.0, step = 1.0, default = 15.0, fmt = "%.0f"},
	{key = "slide_cooldown",   label = "Slide cooldown",    min = 0.0, max = 2.0, step = 0.1, default = 0.6, fmt = "%.1f"},
	{key = "bounce_force_max",     label = "Bounce force",          min = 3.0, max = 20.0, step = 0.5, default = 6.0, fmt = "%.1f"},
	{key = "bounce_upward_kick",   label = "Bounce upward kick",     min = 1.0, max = 8.0, step = 0.5, default = 4.5, fmt = "%.1f"},
	{key = "wall_check_distance",  label = "Wall check distance",    min = 0.5, max = 3.0, step = 0.1, default = 1.2, fmt = "%.1f"},
}

local function getVal(s)
	local v = GetFloat("savegame.mod." .. s.key)
	if v == 0 then v = s.default end
	return v
end

function init()
end

function draw()
	UiPush()
		UiTranslate(UiCenter(), 80)
		UiAlign("center top")
		UiFont("regular.ttf", 32)
		UiColor(1, 1, 1)
		UiText("Quake Movement")
	UiPop()

	local y = 150
	for i = 1, #settings do
		local s = settings[i]
		local val = getVal(s)

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

		y = y + 80
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
