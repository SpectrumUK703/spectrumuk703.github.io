//Based on KartMP's K_handleRespawn function
addHook("MapLoad", function()
	for p in players.iterate
		p.softlocktimer = 0
		p.othersoftlocktimer = 0
	end
end)

addHook("ThinkFrame", do
	for p in players.iterate
		if p.spectator or not p.mo or not p.mo.valid
			p.softlocktimer = 0
			continue
		end
		local mo = p.mo
		if P_IsObjectOnGround(mo)
			p.softlocktimer = $ and $-1
			p.othersoftlocktimer = 0
		end
		if p.kartstuff[k_respawn]
			if (p.softlocktimer 
			or (p.othersoftlocktimer and p.othersoftlocktimer > TICRATE*5))
			and not P_IsObjectOnGround(mo) //We may be softlocked
				local sector = mo.subsector.sector
				for mobj in sector.thinglist()
					if mobj.type == MT_STARPOST //Spawn closer to the starpost
					and P_TryMove(mo, mobj.x, mobj.y)
						P_SetOrigin(mo, (mo.x + mobj.x)/2, (mo.y + mobj.y)/2, (mo.z + mobj.z+128*mapobjectscale*P_MobjFlip(mo))/2)
						p.softlocktimer = 0
						p.othersoftlocktimer = 0
						break
					end
				end
			end
			if P_IsObjectOnGround(mo)
				p.softlocktimer = TICRATE*2
				p.othersoftlocktimer = 0
			else
				p.othersoftlocktimer = $ and $+1 or 1
			end
		end
	end
end)