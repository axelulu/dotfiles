tell application "System Events"
    set processList to (processes where background only is false)
    set pathList to {}
    repeat with proc in processList
        try
            set procPath to file of proc
            set posixPath to POSIX path of procPath
            set end of pathList to posixPath as text
        on error
            -- 忽略无法获取路径的进程
        end try
    end repeat
end tell

-- 提取应用程序名称
set appNameList to {}

repeat with appPath in pathList
    set {TID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "/"}
    set appName to last text item of appPath
    set AppleScript's text item delimiters to "."
    set appName to text item 1 of appName
    set AppleScript's text item delimiters to TID
    set end of appNameList to appName
end repeat

-- 拼接应用程序名称为字符串
set {TID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, ", "}
set resultString to appNameList as text
set AppleScript's text item delimiters to TID

return resultString
