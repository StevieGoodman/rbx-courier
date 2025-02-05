local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Courier = require(ReplicatedStorage.Packages.Package)

return function()

    local courier
    it("can create a new Courier", function()
        courier = Courier.new("TestCourier")
        expect(courier).never.to.be.equal(nil)
    end)

    it("can send events", function()
        local testEvent = courier:GetEvent("TestEvent")
        expect(testEvent).never.to.be.equal(nil)
        testEvent("Hello from the client!")
    end)

    it("can recieve incoming events", function()
        local result
        courier:BindToEvent("TestEvent", function(...)
            result = ...
        end)
        local startTime = os.clock()
        repeat task.wait()
        until result ~= nil or os.clock() - startTime > 10
        expect(result).to.be.equal("Hello from the server!")
    end)

    it("can recieve incoming functions", function()
        local result
        courier:BindToFunction("TestFunction", function(...)
            result = ...
            return string.gsub(result, "server", "client")
        end)
        local startTime = os.clock()
        repeat task.wait()
        until result ~= nil or os.clock() - startTime > 10
        expect(result).to.be.equal("Hello from the server!")
    end)

    it("can call functions", function()
        local testFunction = courier:GetFunction("TestFunction")
        expect(testFunction).never.to.be.equal(nil)
        local success, result = testFunction("Hello from the client!"):await()
        expect(success).to.be.equal(true)
        expect(result).to.be.equal("Hello from the server!")
    end)

    afterAll(function()
        courier:Destroy()
    end)
end