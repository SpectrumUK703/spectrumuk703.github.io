local k_sneakertimer = k_sneakertimer
local k_speedboost = k_speedboost
local FRACUNIT = FRACUNIT
local TICRATE = TICRATE
local MFE_SPRUNG = MFE_SPRUNG
local hostmodload

local cv_jumpcorrection = CV_RegisterVar({
    name = "jumpcorrection",
    defaultvalue = "On",
    possiblevalue = CV_OnOff,
    flags = CV_NETVAR,
})

local sneakerpowertable = {53740+768, 32768, 17294+768}

-- for stackable panels
local boosttable = {
	{ 53740+768, 75000, 87500},
	{     32768, 49152, 60074},
	{ 17294+768, 32000, 41000}
}

local sneakerpower
local newmomz
local mo
local sector
local special

addHook("ThinkFrame", function()
	if not cv_jumpcorrection.value then return end
	sneakerpower = sneakerpowertable[gamespeed+1]
	for p in players.iterate
		if p.SPSstackedpanels
			sneakerpower = boosttable[gamespeed+1][p.SPSstackedpanels]
		else
			sneakerpower = sneakerpowertable[gamespeed+1]
		end
		p.springjump = $ and $-1 or 0
		mo = p.mo
		if p.spectator
		or not (mo and mo.valid) then continue end
		sector = mo.subsector.sector
		special = GetSecSpecial(sector.special, 3)
		if not P_IsObjectOnGround(mo)
			if not p.jumped
			and p.kartstuff[k_speedboost] > sneakerpower and mo.momz > 0
			and not ((mo.eflags & MFE_SPRUNG) or special == 5 or p.springjump)
				-- In the case of hardsneaker/firmsneaker, this is (50%-27.5%/150%)
				newmomz = ((-mo.momz/256-1)*(1+p.kartstuff[k_speedboost]/256-sneakerpower/256)/(FRACUNIT/256+p.kartstuff[k_speedboost]/256))*256
				--print(mo.momz)
				--print(p.kartstuff[k_speedboost])
				--print(sneakerpower)
				--print(newmomz)
				P_SetObjectMomZ(mo, newmomz, true)
				--print("Jump corrected")
			end
			p.jumped = true
		else
			p.jumped = false
			if (mo.eflags & MFE_SPRUNG) or special == 5
				p.springjump = 10
			end
		end
	end
	if hostmodload or not (server and HOSTMOD and leveltime > TICRATE) then return end
	HM_Scoreboard_AddMod({disp = "JumpCorrection", var = "jumpcorrection"})
	hostmodload = true
end)