-- Slide: sprint + crouch = slide forward with momentum

local slideState = {}   -- [playerId] = {timeLeft, dir, normalBuffer}
local prevCrouch = {}   -- [playerId] = number, for edge detection
local slideCdLeft = {}  -- [playerId] = seconds until next slide allowed

function slideTick(playerId, input, dt)
	local s = slideState[playerId]

	-- Tick cooldown
	local cd = slideCdLeft[playerId] or 0
	if cd > 0 then
		slideCdLeft[playerId] = cd - dt
	end

	-- Sync slide state to client via shared
	shared.slideActive = shared.slideActive or {}
	shared.slideActive[playerId] = s ~= nil

	-- Active slide: tick down timer + slope boost
	if s then
		s.timeLeft = s.timeLeft - dt
		if s.timeLeft <= 0 or GetPlayerCrouch(playerId) < 0.5 then
			slideState[playerId] = nil
			slideCdLeft[playerId] = shared.config.slide_cooldown
			prevCrouch[playerId] = GetPlayerCrouch(playerId)
			return
		end

		-- Slope acceleration when grounded
		local contact, _, _, normal = GetPlayerGroundContact(playerId)
		if contact then
			-- Buffer normals for smoothing
			local buf = s.normalBuffer
			buf[#buf + 1] = normal
			if #buf > 8 then
				table.remove(buf, 1)
			end

			-- Average normal
			local avg = Vec(0, 0, 0)
			for i = 1, #buf do
				avg = VecAdd(avg, buf[i])
			end
			avg = VecScale(avg, 1 / #buf)
			avg = VecNormalize(avg)

			-- Downslope = gravity projected onto surface plane
			local g = Vec(0, -10, 0)
			local gDotN = VecDot(g, avg)
			local downslope = VecSub(g, VecScale(avg, gDotN))

			local steepness = VecLength(downslope)
			if steepness > 0.1 then
				local dsDir = VecNormalize(downslope)
				local dsHoriz = Vec(dsDir[1], 0, dsDir[3])
				local dsHorizLen = VecLength(dsHoriz)

				if dsHorizLen > 0.01 then
					dsHoriz = VecNormalize(dsHoriz)
					local v = GetPlayerVelocity(playerId)
					local vH = Vec(v[1], 0, v[3])
					local vHLen = VecLength(vH)

					if vHLen > 0.1 then
						local velDir = VecNormalize(vH)
						local alignment = VecDot(velDir, dsHoriz)
						if alignment > 0 then
							local boost = steepness * alignment * shared.config.slide_slope_accel * dt
							local boostVec = VecScale(dsDir, boost)
							SetPlayerVelocity(VecAdd(v, boostVec), playerId)
						end
					end
				end
			end
		end

		prevCrouch[playerId] = GetPlayerCrouch(playerId)
		return
	end

	-- Edge-detect crouch on server (no reliance on ServerCall timing)
	local crouch = GetPlayerCrouch(playerId)
	local wasCrouching = (prevCrouch[playerId] or 0) > 0.5
	prevCrouch[playerId] = crouch
	local crouchJustPressed = crouch > 0.5 and not wasCrouching

	-- Start slide: sprint + crouch press + grounded + moving + cooldown passed
	if not crouchJustPressed then return end
	if not input.sprint then return end
	if not IsPlayerGrounded(playerId) then return end
	if (slideCdLeft[playerId] or 0) > 0 then return end

	local v = GetPlayerVelocity(playerId)
	local vH = Vec(v[1], 0, v[3])
	local speed = VecLength(vH)
	if speed < 3.0 then return end

	local dir = VecNormalize(vH)
	slideState[playerId] = {
		timeLeft = shared.config.slide_duration,
		dir = dir,
		normalBuffer = {},
	}

	-- Impulse: add on top of current speed
	local newSpeed = speed + shared.config.slide_impulse
	local impulse = VecScale(dir, newSpeed)
	SetPlayerVelocity(Vec(impulse[1], v[2], impulse[3]), playerId)
end

function slideIsActive(playerId)
	return slideState[playerId] ~= nil
end
