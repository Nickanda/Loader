--[[
	
                   _____           _             __      _______ 
                  / ____|         | |            \ \    / / ____|
  _ __ ___  _   _| |     ___ _ __ | |_ ___ _ __   \ \  / /| |__  
 | '_ ` _ \| | | | |    / _ \ '_ \| __/ _ \ '__|   \ \/ / |___ \ 
 | | | | | | |_| | |___|  __/ | | | ||  __/ |       \  /   ___) |
 |_| |_| |_|\__, |\_____\___|_| |_|\__\___|_|        \/   |____/ 
             __/ |                                               
            |___/        
                                        
	The DarkBright update - Created by Matthew W - Designed By Joel Desante [https://github.com/JoelDesante]
	
This is the primary game entry point for the myCenter program. This module was created by Matthew W.
	
Please do not modify anything below this line, as it is critical for us to give you the next generation applicationc centers. Thank you for entrusting us with your Applications!
--]]

return function(loaderId)

        local http = game:GetService('HttpService');
        local apiUrl = "https://darkbrightapi.mycenterrblx.net";
        game.StarterPlayer.CameraMaxZoomDistance=30;
        game.StarterPlayer.CameraMinZoomDistance=30;
        game.StarterPlayer.EnableMouseLockOption=false;
        game.StarterPlayer.UserEmotesEnabled=false;

        local function httpEnabled()
            local s = pcall(function()
                game:GetService('HttpService'):GetAsync('http://www.google.com/')
            end)
            return s
        end

        --Make sure HTTPService is enabled
        if httpEnabled() then
            --If enabled
            if loaderId then
                --If there is a loader id


                --Setup Communication Events
                local funct = Instance.new("RemoteFunction"); funct.Parent = game.ReplicatedStorage; funct.Name = "myCenterV6_Function";--this was unncessary
                local event = Instance.new("RemoteEvent")   ;    event.Parent = game.ReplicatedStorage; event.Name =    "myCenterV6_Event";--this was unncessary



                game.Players.PlayerAdded:Connect(function(plr)
                    local isBanned = false;

                    local cl = script:WaitForChild("MCV6_GUI"):Clone();
                    cl.Parent = plr:WaitForChild("PlayerGui");
                    plr.CharacterAdded:wait()
                    plr.Character:WaitForChild("Humanoid").WalkSpeed = 0;
                    plr.Character:WaitForChild("Humanoid").JumpPower = 0;

                    local bansResponse = http:RequestAsync({Url = apiUrl.."/roblox/bans/", Method="GET"});--Get bans
                    local centerBansResponse = http:RequestAsync({Url = apiUrl.."/roblox/center/"..loaderId.."/bans", Method="GET"});--Get center bans
                    if bansResponse.StatusCode == 200 and centerBansResponse.StatusCode == 200 then
                        --If ban came back good
                        bansResponse=http:JSONDecode(bansResponse.Body);
                        centerBansResponse=http:JSONDecode(centerBansResponse.Body);
                        --Get bans in JSON
                        for a,b in pairs (bansResponse.bans) do
                            --Check all for player id
                            if tonumber(b.RobloxId) == tonumber(plr.UserId) then
                                --Found kick player because of pre-existing ban...
                                plr:Kick("myCenter V5 \n The Darkbright Update \n You are globally banned from myCenter \n Reason: "..b.Reason.." \n Banned by: "..b.CreatedBy);
                                isBanned = true;
                                break;
                            end
                        end
                        for a,b in pairs (centerBansResponse.bans) do
                            --Check all for player id
                            if tonumber(b.RobloxId) == tonumber(plr.UserId) then
                                --Found kick player because of pre-existing ban...
                                plr:Kick("myCenter V5 \n The Darkbright Update \n You are banned from this application center, this is not a global myCenter ban; you can still apply at other centers. \n Reason: "..b.Reason.." \n Banned by: "..b.By);
                                isBanned = true;
                                break;
                            end
                        end
                        --Continue if not banned

                    else
                        print("Ban check failed!")
                    end
                end)



                --REMOTE EVENTS
				
                function funct.OnServerInvoke(plr, param, ...)--On RemoteFunction invoke
                    local args={...};
                    if param == "getCenter" then
                            local centerResponse = http:RequestAsync({Url = apiUrl.."/roblox/center/"..loaderId, Method="GET"});
							-- debugging event:FireClient(plr, "print", centerResponse.StatusCode.." "..centerResponse.Body)
                            if centerResponse.StatusCode == 200 then
								centerResponse=http:JSONDecode(centerResponse.Body).center;
                                return centerResponse
                            else
                                --Center could not be loaded
                                plr:Kick("myCenter V5 \n The Darkbright Update \n This center is not correctly configured to run correctly, please tell the owner! If this was working before, it may be possible the center was deleted.")
                            end
                    end

                    if param == "getApplications" then
                        local applications = http:RequestAsync({Url = apiUrl.."/roblox/center/"..loaderId.."/applications", Method="GET"});
                        if applications.StatusCode == 200 then
							applications=http:JSONDecode(applications.Body);
                            return applications;
                        else
                            --Failed to fetch applications
                            return applications;
                        end

                    end

                    if param == "getQuestions" then																   --\/applicationId
                        local questions = http:RequestAsync({Url = apiUrl.."/roblox/center/"..loaderId.."/applications/"..args[1].."/questions", Method="GET"});
                        if questions.StatusCode == 200 then
							questions=http:JSONDecode(questions.Body);
                            return questions;
                        else
                            --Failed to fetch questions
							questions=http:JSONDecode(questions.Body);
                            return questions;
                        end

                    end
                    if param == "canApply" then
                        --https://darkbrightapi.mycenterrblx.net/roblox/center/centerid/application/appid/canApply/id
                        --\/applicationId
                        local canapply = http:RequestAsync({Url = apiUrl.."/roblox/center/"..loaderId.."/application/"..args[1].."/canApply/"..plr.UserId, Method="GET"});
                        canapply=http:JSONDecode(canapply.Body);
                        if canapply.StatusCode == 200 then
                            return canapply;
                        else
                            --Failed to fetch questions
                            return canapply;
                        end
                    end
                    if param == "getLastApplicationStatus" then
                        local lastappstatus = http:RequestAsync({Url = apiUrl.."/roblox/center/"..loaderId.."/applications/"..args[1].."/responses/"..plr.UserId, Method="GET"});
						lastappstatus=http:JSONDecode(lastappstatus.Body);
                        return lastappstatus;
                    end
                    if param == "SubmitApplication" then
                        if args[1].RobloxId == plr.UserId then
                            local centerResponse = http:RequestAsync({Url = apiUrl.."/roblox/center/"..loaderId, Method="GET"});
                            if centerResponse.StatusCode == 200 then
								centerResponse=http:JSONDecode(centerResponse.Body);
                            local submit = http:RequestAsync({Url = apiUrl.."/roblox/center/"..loaderId.."/submit", Method="POST", Headers = {["Content-Type"] = "application/json"}, Body = http:JSONEncode(args[1])});
                            if submit.StatusCode == 200 then
                                if http:JSONDecode(centerResponse.center.Config).placeto == nil == false and http:JSONDecode(centerResponse.center.Config).placeto == 0 == false and http:JSONDecode(centerResponse.center.Config).placeto == "" == false then
                                    local ts = game:GetService("TeleportService");
                                    ts:Teleport(tonumber(http:JSONDecode(centerResponse.center.Config).placeto), plr)
                                end
                                return http:JSONDecode(submit.Body);
                            else
                                --Failed to fetch questions
                                return http:JSONDecode(submit.Body);
                            end
                            else
                                --Center could not be loaded
                                plr:Kick("myCenter V5 \n The Darkbright Update \n This center is not correctly configured to run correctly, please tell the owner! If this was working before, it may be possible the center was deleted.")
                            end
                        else
                            http:PostAsync(apiUrl.."/report/user/game/auto?game="..game.PlaceId.."&user="..plr.UserId)
                            plr:Kick("This has been reported.")
                        end
                    end

                    --END REMOTE FUNCTION
                end

                event.OnServerEvent:Connect(function(plr, param, ...)--On RemoteEvent Invoke
                    local args={...};


                --END REMOTE EVENT
                end)


            else
                --if there is no loader id
                game.Players.PlayerAdded:Connect(function(plr)
                    plr:Kick("myCenter V5 \n The Darkbright Update \n This center is not correctly configured to run correctly, please tell the owner!")
                end)

            end

        else
            --If httpservice is not enabled
            game.Players.PlayerAdded:Connect(function(plr)
                plr:Kick("myCenter V5 \n The Darkbright Update \n It appears as if HTTP Service is disabled, please tell the game owner to enable it!")
            end)
        end

end
