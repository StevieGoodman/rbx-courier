export type CourierId = string
export type EventId = string
export type FunctionId = string
export type ServerCallback = (Player, any...) -> any?
export type ClientCallback = (any...) -> any?
export type Courier = {
    new: () -> Courier,
    GetEvent: (self: Courier, eventId: EventId) -> (...any) -> nil,
    GetFunction: (self: Courier, functionId: FunctionId) -> (...any) -> any?,
    BindToEvent: (self: Courier, eventId: EventId, callback: ServerCallback | ClientCallback) -> RBXScriptConnection,
    BindToFunction: (self: Courier, functionId: FunctionId, callback: ServerCallback | ClientCallback) -> RBXScriptConnection,
    Destroy: (self: Courier) -> nil,
}

local RunService = game:GetService("RunService")

local Net = require(script.Parent.Net)
local Trove = require(script.Parent.Trove)
local Promise = require(script.Parent.Promise)

local Courier = {}

setmetatable(Courier, Courier)

function Courier.new(courierId: CourierId)
    local self = {}
    self._trove = Trove.new()
    self._remoteEvent = Net:RemoteEvent(`{courierId}RemoteEvent`)
    self._remoteFunction = Net:RemoteFunction(`{courierId}RemoteFunction`)

    self._trove:Add(self._remoteEvent)
    self._trove:Add(self._remoteFunction)

    setmetatable(self, { __index = Courier })
    return self
end

function Courier:GetEvent(eventId: EventId)
    return function(...)
        if RunService:IsServer() then
            self._remoteEvent:FireAllClients(eventId, ...)
        else
            self._remoteEvent:FireServer(eventId, ...)
        end
    end
end

function Courier:GetFunction(functionId: FunctionId)
    return function(...)
        local args = table.pack(...)
        return Promise.new(function(resolve, _, _)
            if RunService:IsServer() then
                local player = args[1]
                args = table.unpack(args, 2, #args)
                resolve(self._remoteFunction:InvokeClient(player, functionId, args))
            else
                resolve(self._remoteFunction:InvokeServer(functionId, table.unpack(args)))
            end
        end)
    end
end

function Courier:BindToEvent(eventId: EventId, callback: ServerCallback | ClientCallback)
    local connection
    if RunService:IsServer() then
        connection = self._remoteEvent.OnServerEvent:Connect(function(player, incomingEventId, ...)
            if eventId ~= incomingEventId then return end
            callback(player, ...)
        end)
    else
        connection = self._remoteEvent.OnClientEvent:Connect(function(incomingEventId, ...)
            if eventId ~= incomingEventId then return end
            callback(...)
        end)
    end
    self._trove:Add(connection)
end

function Courier:BindToFunction(functionId: FunctionId, callback: ServerCallback | ClientCallback)
    if RunService:IsServer() then
        self._remoteFunction.OnServerInvoke = function(player, incomingFunctionId, ...)
            if functionId ~= incomingFunctionId then return end
            return callback(player, ...)
        end
    else
        self._remoteFunction.OnClientInvoke = function(incomingFunctionId, ...)
            if functionId ~= incomingFunctionId then return end
            return callback(...)
        end
    end
end

function Courier:Destroy()
    self._trove:Destroy()
end

return Courier