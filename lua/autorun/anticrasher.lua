if SERVER then
	local Time = CurTime()
	local LagTime = 0
	local Lags = 0 
	local MaxLag = 5
	local MaxLagTime = 4
	local Delay = 2
	local LagInt = 0

	util.AddNetworkString( "SendClrChat" )

	function sendClrChat(str)
		print("[Lags]:", str)

		net.Start( "SendClrChat" )
		net.WriteString( str )
		net.Broadcast()
	end

	function freezeEnt () 
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
					sendClrChat( "Уровень лагов: "..LagInt )

					freezeEnt()
					sendClrChat( "Все энтити заморожены" )
				end
				if LagInt >= 2 then 
					RunConsoleCommand("wire_expression2_quotatick", "0")

					sendClrChat( "Все E2 чипы остановлены" )
				end
			else
				game.CleanUpMap( false, {} )

				sendClrChat( "Карта очищена" )
			end
		else  if Lags>1 then
				sendClrChat( "Уровень лагов сброшен" )
				RunConsoleCommand("wire_expression2_quotatick", "50000")
		end 
		Lags=0 
		LagInt = 0
	end
	end)
end

if CLIENT then 
	function ReceivedClrChat()
		local prefclr = Color(97,255,73)
		local str = net.ReadString()

		chat.AddText( prefclr, "[Lags]: ",  Color(255,255,255), str )
	end

	net.Receive("SendClrChat", ReceivedClrChat)
end 