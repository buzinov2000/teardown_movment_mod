-- Input bridge: client sends input to server each frame via ServerCall

local playerInput = {}

function inputBridgeInit()
	playerInput = {}
end

function inputBridgeGet(playerId)
	local inp = playerInput[playerId]
	if not inp then
		return {sprint_held = false, sprint_pressed = false, wishX = 0, wishY = 0, jumpPressed = false}
	end
	-- Copy current state, then clear latched pressed events
	local out = {
		sprint_held = inp.sprint_held,
		sprint_pressed = inp.sprint_pressed,
		wishX = inp.wishX,
		wishY = inp.wishY,
		jumpPressed = inp.jumpPressed,
	}
	inp.jumpPressed = false
	inp.sprint_pressed = false
	return out
end

-- RPC handler called by client via ServerCall
function inputBridgeReceive(playerId, sprintHeld, sprintPressed, wishX, wishY, jumpPressed)
	local prev = playerInput[playerId]
	playerInput[playerId] = {
		sprint_held = sprintHeld,
		-- Latch pressed events so they survive until consumed
		sprint_pressed = sprintPressed or (prev and prev.sprint_pressed) or false,
		wishX = wishX,
		wishY = wishY,
		jumpPressed = jumpPressed or (prev and prev.jumpPressed) or false,
	}
end

-- Client-side: gather input and send to server
function inputBridgeSendThisFrame()
	local pid = GetLocalPlayer()
	local sprintHeld = InputDown("shift")
	local sprintPressed = InputPressed("shift")
	local wishX = 0
	local wishY = 0
	if InputDown("up") then wishY = wishY + 1 end
	if InputDown("down") then wishY = wishY - 1 end
	if InputDown("right") then wishX = wishX + 1 end
	if InputDown("left") then wishX = wishX - 1 end
	local jumpPressed = InputPressed("jump")
	ServerCall("inputBridgeReceive", pid, sprintHeld, sprintPressed, wishX, wishY, jumpPressed)
end
