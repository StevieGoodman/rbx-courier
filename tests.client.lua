local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.DevPackages.TableUtil)
local TestEZ = require(ReplicatedStorage.DevPackages.TestEz)

local testFiles = TableUtil.Filter(ReplicatedStorage.Packages.Package:GetChildren(), function(v)
    return string.match(v.Name, "Client.spec") ~= nil
end)

TestEZ.TestBootstrap:run(testFiles)