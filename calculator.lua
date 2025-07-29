-- Services you'll need in Roblox
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- --- CONFIGURATION ---
-- Updated list of modifiers for Rainbow mutation
local MODIFIERS = {
    "Shocked",
    "Frozen",
    "Choc",
    "Moonlit",
    "Bloodlit",
    "Celestial",
    "Disco",
    "Zombified",
    "Plasma",
    "Voidtouched",
    "Pollinated",
    "Honeyglazed",
    "Heavenly",
    "Cooked",
    "Molten",
    "Meteoric",
    "Alienlike",
    "Paradisal",
    "Galactic",
    "Aurora",
    "Cloudtouched",
    "Fried",
    "Ceramic",
    "Ancientamber",
    "Sandy",
    "Tempestous",
    "Friendbound",
    "Infected",
    "Tranquil",
    "Toxic",
    "Radioactive",
    "Corrupt",
    "Subzero",
    "Blitzshock",
    "Jackpot",
    "Touchdown",
    "Static",
    "Harmonisedfoxfire",
    "Harmonisedchakra"
}

-- Constants
local RAINBOW_MULTIPLIER = 50
local NUMBER_OF_MODIFIERS = #MODIFIERS
local SUM_OF_MODIFIERS = NUMBER_OF_MODIFIERS  -- Since each modifier adds +1

-- Calculate the combined modifier part once, as it's constant
local COMBINED_MODIFIER_PART = RAINBOW_MULTIPLIER * (1 + SUM_OF_MODIFIERS - NUMBER_OF_MODIFIERS)
print("[BaseValueCalculator] Initialized Combined Modifier Part:", COMBINED_MODIFIER_PART)
print("[BaseValueCalculator] Number of Modifiers:", NUMBER_OF_MODIFIERS)
print("[BaseValueCalculator] Sum of Modifiers:", SUM_OF_MODIFIERS)

-- --- UI CREATION AND NOTIFICATION ---

-- Notification UI elements (re-used from your previous script)
local notificationFrame
local titleLabel
local messageLabel

-- Function to create and manage the sliding notification UI
local function createNotification(title, message)
    -- Initialize UI elements if they don't exist
    if not notificationFrame then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            warn("PlayerGui not found! Cannot create UI notification.")
            warn("--- Notification: " .. title .. " ---")
            warn(message)
            return
        end

        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "BaseValueCalculatorNotificationGui" -- Unique name
        notificationGui.Parent = playerGui
        notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        notificationFrame = Instance.new("Frame")
        notificationFrame.Name = "NotificationFrame"
        notificationFrame.Size = UDim2.new(0.3, 0, 0.1, 0) -- 30% width, 10% height of screen
        notificationFrame.Position = UDim2.new(0.5, 0, 0.9, 0) -- Centered near bottom
        notificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        notificationFrame.BackgroundTransparency = 0.1
        notificationFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
        notificationFrame.BorderSizePixel = 2
        notificationFrame.Parent = notificationGui
        notificationFrame.Visible = false -- Start invisible

        titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        titleLabel.BackgroundTransparency = 0.2
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center
        titleLabel.Parent = notificationFrame
        titleLabel.ZIndex = 2 -- Ensure labels are above frame

        messageLabel = Instance.new("TextLabel")
        messageLabel.Name = "MessageLabel"
        messageLabel.Size = UDim2.new(1, 0, 0.7, 0)
        messageLabel.Position = UDim2.new(0, 0, 0.3, 0)
        messageLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        messageLabel.BackgroundTransparency = 0.5
        messageLabel.TextScaled = true
        messageLabel.Font = Enum.Font.SourceSans
        messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        messageLabel.TextWrapped = true
        messageLabel.TextXAlignment = Enum.TextXAlignment.Center
        messageLabel.TextYAlignment = Enum.TextYAlignment.Center
        messageLabel.Parent = notificationFrame
        messageLabel.ZIndex = 2 -- Ensure labels are above frame

        -- Add a UI Corner for a smoother look
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = notificationFrame
    end

    -- Update text and make visible
    titleLabel.Text = title
    messageLabel.Text = message
    notificationFrame.Visible = true

    -- Tween the notification in (slide up slightly)
    local initialPos = UDim2.new(0.5, 0, 0.9, 0) -- Always show at the bottom center
    notificationFrame.Position = initialPos + UDim2.new(0, 0, 0.05, 0) -- Start slightly lower to slide up
    notificationFrame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1

    -- Fade in and slide up
    TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = initialPos,
        BackgroundTransparency = 0.1
    }):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    TweenService:Create(messageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    task.delay(4, function() -- Display for 4 seconds
        -- Fade out and slide down
        TweenService:Create(notificationFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = initialPos + UDim2.new(0, 0, 0.05, 0), -- Slide back down
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(messageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()

        task.delay(0.7, function() -- Wait for fade out to complete before making invisible
            notificationFrame.Visible = false
        end)
    end)
end

-- --- MAIN CALCULATOR UI ---

-- Ensure the PlayerGui is ready before creating UI
task.spawn(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    local calculatorGui = Instance.new("ScreenGui")
    calculatorGui.Name = "BaseValueCalculatorUI"
    calculatorGui.Parent = playerGui
    calculatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Important for layering

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "CalculatorFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 220) -- Slightly larger to accommodate more info
    mainFrame.Position = UDim2.new(0.5, -150, 0.2, 0) -- Centered top part of screen
    mainFrame.AnchorPoint = Vector2.new(0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.Draggable = true -- Make it draggable
    mainFrame.Parent = calculatorGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    local titleBar = Instance.new("TextLabel")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    titleBar.BackgroundTransparency = 0.2
    titleBar.Text = "Base Value Calculator (Updated)"
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleBar.TextScaled = true
    titleBar.TextWrapped = true
    titleBar.TextXAlignment = Enum.TextXAlignment.Center
    titleBar.TextYAlignment = Enum.TextYAlignment.Center
    titleBar.Parent = mainFrame
    
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Name = "WeightLabel"
    weightLabel.Size = UDim2.new(0.9, 0, 0, 20)
    weightLabel.Position = UDim2.new(0.05, 0, 0, 40)
    weightLabel.Text = "Plant Weight (kg):"
    weightLabel.Font = Enum.Font.SourceSans
    weightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    weightLabel.BackgroundTransparency = 1
    weightLabel.TextXAlignment = Enum.TextXAlignment.Left
    weightLabel.TextScaled = true
    weightLabel.Parent = mainFrame

    local weightInput = Instance.new("TextBox")
    weightInput.Name = "WeightInput"
    weightInput.Size = UDim2.new(0.9, 0, 0, 30)
    weightInput.Position = UDim2.new(0.05, 0, 0, 65)
    weightInput.PlaceholderText = "e.g., 147"
    weightInput.Text = "147" -- Default value from example
    weightInput.Font = Enum.Font.SourceSans
    weightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    weightInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    weightInput.BackgroundTransparency = 0.2
    weightInput.Parent = mainFrame
    weightInput.ClearTextOnFocus = false -- Don't clear on click
    weightInput.TextScaled = true

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.9, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.05, 0, 0, 100)
    valueLabel.Text = "Plant Sold Value ($):"
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextScaled = true
    valueLabel.Parent = mainFrame

    local valueInput = Instance.new("TextBox")
    valueInput.Name = "ValueInput"
    valueInput.Size = UDim2.new(0.9, 0, 0, 30)
    valueInput.Position = UDim2.new(0.05, 0, 0, 125)
    valueInput.PlaceholderText = "e.g., 45643009995436"
    valueInput.Text = "45643009995436" -- Default value from example
    valueInput.Font = Enum.Font.SourceSans
    valueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    valueInput.BackgroundTransparency = 0.2
    valueInput.Parent = mainFrame
    valueInput.ClearTextOnFocus = false -- Don't clear on click
    valueInput.TextScaled = true

    local calculateButton = Instance.new("TextButton")
    calculateButton.Name = "CalculateButton"
    calculateButton.Size = UDim2.new(0.8, 0, 0, 30)
    calculateButton.Position = UDim2.new(0.1, 0, 0, 160)
    calculateButton.Text = "Calculate Base Value"
    calculateButton.Font = Enum.Font.SourceSansBold
    calculateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    calculateButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    calculateButton.BackgroundTransparency = 0.1
    calculateButton.Parent = mainFrame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(0.9, 0, 0, 20)
    infoLabel.Position = UDim2.new(0.05, 0, 0, 195)
    infoLabel.Text = "Using "..NUMBER_OF_MODIFIERS.." modifiers"
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.TextScaled = true
    infoLabel.Parent = mainFrame

    -- Button click logic
    calculateButton.MouseButton1Click:Connect(function()
        local plantWeight = tonumber(weightInput.Text)
        local plantSoldValue = tonumber(valueInput.Text)

        if not plantWeight or not plantSoldValue then
            createNotification("Input Error", "Please enter valid numbers for both weight and value.")
            return
        end

        print(string.format("[BaseValueCalculator] Received Weight: %.5f kg", plantWeight))
        print(string.format("[BaseValueCalculator] Received Sold Value: %.0f", plantSoldValue))

        if plantWeight <= 0 then
            createNotification("Calculation Error", "Weight must be greater than zero.")
            return
        end

        if COMBINED_MODIFIER_PART == 0 then
            createNotification("Configuration Error", "Combined Modifier Part cannot be zero. Check constants.")
            return
        end

        local denominator = (plantWeight ^ 2) * COMBINED_MODIFIER_PART
        if denominator == 0 then
            createNotification("Calculation Error", "Denominator became zero during calculation. Cannot divide.")
            return
        end

        local calculatedBaseValue = plantSoldValue / denominator

        print(string.format("[BaseValueCalculator] Calculated Base Value: %.15f", calculatedBaseValue))
        createNotification(
            "Calculated Base Value!",
            string.format("For %.3fkg plant with %d modifiers, sold for $%.0f:\nBase Value: %.15f",
                          plantWeight, NUMBER_OF_MODIFIERS, plantSoldValue, calculatedBaseValue)
        )
    end)

    -- Initial notification that the UI is ready
    createNotification("Base Value Calculator UI", "Window open! Enter values and click 'Calculate'.")
end)
