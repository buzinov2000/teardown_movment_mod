#version 2

#include "src/util.lua"
#include "src/config.lua"
#include "src/input_bridge.lua"
#include "src/sprint.lua"
#include "src/airstrafe.lua"
#include "src/slide.lua"
#include "src/wallbounce.lua"
#include "src/camera_fix.lua"
#include "src/feel.lua"

function server.init()
	configLoad()
	inputBridgeInit()
	sprintInit()
end

function server.tick(dt)
	configLoad()
	local allPlayers = GetAllPlayers()
	for i = 1, #allPlayers do
		local p = allPlayers[i]
		local input = inputBridgeGet(p)
		sprintTick(p, input, dt)
		airstrafeTick(p, input, dt)
		slideTick(p, input, dt)
		wallbounceTick(p, input, dt)
	end
end

function server.destroy() end

function client.init()
	feelInit()
end

function client.tick(dt)
	inputBridgeSendThisFrame()
	cameraFixTick(dt)
	feelTick(dt)

	-- debug overlay (remove later)
	local v = GetPlayerVelocity(0)
	local hSpeed = VecLength(Vec(v[1], 0, v[3]))
	DebugWatch("speed", string.format("%.1f", hSpeed))
	DebugWatch("grounded", tostring(IsPlayerGrounded(0)))
	DebugWatch("sprint", tostring(InputDown("shift")))
	DebugWatch("slide", tostring(InputPressed("crouch")))
end

function client.draw(dt) end
