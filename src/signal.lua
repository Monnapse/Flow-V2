--[[
    Monnapse's Signal Script MODIFIED
    @0.1.0
--]]

--[=[
    Send signals over scripts easily.
    @class signal
    @client
    @private
]=]
local signal = {}
signal.__index = signal

export type signal = {
    Connect: (() -> nil) -> nil,
    Destroy: () -> nil,
    Enable: () -> nil,
    Disable: () -> nil
}

--[=[
    Create a new signal.

    @client
    @private

    @return signal
]=]
function signal.new(): signal
    local self = setmetatable({}, signal)
    self.CallbackEvents = {}
    self.enabled = true
    return self
end

--[=[
    Fire an event to a signal.

    @client
    @private

    @param ... any -- Parameters that will be sent to the signal
]=]
function signal:Fire(...)
    for index, CallbackEvent in pairs(self.CallbackEvents) do
        CallbackEvent(...)
    end
end

--[=[
    Connect to the signal to get callbacks.

    @client

    @param CallbackEvent function -- The event that will be called when the signal is fired
]=]
function signal:Connect(CallbackEvent)
    table.insert(self.CallbackEvents,CallbackEvent)
end

--[=[
    Destroy the signal.

    @client
    @private
]=]
function signal:Destroy()
    setmetatable(self,nil)
end

--[=[
    Enable the signal

    @client
]=]
function signal:Enable()
    self.enabled = true
end

--[=[
    Disable the signal.

    @client
]=]
function signal:Disable()
    self.enabled = false
end

return signal