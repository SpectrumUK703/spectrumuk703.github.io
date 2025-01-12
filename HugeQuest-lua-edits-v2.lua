if not HugeQuest then return end

local TICRATE = TICRATE
local FRACUNIT = FRACUNIT
--local ANGLE_22h = ANGLE_22h
--local FRACBITS = FRACBITS
local k_sneakertimer = k_sneakertimer
local k_spinouttimer = k_spinouttimer
local k_wipeoutslow = k_wipeoutslow
local k_driftboost = k_driftboost
local k_driftcharge = k_driftcharge
local k_floorboost = k_floorboost
local k_startboost = k_startboost
local k_itemamount = k_itemamount
local k_itemtype = k_itemtype
local k_rocketsneakertimer = k_rocketsneakertimer
local k_hyudorotimer = k_hyudorotimer
local k_drift = k_drift
local k_speedboost = k_speedboost
local k_boostpower = k_boostpower
local k_accelboost = k_accelboost
local k_invincibilitytimer = k_invincibilitytimer
local k_growshrinktimer = k_growshrinktimer
local k_offroad = k_offroad
local k_itemroulette = k_itemroulette
local k_roulettetype = k_roulettetype
local STARTTIME = 6*TICRATE + (3*TICRATE/4)

local CI = CheckInvincibility
CheckInvincibility = function(p)
	-- TSR
	if tsrb2kr and p.tsr and p.tsr.team and server.tsr_server and server.tsr_server.transfers
		local teamtransfer = server.tsr_server.transfers[p.tsr.team]
		if teamtransfer and teamtransfer[4] == TICRATE*8 - 1 and (p.tsr.teammsg == "TRANSFER!" or p.tsr.teammsg == "CHARITY!") and p.tsr.teammsg_time == 69 --nice
			return true
		end
	end
	return CI(p)
end

local cv_showitemtimers = CV_RegisterVar({
    name = "showitemtimersplustsr",
    defaultvalue = "Yes",
    possiblevalue = CV_YesNo,
})

addHook("ThinkFrame", function()
	if not tsrb2kr then return end
	local HQitemtimers = CV_FindVar("showitemtimers")
	if consoleplayer and HQitemtimers and HQitemtimers.value
		COM_BufInsertText(consoleplayer, "showitemtimers off;showitemtimersplustsr on")
	end
	for p in players.iterate
		if p.mo and p.mo.valid and p.mo.tsr_ultimateon
			if p.oldtsrultimategauge ~= nil and p.tsr.teamultimate ~= nil
				p.tsrultimatedepletion = p.oldtsrultimategauge - p.tsr.teamultimate
			end
			p.oldtsrultimategauge = p.tsr.teamultimate
		else
			p.oldtsrultimategauge = nil
			p.tsrultimatedepletion = nil
		end
	end
end)

local cache = {}

local function cachePatches(v, name, patches)
    cache[name] = {}

    for i = 1, #patches do
        table.insert(cache[name], v.cachePatch(patches[i]))
    end

    return cache[name]
end

hud.add(function(v,p,c)
	if splitscreen return end
	if leveltime < 2 then return end

	if not p.spectator and cv_showitemtimers.value then

		-- name - for cache
        -- timer - timer to use
        -- patches - list of patch names
        -- anim_frames - frames for 1 animation step (used only for invincibility, in fact)
		local timerTable = {
			{
                name = "shoe",
                timer = p.kartstuff[k_sneakertimer],
				hqsuperflag = not (tsrb2kr and p.mo and p.mo.valid and p.mo.tsr_ultimateon),
                patches = {"K_ISSHOE"},
                anim_frames = 1
            },
			{
                name = "invincible",
                timer = p.kartstuff[k_invincibilitytimer],
				hqsuperflag = not p.hugequest.super,
                patches = {"K_ISINV1", "K_ISINV2", "K_ISINV3", "K_ISINV4", "K_ISINV5", "K_ISINV6"},
                anim_frames = 3
            },
			{
                name = "grow",
                timer = p.kartstuff[k_growshrinktimer],
				hqsuperflag = -1,
                patches = {"K_ISGROW"},
                anim_frames = 1
            },
			{
                name = "growplus",
                timer = p.hugequest.huge,
				hqsuperflag = not p.hugequest.super,
                patches = {"K_ISGROW"},
                anim_frames = 1
            },
			{
                name = "superform",
                timer = p.kartstuff[k_invincibilitytimer],
				hqsuperflag = p.hugequest.super,
                patches = {"K_ISEMR1", "K_ISEMR2", "K_ISEMR3", "K_ISEMR4"},
                anim_frames = 3
            },
			{
                name = "rocketsneakers",
                timer = p.kartstuff[k_rocketsneakertimer],
				hqsuperflag = -1,
                patches = {"K_ISRSHE"},
                anim_frames = 1
            },
			{
                name = "hyudoro",
                timer = p.kartstuff[k_hyudorotimer],
				hqsuperflag = -1,
                patches = {"K_ISHYUD"},
                anim_frames = 1
            },
			{
                name = "driftboost",
                timer = p.kartstuff[k_driftboost],
				hqsuperflag = -1,
                patches = {"BSSMA0", "BSSMB0", "BSSMC0", "BSSMD0", "BSSME0", "BSSMF0", "BSSMG0", "BSSMH0"},
                anim_frames = 3,
				color = p.skincolor
            },
			{
                name = "spinout",
                timer = p.kartstuff[k_spinouttimer],
				hqsuperflag = -1,
                patches = {"DIZZA0", "DIZZB0", "DIZZC0", "DIZZD0"},
                anim_frames = 3
            },
			{
                name = "teamultimate",
                timer = (tsrb2kr and p.tsr and p.tsr.teamultimate and p.tsrultimatedepletion and p.tsr.teamultimate/p.tsrultimatedepletion) or 0,
				hqsuperflag = (tsrb2kr and p.mo and p.mo.valid and p.mo.tsr_ultimateon),
                patches = {"K_HMTSR1", "K_HMTSR2"},
                anim_frames = 1
            }
		}
		-- sort table by timer

		table.sort(timerTable, function(a, b)
			if(a.timer ~= nil and b.timer ~= nil) then 
				return a.timer > b.timer 
			end 
		end)

		local hardY = --[[(hpmod and hpmod.running) and 140 or ]] 170
		local iconX = (hpmod and hpmod.running) and 240 or 150

		local iconXOffset = -30
		for i, icon in ipairs(timerTable) do
			if(icon.timer and icon.timer > 0) and icon.hqsuperflag then
				iconXOffset = $ + 30
			end
		end

		iconX = $ - (iconXOffset/2)
		local hasBeenOffset = false
		for i, icon in ipairs(timerTable) do

			-- Draw icon/relevant timer

			local timer

			if icon.timer and icon.timer > 0 and icon.hqsuperflag then

				timer = icon.timer
				
				local minutes = G_TicsToMinutes(timer, true)
                local seconds = G_TicsToSeconds(timer)
                local centiseconds = G_TicsToCentiseconds(timer)
				
				local timerstring = (minutes*60)+seconds.."."..(centiseconds < 9 and "0" or "")..centiseconds
				local transflags = V_SNAPTOBOTTOM
				if(timer < 3) then
					transflags = (leveltime % 5) and $|TR_TRANS30 or $
				end

                local patches = cache[icon.name]

                if patches == nil then
                    patches = cachePatches(v, icon.name, icon.patches)
                end

                local patch_num = (leveltime % (icon.anim_frames * #patches) / icon.anim_frames) + 1
				
				if icon.color then
					v.drawScaled(iconX*FRACUNIT, hardY*FRACUNIT, 6*FRACUNIT/10, patches[patch_num], transflags, v.getColormap(-1, icon.color))
				else
					v.drawScaled(iconX*FRACUNIT, hardY*FRACUNIT, 6*FRACUNIT/10, patches[patch_num], transflags)
				end
				v.drawString(iconX + 7, hardY + 15, timerstring, transflags, "thin")

				iconX = $ + 30
			end


		end

	end
end)

