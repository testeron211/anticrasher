if SERVER then
	local Time = CurTime()
	local LagTime = 0
	local Lags = 0 
	local MaxLag = 5
	local MaxLagTime = 4
	local Delay = 2
	local LagInt = 0

	util.AddNetworkString( "SendClrChat" )

	function FreezeEnt () 
		local e = ents.GetAll()
		for i = 1,#e do 
			local phys = e[i]:GetPhysicsObject()
			if (IsValid(phys)) then
				phys:EnableMotion(false)
			end
		end
	end

	timer.Create("Lagometer",1/Delay,0,function() 
		LagTime = (SysTime() - CurTime() - Time)*1.02
		Time = Time + LagTime

		if MaxLag<1 then return end
		if (LagTime*Delay)*10 >= MaxLag then 
			if Lags < MaxLagTime then 
				Lags=Lags+LagTime
				if Lags<1 then return end
					LagInt = math.Clamp( math.Round( 10*((Lags*Delay*100)/(MaxLagTime*1000)) ) , 0, MaxLag )
				if LagInt >= 1 then
					net.Start( "SendClrChat" )
					net.WriteTable( Color(255,255,255) )
					net.WriteString( "Уровень лагов: "..LagInt )
					net.Broadcast()

					FreezeEnt()
					net.Start( "SendClrChat" )
					net.WriteTable( Color(255, 255, 77) )
					net.WriteString( "Фриз энтити" )
					net.Broadcast()
				end
				if LagInt >= 2 then 
					RunConsoleCommand("wire_expression2_quotatick", "0")

					net.Start( "SendClrChat" )
					net.WriteTable( Color(255, 77, 77) )
					net.WriteString( "Остановка E2 чипов" )
					net.Broadcast()
				end
			else
				game.CleanUpMap( false, {} )

				net.Start( "SendClrChat" )
				net.WriteTable( Color(255, 77, 77) )
				net.WriteString( "Очистка карты" )
				net.Broadcast()
			end
		else  if Lags>1 then
				net.Start( "SendClrChat" )
				net.WriteTable( Color(77, 255, 77) )
				net.WriteString( "Уровень лагов сброшен" )
				net.Broadcast()
		end 
		Lags=0 
		LagInt = 0
		RunConsoleCommand("wire_expression2_quotatick", "50000")
	end
	end)
end

if CLIENT then 
	function ReceivedClrChat()
		local prefclr = Color(97,255,73)
		local pref = "[Lags] "

		local clr = net.ReadTable()
		local str = net.ReadString()

		chat.AddText( prefclr, pref,  clr, str )
	end

	net.Receive("SendClrChat", ReceivedClrChat)
end 