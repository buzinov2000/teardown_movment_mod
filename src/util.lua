-- Utility helpers

-- Registry wrapper: GetFloat returns 0 when key doesn't exist,
-- so we use HasKey to check and fall back to default
function cfgFloat(key, default)
	local val = GetFloat(key)
	if val == 0 and not HasKey(key) then
		return default
	end
	return val
end
