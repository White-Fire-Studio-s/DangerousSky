--// Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Client = ReplicatedStorage:WaitForChild("Client")
local Wrappers = Client:WaitForChild("Wrappers")
local Interface = Client:WaitForChild("Interface")

--// Imports
local wrapper = require(Packages.Wrapper)
local Profile = require(Wrappers._Player.Profile)
local Coil = require(Wrappers.Coil)
local Zap = require(ReplicatedStorage.Zap)

task.defer(function()
    require(Wrappers._Player.Profile)
    require(Interface.Components.Button)
    require(Interface.Components.Slider)
    require(Wrappers.Orb)
end)

--// Player
local Player = {}

local function formatChatMessage(data)
    return `<font color="#{data.Color}"><font size="{data.FontSize}"><font face="{data.Font}">{data.Text}</font></font></font>`
end

function Player.wrap(rbxPlayer: Player)
    if rbxPlayer ~= game.Players.LocalPlayer then
        rbxPlayer:WaitForChild("Profile"):Destroy()

        return
    end

    local self = wrapper(rbxPlayer)
    local channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")
    self.Profile = Profile.get(rbxPlayer)

    function self:loadCoils()
        
        for _, coil in CollectionService:GetTagged("Coil") do
            Coil.wrap(coil)
        end

        CollectionService:GetInstanceAddedSignal("Coil"):Connect(Coil.wrap)
    end
    function self:loadInterface()

        for _, interface in Interface:GetChildren() do
            if not interface:IsA("ModuleScript") then
                continue
            end

            require(interface)()
        end
    end

    self:loadCoils()
    self:loadInterface()

    Zap.DisplayMessage.setCallback(function(data)
        channel:DisplaySystemMessage(formatChatMessage(data))
    end)

    if self.isDeveloper or self.isOwner then
        rbxPlayer.PlayerGui.Main.Buttons2.Visible = true
    else
        rbxPlayer.PlayerGui.Main.Buttons2:Destroy()
    end

    return self
end

return Player