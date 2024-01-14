--!strict

--// Packages
local Signal = require(script.Parent.Signal)
type Signal<Param...> = Signal.Signal<Param...>

--[=[
    @class wrapper
    A empty wrapper to be extended by others components, it gives some methods for short handing.
]=]

--[=[
    @within wrapper
    @function wrapper
    @param instance Instance    -- instance which are be wrapping
    @return wrapper       -- wrapper for instance received
]=]
local function wrapper(instance: Instance,...: string)
    
    local tags = {...}
    for _,tag in tags do instance:AddTag(tag) end
    
    local meta = { __metatable = "locked" }
    local self = setmetatable({ roblox = instance } :: { [string]: any }, meta)
    local attributeChangedSignals = {} :: { [string]: Signal<any> }
    local instanceVisualizers = {} :: { [string]: ObjectValue }
    local compoundAttributes = {}
    local cleaners = {}
    
    --[=[
        @within wrapper
        @method listenChange
        @param attribute string
        @return Signal
        
        Create a signal that is called when attribute is changed.
    ]=]
    function self:listenChange(attribute: string): Signal<any>
        
        if not attributeChangedSignals[attribute] then
            
            local signal = Signal.new(`{attribute}Changed`)
            attributeChangedSignals[attribute] = signal
            
            instance:GetAttributeChangedSignal(attribute):Connect(function() signal:_emit(instance:GetAttribute(attribute)) end)
        end
        
        return attributeChangedSignals[attribute]
    end
    --[=[
        @within Wrapper
        @method addTags
        @params ... string -- tags
        
        Add all given tags to wrapped instance, when :unwrap'ed, the tags will be removed.
        Useful for inheritance
    ]=]
    function self:addTags(...: string)
        
        table.move({...}, 1, select('#',...), #tags+1, tags)
        for _,tag in {...} do instance:AddTag(tag) end
        
        return self
    end
    --[=[
        @within Wrapper
        @method hasTags
        @params ... string -- tags
        
        Check if all given tags was added to wrapped instance.
        Useful for type check
    ]=]
    function self:hasTags(...: string): boolean
        
        for _,tag in {...} do
            
            if not instance:HasTag(tag) then return false end
        end
        
        return true
    end
    --[=[
        @within Wrapper
        @method is
        @params ... string -- tags
        
        Check if all given tags was added from this wrapper.
        Useful for type check
    ]=]
    function self:is(...: string): boolean
        
        for _,tag in {...} do
            
            if not table.find(tags, tag) then return false end
        end
        
        return true
    end
    
    --[=[
        @within wrapper
        @method cleaner
        @return () -> ()    -- for cleaner cancellation
        
        Add a callback to be called when :unwrap, and returns a function to cancel this callback.
    ]=]
    function self:cleaner(cleaner: () -> ()): () -> ()
        
        local function cancel() cleaners[cleaner] = nil end
        cleaners[cleaner] = cancel
        
        return cancel
    end
    --[=[
        @within wrapper
        @method unwrap
        
        Destroy wrapper, keeping the main instance alive.
    ]=]
    function self:unwrap()
        
        for cleaner in cleaners do cleaner() end
        for _,tag in tags do instance:RemoveTag(tag) end
        
        local label = tostring(self)
        table.clear(self)
        
        function meta:__newindex(index: string, value: any)
            
            error(`attempt to write '{index}' to {value} on {self}`)
        end
        function meta:__index(index: string)
            
            error(`attempt to read '{index}' on {self}`)
        end
        function meta:__tostring()
            
            return `destroyed {label}`
        end
    end
    --[=[
        @within wrapper
        @method destroy
        
        Destroy wrapper and wrapped instance.
    ]=]
    function self:destroy()
        
        instance:Destroy()
    end
    
    --[=[
        @within wrapper
        @method _host
        @param child wrapper|Instance|RBXScriptConnection|Connection    -- element to be hosted
        @return Instance|RBXScriptConnection|Connection -- the element received
        
        Receives an instance or connection to be destroyed together this wrapper, and sets the instance parent to self.
        Useful to avoid memory leaks.
    ]=]
    function self:_host<child>(child: child & ({ roblox: Instance }|Instance|RBXScriptConnection|Signal.Connection)): child
        
        local unwrappedChild = if typeof(child) == "table" and rawget(child, "roblox")
            then child.roblox :: Instance
            else child
        
        local cancelClean = self:cleaner(function()
            
            if typeof(unwrappedChild) == "Instance" then unwrappedChild:Destroy()
            elseif typeof(unwrappedChild) == "RBXScriptConnection" then unwrappedChild:Disconnect()
            elseif typeof(rawget(unwrappedChild, "destroy")) == "function" then unwrappedChild:destroy()
            end
        end)
        
        if typeof(unwrappedChild) == "Instance" and unwrappedChild.Parent == nil then
            
            unwrappedChild.Parent = instance
            unwrappedChild:GetPropertyChangedSignal("Parent"):Once(function() cancelClean() end)
        end
        
        return child
    end
    --[=[
        @within wrapper
        @method _syncAttributes
        @params attributes table
        
        Set all given data as attributes for the wrapped instance, and sync attributes with data.
    ]=]
    function self:_syncAttributes(data: { [string]: any })
        
        for attributeName, value in data do
            
            local isAttribute = meta.__newindex(self, attributeName, value)
            if not isAttribute then continue end
            
            self:listenChange(attributeName):connect(function(newValue) data[attributeName] = newValue end)
        end
        
        return self
    end
    --[=[
        @within wrapper
        @method _signal
        @param name string
        @return Signal<...any>
        
        Create a signal within this wrapper, just a shorthand for create signals.
    ]=]
    function self:_signal(name: string): Signal<...any>
        
        return self:_host(Signal.new(name))
    end
    
    local function visualizeObject(name: string, object: Instance)
        
        local visualizer = instanceVisualizers[name]
        if nil == visualizer then
            
            visualizer = Instance.new("ObjectValue")
            visualizer.Name = name
            self:_host(visualizer)
        end
        
        visualizer.Value = object --will call by .Changed visualizeObjectValue()
    end
    
    --// Metamethods
    function meta:__newindex(index: string, value: any)
        
        if value == nil and instanceVisualizers[index] then
            
            instanceVisualizers[index].Value = nil
            
        elseif typeof(value) == "table" and rawget(value, "roblox") then
            
            compoundAttributes[index] = value
            visualizeObject(index, value.roblox)
            
        elseif typeof(value) == "Instance" then
            
            visualizeObject(index, value)
            
        elseif type(value) == "function" or type(value) == "table" or typeof(value) == "userdata" or type(value) == "thread" then
            
            compoundAttributes[index] = value
            
            local attributeChangedSignal = attributeChangedSignals[index]
            if attributeChangedSignal then attributeChangedSignal:_emit(value) end
        else
            
            instance:SetAttribute(index, value)
            return true
        end
        
        return false
    end
    function meta:__index(index: string)
        
        return instance:GetAttribute(index) or compoundAttributes[index]
    end
    function meta:__tostring()
        
        return `wrapper({instance:GetFullName()})`
    end
    
    --// Listeners
    local function setupVisualizer(objectValue: Instance, initCompute: boolean?)
        
        if not objectValue:IsA("ObjectValue") then return end
        local name = objectValue.Name
        
        local function compute()
            
            local value = compoundAttributes[name]
            if type(value) == "table" and rawget(value, "roblox") == objectValue.Value then return end
            
            compoundAttributes[name] = objectValue.Value
            
            local changedSignal = attributeChangedSignals[name]
            if changedSignal then changedSignal:_emit(objectValue.Value) end
        end
        objectValue:GetPropertyChangedSignal("Value"):Connect(compute)
        if initCompute then compute() end
        
        instanceVisualizers[name] = objectValue
    end
    for _,objectValue in instance:GetChildren() do setupVisualizer(objectValue, true) end
    instance.ChildAdded:Connect(setupVisualizer)
    
    instance.Destroying:Connect(function() self:unwrap() end)
    
    --// End
    return self, meta
end

--// End
return wrapper