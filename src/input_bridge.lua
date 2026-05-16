-- Input bridge: client sends input to server each frame via ServerCall

local playerInput = {}

function inputBridgeInit()
	playerInput = {}
end

function inputBridgeGet(playerId)
	local inp = playerInput[playerId]
	if not inp then
		return {sprint = false, wishX = 0, wishY = 0, jumpPressed = false}
	end
	-- Copy current state, then clear latched pressed events
	local out = {
		sprint = inp.sprint,
		wishX = inp.wishX,
		wishY = inp.wishY,
		jumpPressed = inp.jumpPressed,
	}
	inp.jumpPressed = false
	return out
end

-- RPC handler called by client via ServerCall
function inputBridgeReceive(playerId, sprint, wishX, wishY, jumpPressed)
	local prev = playerInput[playerId]
	playerInput[playerId] = {
		sprint = sprint,
		wishX = wishX,
		wishY = wishY,
		-- Latch: OR with previous value so pressed events survive until consumed
		jumpPressed = jumpPressed or (prev and prev.jumpPressed) or false,
	}
end

-- Client-side: gather input and send to server
function inputBridgeSendThisFrame()
	local pid = GetLocalPlayer()
	local sprint = InputDown("shift")
	local wishX = 0
	local wishY = 0
	if InputDown("up") then wishY = wishY + 1 end
	if InputDown("down") then wishY = wishY - 1 end
	if InputDown("right") then wishX = wishX + 1 end
	if InputDown("left") then wishX = wishX - 1 end
	local jumpPressed = InputPressed("jump")
	ServerCall("inputBridgeReceive", pid, sprint, wishX, wishY, jumpPressed)
end
