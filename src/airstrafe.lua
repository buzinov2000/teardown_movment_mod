-- Air-strafing: Quake-style air acceleration

function airstrafeTick(playerId, input, dt)
	if IsPlayerGrounded(playerId) then return end
	if input.wishX == 0 and input.wishY == 0 then return end

	local cfg = shared.config
	local t = GetPlayerTransform(playerId)
	local vel = GetPlayerVelocity(playerId)

	-- Build world-space wish direction from player facing + WASD
	local fwd = TransformToParentVec(t, Vec(0, 0, -1))
	local rgt = TransformToParentVec(t, Vec(1, 0, 0))
	-- Zero out vertical component
	fwd[2] = 0
	rgt[2] = 0
	fwd = VecNormalize(fwd)
	rgt = VecNormalize(rgt)

	local wishdir = VecAdd(VecScale(fwd, input.wishY), VecScale(rgt, input.wishX))
	wishdir[2] = 0
	wishdir = VecNormalize(wishdir)

	-- Quake3 air acceleration formula
	local vH = Vec(vel[1], 0, vel[3])
	local currentSpeed = VecDot(vH, wishdir)
	local addSpeed = cfg.air_wishspeed - currentSpeed
	if addSpeed <= 0 then return end

	local accelSpeed = cfg.air_accel * cfg.air_wishspeed * dt
	if accelSpeed > addSpeed then accelSpeed = addSpeed end

	SetPlayerVelocity(VecAdd(vel, VecScale(wishdir, accelSpeed)), playerId)
end
