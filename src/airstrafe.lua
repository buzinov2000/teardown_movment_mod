-- Air-strafing: Quake-style air acceleration with turn rate clamp

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
	local vH_old = Vec(vel[1], 0, vel[3])
	local currentSpeed = VecDot(vH_old, wishdir)
	local addSpeed = cfg.air_wishspeed - currentSpeed
	if addSpeed <= 0 then return end

	local accelSpeed = cfg.air_accel * cfg.air_wishspeed * dt
	if accelSpeed > addSpeed then accelSpeed = addSpeed end

	local newVel = VecAdd(vel, VecScale(wishdir, accelSpeed))
	local vH_new = Vec(newVel[1], 0, newVel[3])

	-- Turn rate clamp: limit how fast horizontal direction can change per frame
	local oldLen = VecLength(vH_old)
	local newLen = VecLength(vH_new)
	if oldLen > 0.5 and newLen > 0.5 then
		local oldDir = VecNormalize(vH_old)
		local newDir = VecNormalize(vH_new)
		local dot = math.max(-1, math.min(1, VecDot(oldDir, newDir)))
		local angle = math.acos(dot)
		local maxAngle = cfg.air_max_turn_rate * dt

		if angle > maxAngle then
			-- Rotate oldDir toward newDir by maxAngle using 2D atan2/cos/sin
			local oldA = math.atan2(oldDir[3], oldDir[1])
			local newA = math.atan2(newDir[3], newDir[1])
			-- Shortest arc
			local diff = newA - oldA
			if diff > math.pi then diff = diff - 2 * math.pi end
			if diff < -math.pi then diff = diff + 2 * math.pi end
			local clampedA = oldA + (diff > 0 and maxAngle or -maxAngle)
			local clampedDir = Vec(math.cos(clampedA), 0, math.sin(clampedA))
			vH_new = VecScale(clampedDir, newLen)
			newVel = Vec(vH_new[1], newVel[2], vH_new[3])
		end
	end

	SetPlayerVelocity(newVel, playerId)
end
