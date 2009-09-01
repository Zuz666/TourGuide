
local L = TourGuide.Locale


-- Hidden scanning tooltip

do
	local fTGSTt = CreateFrame( "GameTooltip", "_TGScanningTooltip" )
	fTGSTt.TtTextFS = fTGSTt:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" )
	fTGSTt:AddFontStrings(
		fTGSTt.TtTextFS,
		fTGSTt:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ) )


	function TourGuide:QuestsTranslator()
		local questid, action
		local fails = 0
		fTGSTt:SetOwner( WorldFrame, "ANCHOR_NONE" )

		for i,_ in pairs(self.quests) do
			action = self.actions[i]
			if (action == "ACCEPT" or action == "COMPLETE" or action == "TURNIN") then
				questid = TourGuide:GetObjectiveTag("QID", i)
    	    	if questid then
					fTGSTt:ClearLines()
					fTGSTt:SetHyperlink("quest:"..questid)
					if fTGSTt:IsShown() then
						local questpartnum = self.quests[i]:match(L.PART_MATCH)
						local locquest = fTGSTt.TtTextFS:GetText() -- may be fail if not cached
						if locquest then
							if questpartnum then
								locquest = locquest.." ("..L.PART_TEXT.." "..questpartnum..")"
							end
							self.quests[i] = locquest
						else 
							fails = fails + 1
						end
					else
						fails = fails + 1
					end
				end
			end
		end
		return fails
	end
end


-- Background quest's tooltip scanning

do
	local fTGBgScan = CreateFrame( "Frame", "_TGBackgroundScan" )
	local TicksCounter = 0
	local Reiterations = 0

	function fTGBgScan:OnUpdate( Elapsed )
		TicksCounter = TicksCounter + Elapsed;
		if ( TicksCounter > 1 ) then
			TicksCounter = 0;
			Reiterations = Reiterations + 1
			local fails = TourGuide:QuestsTranslator()
			if fails == 0 then fTGBgScan:Hide() end
			TourGuide:UpdateStatusFrame()
			TourGuide:DebugF (1, "Translating guide: %q. Try: %u. Fails: %u.", TourGuide.db.char.currentguide, Reiterations, fails)
			if Reiterations > 9 then
				fTGBgScan:Hide()
				Reiterations = 0
			end
		end
	end

	fTGBgScan:SetScript( "OnUpdate", fTGBgScan.OnUpdate );
	fTGBgScan:Hide()
	TourGuide.fTGBgScan = fTGBgScan
end


function TourGuide:GuideTitleTranslator(GuideTitle)
	if L.LOC_FLAG and GuideTitle and TourGuide.BZ then
		local _, _, guidetitle, guidetitlelevels = GuideTitle:find("(.+)(%s%([%d%-]+.+%))")
		if TourGuide.BZB[guidetitle] then
			guidetitle = TourGuide.BZ[guidetitle]
            return guidetitle..guidetitlelevels
		end
	end
	return GuideTitle
end

function TourGuide:QuestsZonesTranslator()
	if L.LOC_FLAG and TourGuide.BZ then
		local action, qname
		for i,_ in pairs(self.quests) do
			action = self.actions[i]
			if (action == "FLY" or action == "BOAT" or action == "TURNIN" or action == "HEARTH" or action == "RUN") then
				local _, _, qname, uquestid = self.quests[i]:find("(.+)(@%d+@)")
				if TourGuide.BZB[qname] then
					self.quests[i] = TourGuide.BZ[qname]..uquestid
				end
			end
		end		
	end
end


