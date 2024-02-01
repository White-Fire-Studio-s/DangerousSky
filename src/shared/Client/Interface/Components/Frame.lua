--// Services
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

function Frame.wrap(frame: Frame)
    local self = Wrapper(frame)
    
    local upPosition = frame.Position
    local downPosition = UDim2.fromScale(upPosition.X.Scale, 1.5)
    
    local upTween = TweenService:Create(frame, FRAME_TWEENINFO, { Position = upPosition })
    local downTween = TweenService:Create(frame, FRAME_TWEENINFO, { Position = downPosition })
    
    frame.Position = downPosition
    frame.Visible = true
    
    self.isOpen = false
    self.group = frame:GetAttribute("group") or "main"
    
    function self:open()
        
        local openedFrame = next(shownFrames[self.group])
        if openedFrame then
            openedFrame:close()
        end
        
        upTween:Play()
        
        Lighting.GuiBlur.Enabled = true
        self.isOpen = true
        
        shownFrames[self.group][self] = true
    end
    function self:close()
        
        downTween:Play()
        
        Lighting.GuiBlur.Enabled = false
        self.isOpen = false
        
        table.clear(shownFrames[self.group])
    end
    
    frames[frame] = self
    
    return self
end

function Frame.get(frame: Frame)
    return frames[frame] or Frame.wrap(frame)
end

--// Loader
CollectionService:GetInstanceAddedSignal("frame"):Connect(Frame.get)
for _, frame in CollectionService:GetTagged("frame") do Frame.get(frame) end

--// End
return Frame