--!strict

--// Packages
local Connection = require(script.Connection)

--[=[
    @class Signal
    A class that represents a emitter.
    Useful to does things happen when its fired.
]=]
local Signal = {}
local signals = setmetatable({}, { __mode = "k" })

--[=[
    @within Signal
    @function wrap
    @param bindableEvent BindableEvent
    @return Signal
    
    Wraps the bindableEvent with a Signal instance
]=]
function Signal.wrap(bindableEvent: BindableEvent)
    
    local meta = { __metatable = "locked" }
    local self = setmetatable({ roblox = bindableEvent }, meta)
    
    local event = bindableEvent.Event
    local connections = {}
    local data = {}
    
    --[=[
        @within Signal
        @method connect
        @param callback function    -- function called when signal fired
        @return Connection        -- object to handle the callback, like disconnect the callback or reconnect
        
        Create a listener/observer for signal.
        Useful to bind and unbind functions to some emitter, which can be fired when something happens during game.
    ]=]
    function self:connect(callback: (...any) -> ()): Connection
        
        local connection = Connection.new(self, callback)
        self:_add(connection)
        
        return connection
    end
    --[=[
        @within Signal
        @method once
        @param callback function    -- function called when signal fired
        @return Connection        -- object to handle the callback, like disconnect the callback or reconnect
        
        Create a listener/observer for signal.
        Like [Signal:connect](/api/Signal#connect), but the connection is [Connection:disconnect](/api/Connection#disconnect)'ed after triggered, but can be [Signal:reconnect](/api/Signal#reconnect)'ed multiple times.
    ]=]
    function self:once(callback: (...any) -> ()): Connection
        
        local connection; connection = self:connect(function(...)
            
            callback(...)
            connection:disconnect()
        end)
        
        return connection
    end
    
    --[=[
        @within Signal
        @method awaitWithinTimeout
        
        Wait until the signal was fired within a given timeout, and returns true and data if signal was fired before timeout, else will be returned false.
        Useful to wait some event without blocking infinitely the coroutine. Such wait some client response.
    ]=]
    function self:awaitWithinTimeout(timeout: number): (boolean, ...any)
        
        local thread = coroutine.running()
        local hasResumed = false
        
        task.delay(timeout, function()
            
            if hasResumed then return end
            coroutine.resume(thread)
        end)
        
        event:Wait()
        hasResumed = true
        
        return hasResumed, unpack(data)
    end
    --[=[
        @within Signal
        @method await
        
        Wait until the signal was fired and returns your data.
        [BindableEvent](https://create.roblox.com/docs/reference/engine/classes/BindableEvent) is used here to avoid bad tracebacks when some error after thread be resumed.
    ]=]
    function self:await(): ...any
        
        event:Wait()
        return unpack(data)
    end
    
    --[=[
        @private
        @within Signal
        @method _tryEmit
        @param data any...
        @return boolean -- if havent any error on any listener
        
        Call all connected listeners within pcall, then return if the operation has been succeeded.
        This has made thinking in listeners which can cancel the operation.
    ]=]
    function self:_tryEmit(...: any): boolean
        
        return pcall(self._emit, self,...)
    end
    --[=[
        @private
        @within Signal
        @method _emit
        @param data any...
        
        Call all connected listeners.
    ]=]
    function self:_emit(...: any)
        
        for connection, callback in connections do
            
            callback(...)
        end
        
        data = {...}
        bindableEvent:Fire()
        data = {}
    end
    
    --[=[
        @private
        @within Signal
        @method _disconnectAll
        
        Does [Signal:disconnect](/api/Signal#disconnect) in all listeners.
    ]=]
    function self:_disconnectAll()
        
        for connection in connections do connection:disconnect() end
    end
    function self:_remove(connection: Connection)
        
        connections[connection] = nil
    end
    function self:_add(connection: Connection)
        
        connections[connection] = connection.callback
    end
    
    --// Behaviours
    function meta:__tostring()
        
        return `Signal('{bindableEvent:GetFullName()}')`
    end
    
    --// Listeners
    bindableEvent.Destroying:Connect(function()
        
        local label = tostring(self)
        self:_disconnectAll()
        
        task.wait()
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
    end)
    
    --// End
    signals[bindableEvent] = self
    return self
end
export type Signal<data... = ...any> = {
    connect: (any, callback: (data...) -> ()) -> Connection<data...>,
    once: (any, callback: (data...) -> ()) -> Connection<data...>,
    awaitWithinTimeout: (any, timeout: number) -> (boolean, data...),
    await: (any) -> data...,
    _tryEmit: (any, data...) -> boolean,
    _emit: (any, data...) -> (),
}

--[=[
    @within Signal
    @function new
    @param name string
    @return Signal
    
    Creates a new bindable with given name, then wraps it with Signal
]=]
function Signal.new(name: string): Signal
    
    local bindableEvent = Instance.new("BindableEvent")
    bindableEvent.Name = name
    
    return Signal.wrap(bindableEvent)
end

--[=[
    @within Signal
    @function find
    @param bindableEvent BindableEvent
    @return Signal?
    
    Find the signal which is wrapping given bindableEvent, if not finded, will be returned nil
]=]
function Signal.find(bindableEvent: BindableEvent): Signal?
    
    return signals[bindableEvent]
end

--// End
export type Connection = Connection.Connection
return Signal