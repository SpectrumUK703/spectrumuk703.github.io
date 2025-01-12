-- Copied and edited from Hourglass Pack's Lua

local MAP_ID= "VF"

local RESTORE_TIME= 300*TICRATE

local CV_TO_CHANGE={
    {cvname="juicebox", value= "off"},
}






local function getMapID(n)
    if n<100 then
        return (n<10) and ("0"..n) or tostring(n)
    end

    local x= n-100
    local p= x/36
    local q= x-(36*p)
    local a= string.char(string.byte('A')+p)
    local b= (q<10) and tostring(q) or string.char(string.byte('A')+q-10)

    return a..b
end



local CV_Backups= nil

local function backupAndChangeCV()
    if not CV_Backups then
        CV_Backups= {}
    end

    for i=1,#CV_TO_CHANGE do
        local obj= CV_TO_CHANGE[i]
        local cv= CV_FindVar(obj.cvname)
        if not cv then
            print("ERROR - Counldn't access CVar '"..obj.cvname.."'...")
            continue
        end

        CV_Backups[obj.cvname]= cv.value

        COM_BufInsertText(server,obj.cvname.." "..obj.value)
    end
end

local function restoreCV()
    if not CV_Backups then return end

    for cvname,value in pairs(CV_Backups) do
        local cv= CV_FindVar(cvname)
        if not cv then
            print("ERROR - Counldn't restore CVar '"..cvname.."'...")
            continue
        end

        COM_BufInsertText(server,cvname.." "..value)
    end

    CV_Backups= nil
end


addHook("ThinkFrame", function()
    if leveltime==0 then
        restoreCV()
    end
    
    if getMapID(gamemap)==MAP_ID then
        if leveltime==1 then
            backupAndChangeCV()
        end
        /*if leveltime==RESTORE_TIME then
            restoreCV()
        end*/
    end
end)

addHook("IntermissionThinker", restoreCV)
addHook("VoteThinker", restoreCV)
