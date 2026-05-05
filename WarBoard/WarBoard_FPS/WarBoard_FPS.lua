if not WarBoard_FPS then WarBoard_FPS = {} end
local WarBoard_FPS = WarBoard_FPS
local AvgSum, NbAvg, timer, FPS, AvgFPS, elapsed = 0, 0, 0, 0, 0, 0
local version = "0.3.2"
local LabelSetText, LabelSetTextColor, WindowSetShowing, WindowGetShowing, LabelSetText, LabelSetTextColor, towstring, floor =
	  LabelSetText, LabelSetTextColor, WindowSetShowing, WindowGetShowing, LabelSetText, LabelSetTextColor, towstring, math.floor
local windowName = "WarBoard_FPS"

function WarBoard_FPS.Initialize()
    if WarBoard.AddMod("WarBoard_FPS") then
        if not WarBoard_FPSSettings or version ~= WarBoard_FPSSettings.version then
            WarBoard_FPSSettings =
            {
                ShowAvg = true,
                RefreshRate = 2,
                version = "0.3.2",

                FPSLow = { R = 255, G = 0,   B = 0   },
                AvgLow = { R = 255, G = 0,   B = 0   },

                FPSMed = { R = 255, G = 255, B = 0   },
                AvgMed = { R = 255, G = 255, B = 0   },

                FPSHigh = { R = 0,   G = 255, B = 0   },
                AvgHigh = { R = 0,   G = 255, B = 0   },

                FPSCounter = { Low = 10, Med = 30 },
                AvgCounter = { Low = 10, Med = 30 },
            }
        end

        -- Separator text set ONCE
       -- LabelSetText(windowName.."LabelSep", L"|")

        WarBoard_FPSOptions.Initialize()
    end
end


function WarBoard_FPS.OnOptionsButton()
	WindowSetShowing(windowName.."Options", not WindowGetShowing(windowName.."Options"))
end

function WarBoard_FPS.OnUpdate(elapsed)
	if elapsed > 0 then
		FPS = floor(1/elapsed)
		if WarBoard_FPSSettings.ShowAvg then
			AvgSum = AvgSum + FPS
			NbAvg = NbAvg + 1
			if NbAvg > 100 then
				NbAvg = 1
				AvgSum = 0
			end
			AvgFPS = floor(AvgSum/NbAvg)
		end --End of Average FPS calculus.
		timer = timer+elapsed
		if timer > WarBoard_FPSSettings.RefreshRate then
			WarBoard_FPS.ShowFPS()
			if WarBoard_FPSSettings.ShowAvg then WarBoard_FPS.ShowAvgFPS() end
			timer = 0
		end
	end
end

function WarBoard_FPS.ShowFPS()
	local color
	local counter = WarBoard_FPSSettings.FPSCounter
	LabelSetText(windowName.."LabelFPS", L"FPS: "..towstring(FPS))

	if FPS <= counter.Low then color = WarBoard_FPSSettings.FPSLow
	elseif FPS <= counter.Med then color = WarBoard_FPSSettings.FPSMed
	else color = WarBoard_FPSSettings.FPSHigh end
	LabelSetTextColor(windowName.."LabelFPS", color.R, color.G, color.B)
end

function WarBoard_FPS.ShowAvgFPS()
	local color
	local counter = WarBoard_FPSSettings.AvgCounter
	LabelSetText(windowName.."LabelAvg", L"Avg: "..towstring(AvgFPS))

	if AvgFPS <= counter.Low then color = WarBoard_FPSSettings.AvgLow
	elseif AvgFPS <= counter.Med then color = WarBoard_FPSSettings.AvgMed
	else color = WarBoard_FPSSettings.AvgHigh end
	LabelSetTextColor(windowName.."LabelAvg", color.R, color.G, color.B)
end
