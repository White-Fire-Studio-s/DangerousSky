--// Services
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Wrapper = require(Packages.Wrapper)

--// Constants
local FRAME_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Quint)

--// Cache
local shownFrames = setmetatable({}, {
    __index = function(self, groupName: string)
        self[groupName] = setmetatable({}, { __mode = "k" })
        
        return self[groupName]
    end
})
local frames = setmetatable({}, { __mode = "k" })

--// Component
local Frame = {}

function Frame.wrap(frame: Frame, button: TextButton)

    if frame:IsDescendantOf(StarterGui) then
        return
    end

    local self = Wrapper(frame)
    
    local upPosition = frame.Position
    local downPosition = UDim2.fromScale(upPosition.X.Scale, 1.5)
    
    local upTween = TweenService:Create(frame, FRAME_TWEENINFO, { Position = upPosition })
    local downTween = TweenService:Create(frame, FRAME_TWEENINFO, { Position = downPosition })
    
    frame.Position = downPosition
    frame.Visible = true
    
    self.button = button
    self.group = frame:GetAttribute("group") or "main"
    self.openType = self.openType or "tween"

    if self.isOpen then

        shownFrames[self.group][self] = true
        frame.Position = upPosition
    end
    
    function self:open()
        
        local openedFrame = next(shownFrames[self.group])

        if openedFrame then

            openedFrame:close()
        end
        
        if self.openType == "tween" then
            upTween:Play()
        else
            frame.Position = upPosition
            frame.Visible = true
        end
        
        Lighting.GuiBlur.Enabled = true
        self.isOpen = true
        
        shownFrames[self.group][self] = true
    end
    function self:close()
        
        if self.openType == "tween" then
            downTween:Play()
        else
            frame.Position = downPosition
            frame.Visible = false
        end       
         
        Lighting.GuiBlur.Enabled = false
        self.isOpen = false
        
        table.clear(shownFrames[self.group])
    end
    
    frames[frame] = self
    
    return self
end

function Frame.get(frame: Frame, button: TextButton?)
    return frames[frame] or Frame.wrap(frame, button)
end

--// Loader
CollectionService:GetInstanceAddedSignal("frame"):Connect(Frame.get)
for _, frame in CollectionService:GetTagged("frame") do Frame.get(frame) end

--// End
return Frame