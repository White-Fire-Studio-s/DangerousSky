--!strict

--[=[
    @class Connection
    
    A class that represents a listener of Signals, returned by Signal:Connect() and Signal:Once().
    Useful to handle if callback will be called or not.
]=]
local Connection = {}

--[=[
    @within Connection
    @function new
    @param signal callbacks_container
    @param callback: (...any) -> ...any
    @return Connection
    
    Create a connection binded to given `signal`
]=]
type callbacks_container = {
    _remove: (self: callbacks_container, connection: Connection) -> (),
    _add: (self: callbacks_container, connection: Connection) -> (),
    roblox: Instance
}
function Connection.new(signal: callbacks_container, callback: (...any) -> ...any)
    
    local meta = { __metatable = "locked" }
    local self = setmetatable({ type = "Connection" }, meta)
    
    --[=[
        @within Connection
        @prop isConnected boolean
        
        Determine if connection is connected or not
    ]=]
    self.isConnected = true
    
    --[=[
        @within Connection
        @prop callback
        
        The callback received when :connect'ed
    ]=]
    self.callback = callback
    
    --[=[
        @within Connection
        @method disconnect
        
        Does the callback stop to be called when signal has fired.
    ]=]
    function self:disconnect()
        
        self.isConnected = false
        signal:_remove(self)
    end
    
    --[=[
        @within Connection
        @method reconnect
        
        Does the callback begin to be called when signal has fired.
    ]=]
    function self:reconnect()
        
        self.isConnected = true
        signal:_add(self)
    end
    
    --// Behaviour
    function meta:__tostring()
        
        return `Connection({if self.isConnected then "connected" else "disconnected"} to '{signal.roblox:GetFullName()}')`
    end
    function meta:__call(...)
        
        return callback(...)
    end
    
    --// End
    return self
end
export type Connection = { type: 'Connection',
    callback: (...any) -> ...any,
    isConnected: boolean,
    disconnect: (any) -> (),
    reconnect: (any) -> (),
}

--// End
return Connection