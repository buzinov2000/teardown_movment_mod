-- Double jump: one extra jump in the air, with cooldown after any jump type

local djAvailable = {}   -- [playerId] = boolean
local lastJumpTime = {}  -- [playerId] = number (GetTime())
local wasGrounded = {}   -- [playerId] = boolean (previous tick)

function doubleJumpTick(playerId, input, dt)
	if shared.config.enable_double_jump < 0.5 then return end

	local grounded = IsPlayerGrounded(playerId)
	local prevGrounded = wasGrounded[playerId]
	wasGrounded[playerId] = grounded

	-- Landing: not grounded -> grounded => restore double jump
	if grounded and not prevGrounded then
		djAvailable[playerId] = true
	end

	-- Detect ground jump: grounded -> not grounded with upward velocity
	if not grounded and prevGrounded then
		local vy = GetPlayerVelocity(playerId)[2]
		if vy > 1.0 then
			lastJumpTime[playerId] = GetTime()
		end
	end

	-- Double jump: in air + jump pressed + available + cooldown passed
	if not input.jumpPressed then return end
	if grounded then return end
	if not djAvailable[playerId] then return end

	local timeSinceJump = GetTime() - (lastJumpTime[playerId] or 0)
	if timeSinceJump < shared.config.double_jump_cooldown then return end

	-- Apply: set vertical velocity, preserve horizontal
	local v = GetPlayerVelocity(playerId)
	SetPlayerVelocity(Vec(v[1], shared.config.double_jump_force, v[3]), playerId)

	djAvailable[playerId] = false
	lastJumpTime[playerId] = GetTime()
	input.jumpPressed = false

	-- Signal event to client for visual feedback
	shared.doubleJumpEvents = shared.doubleJumpEvents or {}
	shared.doubleJumpEvents[playerId] = (shared.doubleJumpEvents[playerId] or 0) + 1
end

-- Called from wallbounce when wall-jump fires, to update lastJumpTime
function doubleJumpOnWalljump(playerId)
	lastJumpTime[playerId] = GetTime()
end
