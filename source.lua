-- made by vort.5 on discord

local NotificationLibrary = {}

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local NOTIFICATION_HEIGHT = 65
local NOTIFICATION_WIDTH = 250
local PADDING = 10
local TWEEN_TIME = 0.3

local THEME = {
    BACKGROUND = Color3.fromRGB(40, 30, 60),
    ACCENT = Color3.fromRGB(80, 60, 120),
    SECONDARY = Color3.fromRGB(60, 45, 90),
    TEXT = Color3.fromRGB(255, 255, 255),
    PROGRESS = Color3.fromRGB(120, 90, 180)
}

local activeNotifications = {}

local existingGui = CoreGui:FindFirstChild("NotificationSystem")
if existingGui then
    existingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NotificationSystem"
ScreenGui.ResetOnSpawn = false

local success, result = pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not success then
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function updateNotificationPositions()
    local currentPosition = PADDING
    for i, notif in ipairs(activeNotifications) do
        if notif and notif.Frame then
            local targetPosition = UDim2.new(1, -NOTIFICATION_WIDTH - PADDING, 0, currentPosition)
            TweenService:Create(notif.Frame, 
                TweenInfo.new(0.2, Enum.EasingStyle.Quad), 
                {Position = targetPosition}
            ):Play()
            currentPosition = currentPosition + NOTIFICATION_HEIGHT + PADDING
        end
    end
end

function NotificationLibrary:Notify(title, message, duration)
    duration = duration or 5
    
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Size = UDim2.new(0, NOTIFICATION_WIDTH, 0, NOTIFICATION_HEIGHT)
    NotificationFrame.Position = UDim2.new(1, NOTIFICATION_WIDTH, 0, PADDING)
    NotificationFrame.BackgroundColor3 = THEME.BACKGROUND
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = NotificationFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = THEME.TEXT
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotificationFrame
    
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -20, 1, -35)
    MessageLabel.Position = UDim2.new(0, 10, 0, 30)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = THEME.TEXT
    MessageLabel.TextSize = 14
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = NotificationFrame
    
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(0, 4, 1, 0)
    AccentLine.Position = UDim2.new(0, 0, 0, 0)
    AccentLine.BackgroundColor3 = THEME.ACCENT
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = NotificationFrame
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 8)
    AccentCorner.Parent = AccentLine
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 0, 4)
    ProgressBar.Position = UDim2.new(0, 0, 1, -4)
    ProgressBar.BackgroundColor3 = THEME.PROGRESS
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = NotificationFrame

    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 8)
    ProgressCorner.Parent = ProgressBar

    table.insert(activeNotifications, {
        Frame = NotificationFrame,
        StartTime = tick()
    })
    
    updateNotificationPositions()
    
    local slideIn = TweenService:Create(
        NotificationFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -NOTIFICATION_WIDTH - PADDING, 0, NotificationFrame.Position.Y.Offset)}
    )
    slideIn:Play()
    
    local progressTween = TweenService:Create(
        ProgressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, 0, 0, 4)}
    )
    progressTween:Play()
    
    task.delay(duration, function()
        
        for i, notif in ipairs(activeNotifications) do
            if notif.Frame == NotificationFrame then
                table.remove(activeNotifications, i)
                break
            end
        end
        
        local slideOut = TweenService:Create(
            NotificationFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, NOTIFICATION_WIDTH, 0, NotificationFrame.Position.Y.Offset)}
        )
        slideOut:Play()
        
        slideOut.Completed:Connect(function()
            NotificationFrame:Destroy()
            updateNotificationPositions()
        end)
    end)
end

return NotificationLibrary
