--[[
    Professional Anti-AFK Script
    ============================
    A robust anti-AFK system designed to keep players active in games
    Features: Configurable intervals, random actions, safety checks
    Version: 1.0.0
--]]

local AntiAFK = {}
AntiAFK.__index = AntiAFK

-- Configuration
local CONFIG = {
    enabled = true,
    interval = 30,              -- Seconds between actions (30-120 recommended)
    randomVariation = true,     -- Add random delay to interval
    variationRange = 5,         -- +/- seconds of variation
    logActions = true,          -- Log anti-AFK actions
    maxInactivityTime = 300,    -- Maximum inactivity before warning (seconds)
}

-- Anti-AFK Class
function AntiAFK.new(config)
    local self = setmetatable({}, AntiAFK)
    
    self.config = config or CONFIG
    self.enabled = self.config.enabled
    self.lastActionTime = tick()
    self.actionCount = 0
    self.isRunning = false
    
    return self
end

-- Get next action interval with optional random variation
function AntiAFK:getNextInterval()
    local interval = self.config.interval
    
    if self.config.randomVariation then
        local variation = math.random(-self.config.variationRange, self.config.variationRange)
        interval = interval + variation
    end
    
    return math.max(5, interval) -- Minimum 5 seconds safety threshold
end

-- Perform a random action to appear active
function AntiAFK:performAction()
    if not self.enabled then return end
    
    local actions = {
        function() self:moveCharacter() end,
        function() self:jumpAction() end,
        function() self:rotateCamera() end,
        function() self:useEmote() end,
    }
    
    -- Execute random action
    local randomAction = actions[math.random(1, #actions)]
    local success, err = pcall(randomAction)
    
    if not success then
        self:log("Error performing action: " .. tostring(err))
        return false
    end
    
    self.lastActionTime = tick()
    self.actionCount = self.actionCount + 1
    self:log("Anti-AFK action #" .. self.actionCount .. " executed")
    
    return true
end

-- Movement action
function AntiAFK:moveCharacter()
    -- Implementation depends on game engine
    -- Example for ROBLOX:
    if game and game.Players then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:MoveTo(player.Character.PrimaryPart.Position)
            end
        end
    end
end

-- Jump action
function AntiAFK:jumpAction()
    if game and game.Players then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:Jump()
            end
        end
    end
end

-- Camera rotation action
function AntiAFK:rotateCamera()
    -- Subtle camera rotation to appear active
    if game and game.Workspace then
        local camera = game.Workspace.CurrentCamera
        if camera then
            local currentCFrame = camera.CFrame
            camera.CFrame = currentCFrame * CFrame.Angles(0, math.rad(5), 0)
        end
    end
end

-- Emote action (if available)
function AntiAFK:useEmote()
    -- Implementation depends on game
    self:log("Emote action triggered")
end

-- Start the anti-AFK loop
function AntiAFK:start()
    if self.isRunning then
        self:log("Anti-AFK already running")
        return
    end
    
    self.isRunning = true
    self.enabled = true
    self:log("Anti-AFK system started")
    
    -- Main loop
    while self.isRunning and self.enabled do
        local nextInterval = self:getNextInterval()
        
        -- Wait for next interval
        wait(nextInterval)
        
        -- Check if inactive too long
        local inactiveTime = tick() - self.lastActionTime
        if inactiveTime > self.config.maxInactivityTime then
            self:log("WARNING: Inactive for " .. inactiveTime .. " seconds")
        end
        
        -- Perform action
        self:performAction()
    end
end

-- Stop the anti-AFK system
function AntiAFK:stop()
    self.isRunning = false
    self.enabled = false
    self:log("Anti-AFK system stopped")
end

-- Toggle anti-AFK on/off
function AntiAFK:toggle()
    self.enabled = not self.enabled
    local state = self.enabled and "enabled" or "disabled"
    self:log("Anti-AFK " .. state)
end

-- Get statistics
function AntiAFK:getStats()
    return {
        enabled = self.enabled,
        isRunning = self.isRunning,
        actionCount = self.actionCount,
        lastActionTime = self.lastActionTime,
        timeSinceLastAction = tick() - self.lastActionTime,
    }
end

-- Logging function
function AntiAFK:log(message)
    if self.config.logActions then
        local timestamp = os.date("%H:%M:%S")
        print("[Anti-AFK " .. timestamp .. "]: " .. message)
    end
end

-- Update configuration
function AntiAFK:setConfig(key, value)
    if self.config[key] ~= nil then
        self.config[key] = value
        self:log("Config updated: " .. key .. " = " .. tostring(value))
        return true
    end
    return false
end

-- Get current configuration
function AntiAFK:getConfig()
    return self.config
end

-- ============================================
-- Usage Example
-- ============================================
--[[
    local antiafk = AntiAFK.new({
        enabled = true,
        interval = 45,
        randomVariation = true,
        variationRange = 10,
        logActions = true,
        maxInactivityTime = 300,
    })
    
    -- Start the system
    antiafk:start()
    
    -- Stop when needed
    -- antiafk:stop()
    
    -- Toggle on/off
    -- antiafk:toggle()
    
    -- Check statistics
    -- print(antiafk:getStats())
--]]

return AntiAFK
