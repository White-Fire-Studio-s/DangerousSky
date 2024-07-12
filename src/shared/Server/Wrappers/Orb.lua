--// Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Server = ReplicatedStorage:WaitForChild("Server")
local Wrappers = Server:WaitForChild("Wrappers")

--// Imports
local Wrapper = require(Packages.Wrapper)
local Replicator = require(ServerStorage.Packages.Replicator)
local Profile = require(Wrappers._Player.Profile)

--// Cache
local orbs = setmetatable({}, { __mode = "k" })

--// Module
local Orb = {}

function Orb.wrap(orb: Model)

	local self = Wrapper(orb, "orb")
	local client = Replicator.get(orb)

	local orbCFrame = orb.WorldPivot

	self.collected = false

	function client.Collect(rbxPlayer: Player, lifetime: number)

		assert(not self.collected)
		assert(type(lifetime) == "number")
		assert(lifetime >= 0)

		local character = rbxPlayer.Character
		if not character then return end

		local characterPosition = character.PrimaryPart.Position
		orbCFrame = orbCFrame
			* CFrame.new(0, math.sin(lifetime), 0)
			* CFrame.Angles(0, lifetime, 0)

		if (orbCFrame.Position - characterPosition).Magnitude > 20 then
			return 
		end

		local playerProfile = Profile.get(rbxPlayer)

		playerProfile.Orbs[orb.Name] += 1

		self.whoCollected = rbxPlayer.Name
		self.collected = true

        task.delay(.4, self.destroy, self)
	end

	return self
end

function Orb.new(data: {kind: string, cframe: CFrame})

	assert(data)
	assert(data.kind)
	assert(data.cframe)

	local orb = ReplicatedStorage.Assets.Orbs[data.kind]
		:Clone()

	orb:PivotTo(data.cframe)
	orb.Parent = Workspace.SpecialObjects.Orbs

	orbs[orb] = Orb.wrap(orb)
end

function Orb.cleanAll()
	for orb in orbs do
		orb:destroy()
	end
end

--// Listeners
for _, orb in CollectionService:GetTagged("orb") do Orb.wrap(orb) end
CollectionService:GetInstanceAddedSignal("orb"):Connect(Orb.wrap)

return Orb