local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.DevPackages.TableUtil)
local TestEZ = require(ReplicatedStorage.DevPackages.TestEZ)

local testFiles = TableUtil.Filter(ReplicatedStorage.Package:GetChildren(), function(v)
    return string.match(v.Name, ".spec") ~= nil
end)

TestEZ.TestBootstrap:run(testFiles)