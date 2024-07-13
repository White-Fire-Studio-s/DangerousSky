--// Services
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Signal = require(Packages.Signal)
local Wrapper = require(Packages.Wrapper)
local Button = require(script.Parent.Button)

--// Cache
local enums = setmetatable({}, { __mode = "k" })

--// Module
local Enum = {}

function Enum.wrap(enum: Frame)
    
    local self = Wrapper(enum)
    self.currentPosition = self.currentPosition or 1
    self._elements = if self.elements then HttpService:JSONDecode(self.elements) else {}

    self.Changed = Signal.new('')

    local display = assert(enum:WaitForChild("Display")).Value
    local nextButtonUI = assert(enum:WaitForChild("Next")).Value
    local previousButtonUI = assert(enum:WaitForChild("Previous")).Value

    local nextButton = Button.get(nextButtonUI)
    local previousButton = Button.get(previousButtonUI)

    function self:set(element: string)
        
        local index = table.find(self._elements, element)
        assert(index, `Element ({element}) isn't in Enum`)

        self.currentPosition = index

        display.Text = element

        self.Changed:_emit(element)
    end
    function self:get()
        
        return self._elements[self.currentPosition]
    end
    function self:next()
        
        local index = if self.currentPosition + 1 > #self._elements then 1 else self.currentPosition + 1
        local element = self._elements[index]

        self.currentPosition = index
        display.Text = element

        self.Changed:_emit(element)
    end
    function self:previous()
        
        local index = if self.currentPosition - 1 <= 0 then #self._elements else self.currentPosition - 1
        local element = self._elements[index]

        self.currentPosition = index
        display.Text = element

        self.Changed:_emit(element)
    end

    self:_host(nextButton.Clicked:connect(function() self:next() end))
    self:_host(previousButton.Clicked:connect(function() self:previous() end))

    enums[enum] = self;

    self:set(self._elements[1])

    return self
end

function Enum.get(enum: Frame)
    return enums[enum] or Enum.wrap(enum)
end

--// Loader
for _, enum in CollectionService:GetTagged("enum") do Enum.get(enum) end
CollectionService:GetInstanceAddedSignal("enum"):Connect(Enum.wrap)

return Enum