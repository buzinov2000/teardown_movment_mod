-- Sprint: increases walking speed while shift is held

local vanillaWalkSpeed = 7.0

function sprintInit()
	vanillaWalkSpeed = GetPlayerWalkingSpeed(0)
	if vanillaWalkSpeed == 0 then
		vanillaWalkSpeed = 7.0
	end
end

function sprintTick(playerId, input, dt)
	local target
	if input.sprint and IsPlayerGrounded(playerId) and GetPlayerCrouch(playerId) < 0.5 then
		target = vanillaWalkSpeed * shared.config.sprint_multiplier
	else
		target = vanillaWalkSpeed
	end
	SetPlayerWalkingSpeed(target, playerId)
end
