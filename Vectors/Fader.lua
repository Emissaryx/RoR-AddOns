--[[
	written by Crestor (crestor@web.de)

	You can use this in your own addons,
	but I would be very happy if you would
	send me a mail or pm me somwhere to tell me where you used it.
	If you really liked it you can also mention me in the credits.


	If the Fader is called in a wrong way it will complain
	in the debug window with a debug message
	but it tries not to crash to keep your addon running.

	Fader.FadeTo(window,alpha,duration,delay,alphastart)
			can simply be called on nearly every window
			where only @window and @alpha are needed to be set to something
			just set every other parameter to nil you don't care about
		@window					[string]	- name of the window you want to animate
		@alpha					[number]	- the alpha value you wish to animate your window to
		@duration				[number]	- how long should the animation take, (default : 0.5)
		@delay					[number]	- how long should the animation be delayed, (default: 0)
		@alphastart				[number]	- from which alpha value should the animation start, (default: the current alpha value of the window)

	Fader.FadeTo_MultiCallSafe(window,alpha,duration,delay,alphastart)
			it is the same as Fader.FadeTo but it can be called multiple times
			on the same window with the same delay, where the last call overwrites the previous ones
			instead of only taking the first one, like Fader.FadeTo is doing

	Fader.StopFade(window)
			stop the current animation on the window
		@window					[string]	- name of the window you want to stop

	Fader.Register(window,duration,delay,callback,disablehiding,nestable)
			if you register you window you can change the the default values
			and you can use some additional features
			just set every parameter to nil you don't care about
		@window					[string]	- name of the window you want to register
		@duration				[number]	- new default duration for your window, (default: nil)
		@delay					[number]	- new default delay for your window, (default: nil)
		@callback				[function]	- callback function that gets called everytime the window gets shown or gets hidden
												or if @nestable is set to true, when the window animation is finished, (default: nil)
		@disablehiding			[boolean]	- if true then disable WindowSetShowing calls to prevent reorderization of the windows, (default: false)
		@nestable				[boolean]	- if true then Fader will wait for the animation to finished and then stop the animation
												this is required so we can animate the child windows of this window afterwards (default: false)
		@disablesafetychecks	[boolean]	- if true disables runtime safetychecks for performance, (default: false)

	Fader.Unregister(window)
			unregister your window
		@window			- name of the window you want to unregister
]]

local version=1.4
if(Fader and Fader.version>=version)then return end
if(Fader and Fader.version<=1.3)then WindowUnregisterCoreEventHandler("Root","OnUpdate") end
Fader=Fader or {}
local Fader=Fader

Fader.version=version
if(not DoesWindowExist("Fader_Update"))then
	CreateWindowFromTemplate("Fader_Update","EA_Window_Default","Root")
	WindowRegisterCoreEventHandler("Fader_Update","OnUpdate","Fader.Update")
end

do
	local function setvariable(variable,value)
		Fader[variable]=Fader[variable] or value
	end
	setvariable("_windows",{})
	setvariable("_fade_out",{})
	setvariable("_fade_stop",{})
	setvariable("_queue",{})
end

local timer=0

local std_duration=0.5
local empty={}
local SINGLE_NO_RESET=Window.AnimationType.SINGLE_NO_RESET
local DoesWindowExist=DoesWindowExist
local type=type
local pairs=pairs
local WindowGetShowing=WindowGetShowing
local WindowSetShowing=WindowSetShowing
local WindowGetAlpha=WindowGetAlpha
local WindowSetAlpha=WindowSetAlpha
local WindowStartAlphaAnimation=WindowStartAlphaAnimation
local WindowStopAlphaAnimation=WindowStopAlphaAnimation

local function print(w,s)
	d("Fader (\""..tostring(w).."\"): "..s)
	return true
end

local function fade(window,alpha,duration,delay,alphastart,callback)
	local hidden
	if(WindowGetShowing(window)==false)
	then
		if(alpha>0)
		then
			WindowSetShowing(window,true)
		end
		hidden=0
	else
		callback=nil
	end
	local state=alphastart or hidden or WindowGetAlpha(window)
	if(alphastart or state~=alpha)
	then
		WindowStartAlphaAnimation(window,SINGLE_NO_RESET,state,alpha,duration,hidden~=nil,delay,0)
		local data=Fader._windows[window]
		if(alpha==0 and (not data or (not data.disablehiding or data.callback)))
		then
			Fader._fade_out[window]=delay+duration
		else
			Fader._fade_out[window]=nil
		end
		if(data and data.nestable)
		then
			local timer=Fader._fade_stop[window]
			local newtimer=delay+duration
			if(timer and timer>newtimer)
			then
				Fader._fade_stop[window]=newtimer
				data.target=alpha
			end
		else
			Fader._fade_stop[window]=nil
		end
	end
	if(hidden~=nil and callback)then pcall(callback,window,true) end
	return true
end


function Fader.Register(window,duration,delay,callback,disablehiding,nestable,disablesafetychecks)
	if(not disablesafetychecks)then
	if(		not DoesWindowExist(window) and print(window,"Window "..window.." does not exist.") or
			(duration~=nil and type(duration)~="number") and print(window,"duration is not a number, got a "..type(duration)..".") or
			(delay~=nil and type(delay)~="number") and print(window,"delay is not a number, got a "..type(delay)..".") or
			(callback~=nil and type(callback)~="function") and print(window,"callback is not a function, got a "..type(callback)..".")
		)then return false end end
	Fader._windows[window]={["duration"]=duration,["delay"]=delay,["callback"]=callback,["disablehiding"]=disablehiding,["nestable"]=nestable,["disablesafetychecks"]=disablesafetychecks~=nil}
	return true
end

function Fader.Unregister(window)
	if(Fader._windows[window])
	then
		Fader._windows[window]=nil
		Fader._fade_out[window]=nil
		Fader._fade_stop[window]=nil
		return true
	end
	return false
end

function Fader.FadeTo(window,alpha,duration,delay,alphastart)
	local data=Fader._windows[window] or empty
	duration=duration or data.duration or std_duration
	delay=delay or data.delay or 0
	if(not data.disablesafetychecks)then
	if(		not DoesWindowExist(window) and print(window,"Window "..window.." does not exist.") or
			type(alpha)~="number" and print(window,"alpha is not a number, got a "..type(alpha)..".") or
			type(duration)~="number" and print(window,"duration is not a number, got a "..type(duration)..".") or
			type(delay)~="number" and print(window,"delay is not a number, got a "..type(delay)..".") or
			(alphastart~=nil and type(alphastart)~="number") and print(window,"alphastart is not a number, got a "..type(alphastart)..".")
		)then return false end end
	return fade(window,alpha,duration,delay,alphastart,data and data.callback)
end

function Fader.FadeTo_MultiCallSafe(window,alpha,duration,delay,alphastart)
	local data=Fader._windows[window] or empty
	duration=duration or data.duration or std_duration
	delay=delay or data.delay or 0
	if(not data.disablesafetychecks)then
	if(		not DoesWindowExist(window) and print(window,"Window "..window.." does not exist.") or
			type(alpha)~="number" and print(window,"alpha is not a number, got a "..type(alpha)..".") or
			type(duration)~="number" and print(window,"duration is not a number, got a "..type(duration)..".") or
			type(delay)~="number" and print(window,"delay is not a number, got a "..type(delay)..".") or
			(alphastart~=nil and type(alphastart)~="number") and print(window,"alphastart is not a number, got a "..type(alphastart)..".")
		)then return false end end
	Fader._queue[window..delay]={window,alpha,duration,delay,alphastart,data and data.callback}
	return true
end

function Fader.StopFade(window)
	local alpha=WindowGetAlpha(window)
	WindowStopAlphaAnimation(window)
	WindowSetAlpha(window,alpha)
end

function Fader.Update(elapsed)
	for i,k in pairs(Fader._queue)
	do
		fade(unpack(k))
		Fader._queue[i]=nil
	end

	timer=timer+elapsed
	if(timer<0.2)then return end
	for i,k in pairs(Fader._fade_out)
	do
		Fader._fade_out[i]=k-timer
		if(Fader._fade_out[i]<0)
		then
			local data=Fader._windows[i]
			if(data and data.disablesafetychecks or DoesWindowExist(i))
			then
				if(WindowGetAlpha(i)==0)
				then
					if(data)
					then
						if(not data.disablehiding)then WindowSetShowing(i,false) end
						if(data.callback)then pcall(data.callback,i,false)end
					else
						WindowSetShowing(i,false)
					end
					Fader._fade_out[i]=nil
				end
			else
				print(i,"Window "..i.." does not exist anymore.")
				Fader._fade_out[i]=nil
			end
		end
	end
	for i,k in pairs(Fader._fade_stop)
	do
		Fader._fade_stop[i]=k-timer
		if(Fader._fade_stop[i]<0)
		then
			local data=Fader._windows[i]
			if(data and (data.disablesafetychecks or DoesWindowExist(i)))
			then
				local alpha=WindowGetAlpha(i)
				if(data.nestable and alpha==data.target)
				then
					WindowStopAlphaAnimation(i)
					WindowSetAlpha(i,alpha)
					if(data.callback)then pcall(data.callback,i,alpha)end
					Fader._fade_stop[i]=nil
				end
			else
				if(data)then print(i,"Window "..i.." does not exist anymore.")
				else print(i,"Data for Window "..i.." does not exist anymore.") end
				Fader._fade_stop[i]=nil
			end
		end
	end
end