-- Feel layer: FOV boost on sprint/slide, camera shake on bounce

local currentFov = 90
local lastBounceCount = {}

function feelInit()
	currentFov = 90
	lastBounceCount = {}
end

function feelTick(dt)
	local pid = GetLocalPlayer()
	local cfg = shared.config

	-- 1. FOV: sprint = wider, slide = even wider, else = base
	local targetFov = cfg.fov_base
	local isSprinting = InputDown("shift") and IsPlayerGrounded(pid)
	local isSliding = shared.slideActive and shared.slideActive[pid]

	if isSliding then
		targetFov = cfg.fov_slide
	elseif isSprinting then
		targetFov = cfg.fov_sprint
	end

	currentFov = currentFov + (targetFov - currentFov) * math.min(1, dt * 8)
	SetCameraFov(currentFov)

	-- 2. Shake on wall-bounce
	local bc = (shared.bounceEvents and shared.bounceEvents[pid]) or 0
	if bc > (lastBounceCount[pid] or 0) then
		ShakeCamera(cfg.bounce_shake)
		lastBounceCount[pid] = bc
	end
end
