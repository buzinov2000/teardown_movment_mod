-- Sprint: three modes — hold / toggle / always_on
-- sprint_mode in shared.config: 0=hold, 1=toggle, 2=always_on

local SPRINT_MODE_HOLD = 0
local SPRINT_MODE_TOGGLE = 1
local SPRINT_MODE_ALWAYS = 2

local vanillaWalkSpeed = 7.0
local sprintToggleState = {}  -- [playerId] = boolean
local stoppedTimer = {}       -- [playerId] = seconds at low speed (for toggle auto-off)
local STOPPED_THRESHOLD = 1.0
local STOPPED_DURATION = 0.3

function sprintInit()
	vanillaWalkSpeed = GetPlayerWalkingSpeed(0)
	if vanillaWalkSpeed == 0 then
		vanillaWalkSpeed = 7.0
	end
	sprintToggleState = {}
	stoppedTimer = {}
end

-- Returns whether sprint is effectively active for this player this tick.
-- Called by sprint, slide, and any module that needs to know.
function isSprintingEffective(playerId, input)
	local mode = math.floor(shared.config.sprint_mode + 0.5)

	if mode == SPRINT_MODE_HOLD then
		return input.sprint_held

	elseif mode == SPRINT_MODE_TOGGLE then
		-- Toggle on press
		if input.sprint_pressed then
			sprintToggleState[playerId] = not sprintToggleState[playerId]
		end

		-- Auto-disable: stopped for STOPPED_DURATION
		local v = GetPlayerVelocity(playerId)
		local hSpeed = VecLength(Vec(v[1], 0, v[3]))
		if hSpeed < STOPPED_THRESHOLD then
			stoppedTimer[playerId] = (stoppedTimer[playerId] or 0) + GetTimeStep()
			if stoppedTimer[playerId] >= STOPPED_DURATION then
				sprintToggleState[playerId] = false
			end
		else
			stoppedTimer[playerId] = 0
		end

		return sprintToggleState[playerId] or false

	else -- SPRINT_MODE_ALWAYS (default)
		return not input.sprint_held
	end
end

-- Called from slide.lua when a slide starts — disables toggle sprint
function sprintDisableToggle(playerId)
	sprintToggleState[playerId] = false
end

function sprintTick(playerId, input, dt)
	local sprinting = isSprintingEffective(playerId, input)

	-- Sync to client for FOV/visuals
	shared.sprintActive = shared.sprintActive or {}
	shared.sprintActive[playerId] = sprinting

	local target
	if sprinting and IsPlayerGrounded(playerId) and GetPlayerCrouch(playerId) < 0.5 then
		target = vanillaWalkSpeed * shared.config.sprint_multiplier
	else
		target = vanillaWalkSpeed
	end
	SetPlayerWalkingSpeed(target, playerId)
end
