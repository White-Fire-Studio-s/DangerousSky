--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Imports
local Replicator = require(ServerStorage.Packages.Replicator)
local Wrapper = require(ReplicatedStorage.Packages.Wrapper)

local onHit = require(script.Killbrick)

--// Cache
local objects = setmetatable({}, { __mode = "k" })

--// Client
local client = Replicator.get(workspace.SpecialObjects)

function client.KillbrickHit(rbxPlayer: Player, unwrappedObject: BasePart, data)
    local object = objects[unwrappedObject]

    onHit(rbxPlayer, object, data)
end

--// Trait
return function(object) objects[object] = Wrapper(object) end