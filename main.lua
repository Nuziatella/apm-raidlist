local api = require("api")

local addon = {
    name = "APM RaidList",
    author = "Nuzi",
    version = "1.1.0",
    desc = "Raid class reporter"
}

local COMMAND_RAIDLIST = "!raidlist"
local COMMAND_RAIDCLASSES = "!raidclasses"
local COMMAND_ALIAS = "!apmraidlist"

local function logInfo(message)
    if api.Log ~= nil and api.Log.Info ~= nil then
        api.Log:Info("[APM RaidList] " .. tostring(message or ""))
    end
end

local function trim(value)
    return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function getUnitName(unit)
    local unitId = nil
    if api.Unit ~= nil and api.Unit.GetUnitId ~= nil then
        unitId = api.Unit:GetUnitId(unit)
    end

    if unitId ~= nil and api.Unit ~= nil and api.Unit.GetUnitNameById ~= nil then
        local ok, name = pcall(function()
            return api.Unit:GetUnitNameById(unitId)
        end)
        if ok and trim(name) ~= "" then
            return trim(name), unitId
        end
    end

    if api.Unit ~= nil and api.Unit.UnitInfo ~= nil then
        local ok, info = pcall(function()
            return api.Unit:UnitInfo(unit)
        end)
        if ok and type(info) == "table" and trim(info.name) ~= "" then
            return trim(info.name), unitId
        end
    end

    return "", unitId
end

local function getUnitClass(unit)
    if api.Ability ~= nil and api.Ability.GetUnitClassName ~= nil then
        local ok, className = pcall(function()
            return api.Ability:GetUnitClassName(unit)
        end)
        if ok and trim(className) ~= "" then
            return trim(className)
        end
    end

    if api.Unit ~= nil and api.Unit.UnitClass ~= nil then
        local ok, className = pcall(function()
            return api.Unit:UnitClass(unit)
        end)
        if ok and trim(className) ~= "" then
            return trim(className)
        end
    end

    return "Unknown"
end

local function collectRaidMembers()
    local members = {}
    local seen = {}

    for index = 1, 50 do
        local unit = "team" .. tostring(index)
        local name, unitId = getUnitName(unit)
        local key = unitId ~= nil and ("id:" .. tostring(unitId)) or ("name:" .. string.lower(name))
        if name ~= "" and not seen[key] then
            seen[key] = true
            table.insert(members, {
                unit = unit,
                name = name,
                class_name = getUnitClass(unit)
            })
        end
    end

    if #members == 0 then
        local playerName, playerId = getUnitName("player")
        if playerName ~= "" then
            local playerKey = playerId ~= nil and ("id:" .. tostring(playerId)) or ("name:" .. string.lower(playerName))
            if not seen[playerKey] then
                table.insert(members, {
                    unit = "player",
                    name = playerName,
                    class_name = getUnitClass("player")
                })
            end
        end
    end

    table.sort(members, function(a, b)
        local classA = string.lower(a.class_name or "")
        local classB = string.lower(b.class_name or "")
        if classA ~= classB then
            return classA < classB
        end
        return string.lower(a.name or "") < string.lower(b.name or "")
    end)

    return members
end

local function buildSummary(members)
    local counts = {}
    local ordered = {}

    for _, member in ipairs(members) do
        local className = trim(member.class_name)
        if className == "" then
            className = "Unknown"
        end
        if counts[className] == nil then
            counts[className] = 0
            table.insert(ordered, className)
        end
        counts[className] = counts[className] + 1
    end

    table.sort(ordered, function(a, b)
        return string.lower(a) < string.lower(b)
    end)

    local parts = {}
    for _, className in ipairs(ordered) do
        table.insert(parts, string.format("%s x%d", className, counts[className]))
    end

    return table.concat(parts, ", ")
end

local function buildGroups(members)
    local groups = {}
    local ordered = {}

    for _, member in ipairs(members) do
        local className = trim(member.class_name)
        if className == "" then
            className = "Unknown"
        end
        if groups[className] == nil then
            groups[className] = {}
            table.insert(ordered, className)
        end
        table.insert(groups[className], member.name)
    end

    table.sort(ordered, function(a, b)
        return string.lower(a) < string.lower(b)
    end)

    for _, className in ipairs(ordered) do
        table.sort(groups[className], function(a, b)
            return string.lower(a) < string.lower(b)
        end)
    end

    return groups, ordered
end

local function printRaidClasses()
    local members = collectRaidMembers()
    if #members == 0 then
        logInfo("No raid or party members found.")
        return
    end

    logInfo(string.format("Classes (%d): %s", #members, buildSummary(members)))
end

local function printRaidList()
    local members = collectRaidMembers()
    if #members == 0 then
        logInfo("No raid or party members found.")
        return
    end

    local groups, ordered = buildGroups(members)
    logInfo(string.format("Raid List (%d)", #members))

    for _, className in ipairs(ordered) do
        local names = groups[className] or {}
        logInfo(string.format("%s (%d): %s", className, #names, table.concat(names, ", ")))
    end
end

local function handleCommand(raw)
    local lowered = string.lower(raw)
    if lowered == COMMAND_RAIDLIST then
        printRaidList()
        return true
    end
    if lowered == COMMAND_RAIDCLASSES or lowered == COMMAND_ALIAS then
        printRaidClasses()
        return true
    end
    return false
end

local function handleChatMessage(_, _, _, _, message)
    local raw = trim(message)
    if raw == "" then
        return
    end
    handleCommand(raw)
end

local function onLoad()
    api.On("CHAT_MESSAGE", handleChatMessage)
    pcall(function()
        api.On("COMMUNITY_CHAT_MESSAGE", handleChatMessage)
    end)
    logInfo("Loaded. Use !raidlist or !raidclasses.")
end

local function onUnload()
    api.On("CHAT_MESSAGE", function() end)
    pcall(function()
        api.On("COMMUNITY_CHAT_MESSAGE", function() end)
    end)
end

local function onSettingToggle()
    printRaidList()
end

addon.OnLoad = onLoad
addon.OnUnload = onUnload
addon.OnSettingToggle = onSettingToggle

return addon
