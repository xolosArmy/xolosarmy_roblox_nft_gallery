-- Populate only for a reviewed, separate test copy of the museum.
-- The empty values intentionally keep this integration dormant.
return {
	TestPlaceId = 0,
	TestUniverseId = 0,
	AnchorModelPath = {}, -- Exact names of successive Workspace children, ending at the museum Model.
	ExpectedThresholdCFrame = nil, -- Explicit world CFrame at the finished floor with local +Z inward.
	ReviewedClearance = false, -- Verify the floor, reserved volume and Terrain in Studio first.

	-- Art slug -> Roblox Image content ID. Only enter a verified, approved Image from the exact PNG.
	ImageIds = {
		["cauce-del-itzcuintlan"] = "",
		["el-calor-de-huehueteotl"] = "",
		["itztlantli-en-el-nuevo-mundo"] = "",
	},
}
