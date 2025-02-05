local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Courier = require(ReplicatedStorage.Packages.Package)

return function()

    local courier
    it("can create a new Courier", function()
        courier = Courier.new("TestCourier")
        expect(courier).never.to.be.equal(nil)
    end)

    it("can send events", function()
        Players.PlayerAdded:Wait()
        local testEvent = courier:GetEvent("TestEvent")
        expect(testEvent).never.to.be.equal(nil)
        testEvent("Hello from the server!")
    end)

    it("can recieve incoming events", function()
        local player
        local result
        courier:BindToEvent("TestEvent", function(plr, ...)
            player = plr
            result = ...
        end)
        local startTime = os.clock()
        repeat task.wait()
        until result ~= nil or os.clock() - startTime > 10
        expect(player).to.be.equal(Players.ithacaTheEnby)
        expect(result).to.be.equal("Hello from the client!")
    end)

    it("can call functions", function()
        local testFunction = courier:GetFunction("TestFunction")
        expect(testFunction).never.to.be.equal(nil)
        local success, result = testFunction(Players.ithacaTheEnby, "Hello from the server!"):await()
        expect(success).to.be.equal(true)
        expect(result).to.be.equal("Hello from the client!")
    end)

    it("can recieve incoming functions", function()
        local player
        local result
        courier:BindToFunction("TestFunction", function(plr, ...)
            player = plr
            result = ...
            return string.gsub(result, "client", "server")
        end)
        local startTime = os.clock()
        repeat task.wait()
        until result ~= nil or os.clock() - startTime > 10
        expect(player).to.be.equal(Players.ithacaTheEnby)
        expect(result).to.be.equal("Hello from the client!")
    end)

    afterAll(function()
        courier:Destroy()
    end)

end