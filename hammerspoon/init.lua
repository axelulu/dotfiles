hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(window, appName)
    if appName == "WezTerm" or appName == "Code" then
        if hs.keycodes.currentSourceID() ~= "com.apple.keylayout.ABC" then
            hs.keycodes.currentSourceID("com.apple.keylayout.ABC") -- 切换到英文输入法
        end
    elseif appName == "微信" or appName == "飞书" or appName == "Google Chrome" or appName == "Telegram" then
        if hs.keycodes.currentSourceID() ~= "com.apple.inputmethod.SCIM.ITABC" then
            hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC") -- 切换到拼音输入法
        end
    end
end)
