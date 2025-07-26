-- Final Working Shovel Script for Alt Farm
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Configuration - MUST SET THESE CORRECTLY
local ALT_USERNAME = "rr2obly256sf" -- Your exact alt username
local ALT_FARM_NAME = ALT_USERNAME.."'s Farm" -- Common farm name format
local PROTECTED_PLANTS = {"Carrot", "Sprinkler"}

-- Services and references
local LocalPlayer = game.Players.LocalPlayer
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local Remove_Item = GameEvents:WaitForChild("Remove_Item")
local DeleteObject = GameEvents:WaitForChild("DeleteObject")
local GetFarm = require(ReplicatedStorage.Modules.GetFarm)
local Notification = require(ReplicatedStorage.Modules.Notification)

-- UI Setup
local ShovelPrompt = LocalPlayer.PlayerGui:WaitForChild("ShovelPrompt")
local ConfirmFrame = ShovelPrompt:WaitForChild("ConfirmFrame")
local FruitName = ConfirmFrame:WaitForChild("FruitName")

-- Highlight effect
local Highlight = Instance.new("Highlight")
Highlight.Name = "ShovelHighlight"
Highlight.Parent = LocalPlayer.PlayerGui
Highlight.FillColor = Color3.fromRGB(255, 50, 50)
Highlight.FillTransparency = 1
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local CurrentCamera = workspace.CurrentCamera

local TargetData = {
    Instance = nil,
    IsPlaceableObject = false,
    IsAltFarm = false
}

-- Enhanced farm detection
local function IsInAltFarm(instance)
    -- First get the root farm model
    local farmModel = nil
    local current = instance
    while current and current ~= workspace do
        if current:FindFirstChild("Plot") or string.find(current.Name, "Farm") then
            farmModel = current
            break
        end
        current = current.Parent
    end
    
    if not farmModel then return false end
    
    -- Check if it matches alt farm naming pattern
    if string.find(farmModel.Name, ALT_USERNAME) then
        return true
    end
    
    -- Additional check for common farm naming formats
    if farmModel.Name == ALT_FARM_NAME then
        return true
    end
    
    -- Check for owner value if exists
    if farmModel:FindFirstChild("Owner") and tostring(farmModel.Owner.Value) == ALT_USERNAME then
        return true
    end
    
    return false
end

-- Shovel validation
local function CanShovel(target)
    local name = target.Name
    
    -- Check protected plants
    for _, protected in pairs(PROTECTED_PLANTS) do
        if string.find(string.lower(name), string.lower(protected)) then
            return false, "This plant is protected and cannot be shoveled!"
        end
    end
    
    -- Check if in alt farm
    local isAltFarm = IsInAltFarm(target)
    if not isAltFarm then
        return false, "You can only shovel plants in your alt farm!"
    end
    
    return true, ""
end

-- Raycasting
local function RaycastToPosition(mousePosition)
    local ray = CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    return workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
end

-- Highlight handling
local function UpdateHighlight()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Shovel [Destroy Plants]") then
        Highlight.Adornee = nil
        return
    end

    local success, raycastResult = pcall(RaycastToPosition, UserInputService:GetMouseLocation())
    if not success or not raycastResult then
        Highlight.Adornee = nil
        return
    end

    local targetModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
    if not targetModel then
        Highlight.Adornee = nil
        return
    end

    local canShovel, reason = CanShovel(targetModel)
    
    if canShovel then
        if Highlight.Adornee ~= targetModel then
            Highlight.FillTransparency = 1
            TweenService:Create(Highlight, TweenInfo.new(0.25), {
                FillTransparency = 0.65
            }):Play()
        end
        Highlight.Adornee = targetModel
    else
        Highlight.Adornee = nil
    end
end

-- Input handling
local function HandleShovelInput(inputPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Shovel [Destroy Plants]") then
        return
    end

    local success, raycastResult = pcall(RaycastToPosition, inputPosition)
    if not success or not raycastResult then return end

    local targetModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
    if not targetModel then return end

    local canShovel, reason = CanShovel(targetModel)
    if not canShovel then
        Notification:CreateNotification(reason)
        return
    end

    FruitName.Text = targetModel.Name
    TargetData.Instance = targetModel
    TargetData.IsPlaceableObject = CollectionService:HasTag(targetModel, "PlaceableObject")
    TargetData.IsAltFarm = true
    ShovelPrompt.Enabled = true
end

-- UI Events
ConfirmFrame.Confirm.MouseButton1Click:Connect(function()
    if TargetData.Instance and TargetData.IsAltFarm then
        if TargetData.IsPlaceableObject then
            DeleteObject:FireServer(TargetData.Instance)
        else
            Remove_Item:FireServer(TargetData.Instance)
        end
    end
    ShovelPrompt.Enabled = false
    TargetData.Instance = nil
end)

local function CancelShovel()
    ShovelPrompt.Enabled = false
    TargetData.Instance = nil
end

ConfirmFrame.Cancel.MouseButton1Click:Connect(CancelShovel)
ConfirmFrame.ExitButton.MouseButton1Click:Connect(CancelShovel)

-- Input setup with error handling
local function SetupInput()
    local function connectInput()
        if UserInputService.TouchEnabled then
            return UserInputService.TouchTapInWorld:Connect(function(_, position)
                HandleShovelInput(position)
            end)
        else
            return UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    HandleShovelInput(UserInputService:GetMouseLocation())
                end
            end)
        end
    end

    while true do
        local connection = connectInput()
        connection:GetPropertyChangedSignal("Connected"):Wait()
        if not connection.Connected then
            task.wait(1)
        else
            break
        end
    end
end

-- Initialize
RunService.RenderStepped:Connect(function()
    pcall(UpdateHighlight)
end)

task.spawn(function()
    while true do
        pcall(SetupInput)
        task.wait(5) -- Reconnect every 5 seconds if needed
    end
end)
