--// Services
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local wrapper = require(Packages.Wrapper)
local Entity = require(Packages.Entity)

--// Constants
local FRAME_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Quint)

--// Cache
local shownFrames = setmetatable({}, {
    __index = function(self, groupName: string)
        self[groupName] = setmetatable({}, { __mode = "k" })
    end
})

return Entity.trait("frame", function(self, frame: Frame)
    local upPosition = frame.Position
    local downPosition = UDim2.fromScale(upPosition.X.Scale, 1.5)

    local upTween = TweenService:Create(frame, FRAME_TWEENINFO, { Position = upPosition })
    local downTween = TweenService:Create(frame, FRAME_TWEENINFO, { Position = downPosition })

    frame.Position = downPosition
    frame.Visible = true

    self.isOpen = false
    self.group = frame:GetAttribute("group") or "main"

    function self:open()

        local _,openedFrame = next(shownFrames[self.group])
        if openedFrame then
            openedFrame:close()
        end

        upTween:Play()

        Lighting.GuiBlur.Enabled = true
        self.isOpen = true

        shownFrames[self.group][frame] = true
    end
    function self:close()

        downTween:Play()

        Lighting.GuiBlur.Enabled = false
        self.isOpen = false

        table.clear(shownFrames[self.group])
    end

    return self
end)