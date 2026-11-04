local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges)
end)

local COLORS = {
    [0] = {back = {0.12, 0.12, 0.18, 0.92}, text = {0.7, 0.85, 1.0, 1}, accent = {0.3, 0.6, 1.0, 1}},      -- INFO
    [1] = {back = {0.08, 0.18, 0.08, 0.92}, text = {0.5, 1.0, 0.5, 1}, accent = {0.2, 0.8, 0.2, 1}},      -- OK
    [2] = {back = {0.18, 0.08, 0.08, 0.92}, text = {1.0, 0.5, 0.5, 1}, accent = {0.9, 0.2, 0.2, 1}},      -- ERROR
    [3] = {back = {0.18, 0.13, 0.06, 0.92}, text = {1.0, 0.8, 0.4, 1}, accent = {1.0, 0.6, 0.1, 1}},      -- WARN
    [4] = {back = {0.10, 0.10, 0.12, 0.92}, text = {0.7, 0.7, 0.7, 1}, accent = {0.4, 0.4, 0.4, 1}},      -- DEBUG
}

local currentNotification = nil
local list = {}

EXPORTS = {
    __version = '0.1',
    TYPE = {
        INFO = 0,
        OK = 1,
        ERROR = 2,
        WARN = 3,
        DEBUG = 4
    },
    Show = function(text, type, time, colors)
        list = {}
        table.insert(list, {
            text = text,
            type = type or 2,
            time = time or 4,
            start = os.clock(),
            alpha = 0,
            colors = colors or COLORS[type]
        })
        currentNotification = list[1]
    end
}

local newFrame = imgui.OnFrame(
    function() return #list > 0 end,
    function(self)
        self.HideCursor = true
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 400, 200
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('notf_window', _, 0
            + imgui.WindowFlags.AlwaysAutoResize
            + imgui.WindowFlags.NoTitleBar
            + imgui.WindowFlags.NoResize
            + imgui.WindowFlags.NoMove
            + imgui.WindowFlags.NoBackground
        )
        
        local winSize = imgui.GetWindowSize()
        imgui.SetWindowPosVec2(imgui.ImVec2((resX - winSize.x) / 2, (resY - winSize.y) / 2 + resY * 0.3))
        
        imgui.PushFont(big)
        
        if #list > 0 then
            local data = list[1]
            
            local default_data = {
                text = 'text',
                type = 0,
                time = 1500
            }
            for key, v in pairs(default_data) do
                if data[key] == nil then
                    data[key] = v
                end
            end
        
            local textSize = imgui.CalcTextSize(data.text)
            local padding = 16
            local accentWidth = 4
            local size = imgui.ImVec2(accentWidth + padding * 2 + textSize.x, padding * 2 + textSize.y)
        
            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, data.alpha)
            imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 8)
            imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)
            
            -- Тень
            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, data.alpha * 0.25)
            imgui.SetCursorPos(imgui.ImVec2(3, 3))
            imgui.PushStyleColor(imgui.Col.ChildBg, {0, 0, 0, 1})
            imgui.BeginChild('shadow', size, false, 0)
            imgui.EndChild()
            imgui.PopStyleColor()
            imgui.PopStyleVar()
            
            -- Основной фон
            imgui.SetCursorPos(imgui.ImVec2(0, 0))
            imgui.PushStyleColor(imgui.Col.ChildBg, tableToImVec(data.colors.back or COLORS[data.type].back))
            imgui.BeginChild('toastNotf:'..tostring(1)..tostring(data.text), size, false, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
                
                -- Акцентная полоса слева
                imgui.PushStyleColor(imgui.Col.ChildBg, tableToImVec(data.colors.accent or COLORS[data.type].accent))
                imgui.BeginChild('accent', imgui.ImVec2(accentWidth, size.y), false, 0)
                imgui.EndChild()
                imgui.PopStyleColor()
                
                -- Текст
                imgui.SameLine()
                imgui.SetCursorPos(imgui.ImVec2(accentWidth + padding, padding))
                imgui.PushStyleColor(imgui.Col.Text, tableToImVec(data.colors.text or COLORS[data.type].text))
                imgui.Text(data.text)
                imgui.PopStyleColor()
            imgui.EndChild()
            imgui.PopStyleColor()
            imgui.PopStyleVar(3)
        end
        
        imgui.PopFont()
        imgui.End()
    end
)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 14.0, nil, glyph_ranges)
    smal = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 10.0, _, glyph_ranges)
    big = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 16.0, _, glyph_ranges)
end)

function tableToImVec(tbl)
    return imgui.ImVec4(tbl[1], tbl[2], tbl[3], tbl[4])
end

function bringFloatTo(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return from + (count * (to - from) / 100), true
    end
    return (timer > duration) and to or from, false
end

local DEBUG = false

function main()
    if DEBUG then
        for k, v in pairs(EXPORTS.TYPE) do
            EXPORTS.Show('Toast Notification\nType: '..k..' ('..tostring(v)..')', v, 5000)
        end
    end
    while true do
        wait(0)
        if #list > 0 then
            local data = list[1]
            if data.alpha == nil then data.alpha = 0 end
            if os.clock() - data.start < 0.5 then
                data.alpha = bringFloatTo(0, 1, data.start, 0.5)
            elseif data.time - 0.5 < os.clock() - data.start then
                data.alpha = bringFloatTo(1, 0, data.start + data.time - 0.5, 0.5)
            end

            if os.clock() - data.start > data.time then
                list = {}
                currentNotification = nil
            end
        end
    end
end