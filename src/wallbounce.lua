-- Wall-bounce: wall-jump with fixed angle + flow preservation

function wallbounceTick(playerId, input, dt)
	if not input.jumpPressed then return end
	if not input.sprint then return end
	if IsPlayerGrounded(playerId) then return end

	local v = GetPlayerVelocity(playerId)
	local vH = Vec(v[1], 0, v[3])
	local speedH = VecLength(vH)
	if speedH < 1.0 then return end

	local cfg = shared.config
	local pos = GetPlayerTransform(playerId).pos
	local origin = VecAdd(pos, Vec(0, 1.0, 0))

	-- Find wall: raycast in multiple directions (left, right, forward relative to velocity)
	local vDir = VecNormalize(vH)
	local rightDir = Vec(vDir[3], 0, -vDir[1])  -- perpendicular right
	local leftDir = Vec(-vDir[3], 0, vDir[1])   -- perpendicular left

	local dirs = {rightDir, leftDir, vDir}
	local wallNormal = nil

	for i = 1, #dirs do
		local hit, dist, normal, shape = QueryRaycast(origin, dirs[i], cfg.wall_check_distance)
		if hit and math.abs(normal[2]) < 0.3 then
			wallNormal = normal
			break
		end
	end

	if not wallNormal then return end

	-- Decompose velocity: tangent (along wall) + normal (into wall)
	local tangent = VecSub(vH, VecScale(wallNormal, VecDot(vH, wallNormal)))
	local tangentSpeed = VecLength(tangent)
	local tangentDir = Vec(0, 0, 0)
	if tangentSpeed > 0.1 then
		tangentDir = VecNormalize(tangent)
	end

	-- Fixed bounce: mostly upward + gentle push from wall + preserve tangent flow
	local bounceH = VecAdd(
		VecScale(wallNormal, cfg.bounce_force_max),   -- gentle push from wall
		VecScale(tangentDir, tangentSpeed * 0.8)       -- keep 80% tangent momentum
	)

	local newVy = cfg.bounce_upward_kick
	SetPlayerVelocity(Vec(bounceH[1], newVy, bounceH[3]), playerId)

	input.jumpPressed = false

	DebugWatch("wb wall", "HIT")
	DebugWatch("wb tangentSpd", string.format("%.1f", tangentSpeed))
end
