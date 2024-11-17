-- Lumos v0.1.0 Indev (Codename: Penguin)
-- Copyright 2024 The Lumos Developers. All rights reserved.
-- If you are experiencing issues, make sure HttpService and Adonis _G API are enabled.
-- This Adonis plugin expects that you are already using the main Lumos service
local HttpService = game:GetService("HttpService")
-- all commands below this line are only used internally

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
-- this command gets user data from roblox.
	server.Commands.Lumos_getPlayer = {
		Prefix = server.Settings.Prefix;	-- Prefix to use for command
		Commands = {"getPlayer"};	-- Commands
		Args = {"plr"};	-- Command arguments
		Description = "Gets player info stored by Roblox";	-- Command Description
		Hidden = true; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "SYSTEM";	    -- Admin level; If using settings.CustomRanks set this to the custom rank name (eg. "Baristas")
		Function = function(plr,args)    -- Function to run for command
			local function request()
				local response = HttpService:RequestAsync({
					Url = "", -- the website the request will be sent to; if this is still insomnia please tell hallow to fix it
					Method = "GET",
					Headers = {
						["Content-Type"] = "", -- When sending JSON, set this!
					},
					-- Body =
				})

				if response.Success then
					print("Status code:", response.StatusCode, response.StatusMessage)
					print("Response body:\n", response.Body)
				else
					print("The request failed:", response.StatusCode, response.StatusMessage)
				end
			end

			-- Remember to wrap the function in a 'pcall' to prevent the script from breaking if the request fails
			local success, message = pcall(request)
			if not success then
				print("Http Request failed:", message)
			end
		end
	}
	end
end



-- this command authenticates the player with Lumos
server.Commands.Lumos_authenticate = {
	Prefix = server.Settings.Prefix;	-- Prefix to use for command
	Commands = {"auth"};	-- Commands
	Args = {"plr"};	-- Command arguments
	Description = "Authenticates the player with Lumos";	-- Command Description
	Hidden = true; -- Is it hidden from the command list?
	Fun = false;	-- Is it fun?
	AdminLevel = "SYSTEM";	    -- Admin level; If using settings.CustomRanks set this to the custom rank name (eg. "Baristas")
	Function = function(plr,args)    -- Function to run for command
		local function request()
			local response = HttpService:RequestAsync({
				Url = "", -- the website the request will be sent to; if this is still insomnia please tell hallow to fix it
				Method = "GET",
				Headers = {
					["Content-Type"] = "", -- When sending JSON, set this!
				},
				-- Body =
			})

			if response.Success then
				print("Status code:", response.StatusCode, response.StatusMessage)
				print("Response body:\n", response.Body)
			else
				print("The request failed:", response.StatusCode, response.StatusMessage)
			end
		end

		-- Remember to wrap the function in a 'pcall' to prevent the script from breaking if the request fails
		local success, message = pcall(request)
		if not success then
			print("Http Request failed:", message)
		end
	end 
}



-- all commands above this line are only used internally


-- special lumos-related commands can be found under this line

server.Commands.plrdata = {
	Prefix = server.Settings.Prefix;	-- Prefix to use for command
	Commands = {"plrdata"};	-- Commands
	Args = {"plr.Name"};	-- Command arguments
	Description = "Returns special in-game player data";	-- Command Description
	Hidden = false; -- Is it hidden from the command list?
	Fun = false;	-- Is it fun?
	AdminLevel = "Moderators";	    -- Admin level; If using settings.CustomRanks set this to the custom rank name (eg. "Baristas")
	Function = function(plr,args)    -- Function to run for command
		print("HELLO WORLD FROM AN EXAMPLE COMMAND :)")
		print(`Player supplied args[1] {args[1]}`)
	end
}

-- below this line is what i call the "kernel" for no particular reason. it's essential code that all other code in this plugin depends on. -hallow

settings.CustomRanks = {
	["SYSTEM"] = {
		Level = 9999999;
		Users = {
			--// note to lumos devs: leave this blank; SYSTEM is used for locking 
			--// commands to only be used by lumos and adonis (through _G API)
		};
	};
	
	settings.CustomRanks = {
		["CONSOLE"] = {
			Level = 9999999;
			Users = {
				--// CONSOLE is used for commands that can only be run via
				--// the Lumos Cloud Shell
		};

	
	-- https://github.com/Epix-Incorporated/Adonis-Plugins/blob/master/Server/Server-VerificationLock.luau
	-- this allows game devs to use commands which check certain verification requirements for players
	-- credit to ccuser44 for originally creating this
	local VERIFIED_ASSETS = {102611803, 93078560, 1567446, 18824203}
	local UNVERIFIED_KICK_MESSAGE = "Your account is not verified via email, id, age, group or subscription.\nPlease verify your Roblox account via email."
	local MIN_ACCOUNT_AGE = 7*4*12*5
	local CACHE_CLEAR_TIME = 60
	local BE_IN_GROUP_VERIFIED = false
	local GROUP_ID = 0
	local vcEnabledCache, emailVerifiedCache, isInGroupCache = {}, {}, {}
	local lastCacheClear = os.clock()

	return function(Vargs)
		local server, service = Vargs.Server, Vargs.Service
		local Variables, Functions = server.Variables, server.Functions
		local checkAdmin = server.Admin.CheckAdmin

		local function isVoicechatEnabled(player)
			local userId = player.UserId

			if vcEnabledCache[userId] ~= nil then
				return vcEnabledCache[userId]
			else
				local success, value = pcall(
					service.VoiceChatService.IsVoiceEnabledForUserIdAsync,
					service.VoiceChatService,
					userId
				)

				if success and type(value) == "boolean" then
					vcEnabledCache[userId] = value
					return value
				else
					return false
				end
			end
		end

		local function isEmailVerified(player)
			if emailVerifiedCache[player.UserId] ~= nil then
				return emailVerifiedCache[player.UserId]
			else
				local isVerified = false

				for _, assetId in ipairs(VERIFIED_ASSETS) do
					if service.CheckAssetOwnership(player, assetId) == true then
						isVerified = true
						break
					end
				end

				if isVerified == true then
					emailVerifiedCache[player.UserId] = isVerified
				end

				return isVerified
			end
		end

		local function isInGroup(group, player)
			if not isInGroupCache[group] then
				isInGroupCache[group] = {}
			end

			if isInGroupCache[group][player.UserId] ~= nil then
				return isInGroupCache[group][player.UserId]
			else
				local success, value = pcall(
					player.IsInGroup,
					player,
					group
				)

				if success and type(value) == "boolean" then
					if value == true then
						isInGroupCache[player.UserId] = value
					end

					return value
				else
					return false
				end
			end
		end

		local function isVerified(player)
			if player.MembershipType == Enum.MembershipType.Premium then
				return true
			elseif player.AccountAge >= MIN_ACCOUNT_AGE then
				return true
			elseif player:IsVerified() then
				return true
			elseif isVoicechatEnabled(player) then
				return true
			elseif isEmailVerified(player) then
				return true
			elseif
				BE_IN_GROUP_VERIFIED and
				(GROUP_ID ~= 0 or game.CreatorType == Enum.CreatorType.Group) and
				isInGroup((GROUP_ID ~= 0 and GROUP_ID or game.CreatorId), player)
			then
				return true
			else
				return false
			end
		end

		local function clearDictionary(dictionary)
			for k, _ in pairs(dictionary) do
				dictionary[k] = nil
			end
		end

		Variables.AltVerificationLock = false
		server.Commands.VerificationLock = {
			Prefix = server.Settings.Prefix;
			Commands = {"altlock", "verificationlock", "enableantialt"};
			Args = {"on/off"};
			Description = "Enables/disables server lock";
			AdminLevel = "Admins";
			Function = function(plr: Player, args: {string})
				local arg = args[1] and string.lower(args[1])

				if (not arg and Variables.AltVerificationLock ~= true) or arg == "on" or arg == "true" then
					Variables.AltVerificationLock = true
					Functions.Hint("Server anti-alt verification lock is enabled", service.Players:GetPlayers())
					clearDictionary(vcEnabledCache)
					--clearDictionary(emailVerifiedCache)
					--clearDictionary(isInGroupCache)
				elseif Variables.AltVerificationLock == true or arg == "off" or arg == "false" then
					Variables.AltVerificationLock = false
					Functions.Hint("Server anti-alt verification lock is disabled", service.Players:GetPlayers())
					clearDictionary(vcEnabledCache)
					--clearDictionary(emailVerifiedCache)
					--clearDictionary(isInGroupCache)
				end
			end
		};

		server.Admin.CacheCommands()
		service.HookEvent("PlayerAdded", function(player)
			if Variables.AltVerificationLock == true then
				if not isVerified(player) and not checkAdmin(player) then
					player:Kick(":: Adonis / Lumos ::\n"..UNVERIFIED_KICK_MESSAGE)
				end
			end
		end)
	end
	
	--[[
	Description: Framework to empower surveillance.
	Author: Expertcoderz
	Release Date: 2022-01-28
	Last Updated: 2022-03-11
--]]

			server, service = nil, nil

			local DATASTORE_KEY = "ExportedLogs"

			--// "exporting" = writing of the current server's logs and information to the datastore
			local EXPORT_LOG_IN_STUDIO = false
			local EXPORT_LOG_INTERVAL = 70
			local EXPORT_LOG_ON_CLOSE = true

			--// measured in no. of characters when the data is serialized
			local LOG_SIZE_BEFORE_WARN = 3_000_000
			local CRITICAL_LOG_SIZE = 3_500_000
			local DATASTORE_SIZE_LIMIT = 4_000_000

			local GLOBAL_LOGS_PERMS = {
				--// AdminLevels or rank names eg. "HeadAdmins"
				List = 900,
				Clear = 900,

				Open = 900,
				Delete = 900,

				Export = 900,

				ReceiveOverloadWarning = 900,
			}

			local LOGS_TO_INCLUDE = {
				--// Names of log tables under server.Logs
				"Chats", "Commands", "Exploit", "RemoteFires", --"Interaction", "Economy"
			}
			local INCLUDE_SERVER_OUTPUT_LOG = true

			return function()
				xpcall(function()

					local _serverId = string.format("%x", os.time())
					workspace:SetAttribute("_ServerId", _serverId)

					local GlobalDataStore: DataStore = nil
					if game.GameId == 1360694922 then
						repeat
							task.wait()
							GlobalDataStore = server.Variables.NullLandDataStore
						until GlobalDataStore
					else
						GlobalDataStore = service.DataStoreService:GetDataStore("GlobalLogs")
					end

					local _uniqueJoins: number, _firstJoin: string = {}, nil

					local _serverCountry = select(2, xpcall(function()
						return service.HttpService:JSONDecode(service.HttpService:GetAsync("http://ip-api.com/json")).country
					end, function(err)
						warn("Error fetching server location info;", err)
						return "[Error]"
					end))

					server.Functions.ExportGlobalLog = function(manual: boolean?): boolean?
						if EXPORT_LOG_IN_STUDIO or manual or not service.RunService:IsStudio() then
							return xpcall(function()
								GlobalDataStore:UpdateAsync(DATASTORE_KEY, function(currentLogs)
									if not currentLogs then
										warn("Initial global logging datastore setup")
										currentLogs = {}
									end

									local currentSize = #service.HttpService:JSONEncode(currentLogs)
									if currentSize > CRITICAL_LOG_SIZE then
										warn("GLOBAL EXPORTED LOG STORE CRITICALLY APPROACHING", DATASTORE_SIZE_LIMIT, "CHARACTER LIMIT:", currentSize)
										warn("CLEARING LOGS STARTING FROM EARLIEST UNTIL TOTAL SIZE <=", CRITICAL_LOG_SIZE, "CHARS")
										local ids = {}
										for id in pairs(currentLogs) do table.insert(ids, tonumber(id, 16)) end
										table.sort(ids)
										repeat
											currentLogs[ids[1]] = nil
											table.remove(ids, ids[1])
										until #service.HttpService:JSONEncode(currentLogs) <= CRITICAL_LOG_SIZE
									end

									local dataToExport = {
										_JobId = if game.JobId then tostring(game.JobId) else "[Unknown JobId]";
										_ServerType = if game.PrivateServerOwnerId ~= 0 then "Private"
											elseif game.PrivateServerId ~= "" then "Reserved"
											elseif service.RunService:IsStudio() then "Studio"
											else "Standard";
										_PrivateServerId = if game.PrivateServerId ~= "" then game.PrivateServerId else nil;
										_PrivateServerOwnerId = if game.PrivateServerOwnerId ~= 0 then game.PrivateServerOwnerId else nil;
										_StartTime = math.round(os.time() - time());
										_ServerAge = string.format("%.2f", time() / 60);
										_UniqueJoins = #_uniqueJoins;
										_FirstJoin = _firstJoin or "N/A";
										_ServerCountry = _serverCountry;
									}
									for _, logType in pairs(LOGS_TO_INCLUDE) do
										dataToExport[logType] = server.Logs[logType]
									end
									if INCLUDE_SERVER_OUTPUT_LOG then
										dataToExport.Server = {}
										for i, log in ipairs(service.LogService:GetLogHistory()) do
											dataToExport.Server[i] = {
												Text = log.message,
												Type = log.messageType.Name,
												Time = log.timestamp
											}
										end
									end

									currentLogs[_serverId] = service.HttpService:JSONEncode(dataToExport)
									return currentLogs
								end)
								print("Exported global log for this server", _serverId)
							end, function(err)
								warn("Unable to export to global log datastore:", err)
							end)
						end
						return nil
					end

					task.defer(function()
						if not EXPORT_LOG_INTERVAL or EXPORT_LOG_INTERVAL >= math.huge then return end
						while task.wait(EXPORT_LOG_INTERVAL) do
							server.Functions.ExportGlobalLog()
						end
					end)
					if EXPORT_LOG_ON_CLOSE then game:BindToClose(server.Functions.ExportGlobalLog) end

					service.Events.PlayerAdded:Connect(function(plr: Player)
						if not table.find(_uniqueJoins, plr.UserId) then
							table.insert(_uniqueJoins, plr.UserId)
						end
						if not _firstJoin then _firstJoin = "@"..plr.Name end
						task.defer(function()
							task.wait(3)
							if
								server.Admin.CheckComLevel(server.Admin.GetLevel(plr), GLOBAL_LOGS_PERMS.ReceiveOverloadWarning)
								and select(2, xpcall(function()
									local chars = 0
									for id: string, json: string in pairs(GlobalDataStore:GetAsync(DATASTORE_KEY) or {}) do
										chars += #json
									end
									return chars >= LOG_SIZE_BEFORE_WARN
								end, function(err) warn("Unable to get exported logs store size:", err) return false end))
							then
								server.Remote.MakeGui(plr, "Notification", {
									Title = "Warning!";
									Icon = server.MatIcons.Warning;
									Text = "Global exported log store reaching datastore value limit!";
									Time = 25;
								})
							end
						end)
					end)

					server.Commands.GetServerId = {
						Prefix = server.Settings.PlayerPrefix;
						Commands = {"serverid", "getserverid", "viewserverid"};
						Args = {};
						Description = "Tells you the current server's ID";
						AdminLevel = 0;
						Function = function(plr: Player, args: {string})
							server.Functions.Hint(string.format("The ID of this server is: %s", _serverId), {plr})
						end
					}

					server.Commands.ListExportedLogs = {
						Prefix = server.Settings.Prefix;
						Commands = {"exportedlogs", "globallogs", "listexportedlogs", "getexportedlogs"};
						Args = {};
						Description = "Opens a list of exported global logs";
						AdminLevel = GLOBAL_LOGS_PERMS.List;
						Function = function(plr: Player, args: {string})
							local prefix = server.Settings.Prefix
							local split = server.Settings.SplitKey

							server.Functions.Hint("Loading exported logs...", {plr})

							local globalLogs = select(2, xpcall(function()
								return GlobalDataStore:GetAsync(DATASTORE_KEY) or {}
							end, function(err)
								warn("Error listing global exported logs:", err)
								return nil
							end))
							assert(globalLogs, "Error occurred listing global exported logs")

							local num = 0
							local children = {
								server.Core.Bytecode([[Object:ResizeCanvas(false, true, false, false, 5, 5)]]);
								{
									Class = "UIListLayout";
									SortOrder = Enum.SortOrder.LayoutOrder;
									HorizontalAlignment = Enum.HorizontalAlignment.Center;
									VerticalAlignment = Enum.VerticalAlignment.Top;
								}
							}

							for id: string, json: string in pairs(globalLogs) do
								local decoded = service.HttpService:JSONDecode(json)
								table.insert(children, {
									Class = "TextLabel";
									LayoutOrder = -tonumber(id, 16);
									Size = UDim2.new(1, -10, 0, 30);
									BackgroundTransparency = 1;
									TextXAlignment = "Left";
									Text = "  ["..(server.Remote.Get(plr, "LocallyFormattedTime", decoded._StartTime, true) or "Unknown").."] "..id;
									ToolTip = string.format("#: %s | Type: %s | First Join: %s",
										service.FormatNumber(#json),
										tostring(decoded._ServerType),
										tostring(decoded._FirstJoin)
									);
									ZIndex = 2;
									Children = {
										{
											Class = "TextButton";
											Size = UDim2.new(0, 80, 1, -4);
											Position = UDim2.new(1, -82, 0, 2);
											Text = "Open";
											ToolTip = "#: "..#json;
											ZIndex = 3;
											OnClick = server.Core.Bytecode([[
								if not Object.Parent.ImageButton.Active or not Object.Active then return end
								Object.Active = false
								client.Remote.Send("ProcessCommand", "]]..prefix..[[viewexportedlog]]..split..id..[[")
								wait(1)
								Object.Active = true
								]]);
										},
										{
											Class = "ImageButton";
											Size = UDim2.new(0, 26, 0, 26);
											Position = UDim2.new(1, -110, 0, 2);
											Image = server.MatIcons.Delete;
											ZIndex = 3;
											OnClick = server.Core.Bytecode([[
								if not Object.Active then return end
								Object.Active = false
								client.Remote.Send("ProcessCommand", "]]..prefix..[[delexportedlog]]..split..id..[[")
								Object.Parent:TweenSize(UDim2.new(0, 0, 0, 30), "Out", "Quint", 0.4)
								task.wait(0.3)
								Object.Parent:Destroy()
								]]);
										},
									};
								})
								num += 1
							end

							local len = #service.HttpService:JSONEncode(globalLogs)
							server.Remote.MakeGui(plr, "Window", {
								Name = "ExportedLogs";
								Title = "Exported Logs ("..num..") [#: "..service.FormatNumber(len).."]";
								Icon = server.MatIcons.Description;
								Size  = {330, 250};
								MinSize = {300, 180};
								Content = children;
								Ready = true;
							})
						end
					}

					server.Commands.ViewExportedLog = {
						Prefix = server.Settings.Prefix;
						Commands = {"viewexportedlog", "openexportedlog", "viewgloballog", "opengloballog"};
						Args = {"server ID"};
						Description = "Opens a specific exported log";
						AdminLevel = GLOBAL_LOGS_PERMS.Open;
						Function = function(plr: Player, args: {string})
							assert(args[1], "Server ID not specified")
							server.Remote.MakeGui(plr, "GlobalLogViewer", {ServerId = args[1];})
						end
					}

					server.Remote.Returnables.ExportedLog = function(plr: Player, args)
						if server.Admin.CheckComLevel(server.Admin.GetLevel(plr), GLOBAL_LOGS_PERMS.Open) then
							return select(2, xpcall(function()
								local data = (GlobalDataStore:GetAsync(DATASTORE_KEY) or {})[args[1]]
								return if data then service.HttpService:JSONDecode(data) else nil
							end, function()
								return false
							end))
						end
						server.Remote.RemoveGui(plr, "GlobalLogViewer")
					end

					server.Commands.DeleteExportedLog = {
						Prefix = server.Settings.Prefix;
						Commands = {"delexportedlog", "deleteexportedlog", "delgloballog", "deletegloballog"};
						Args = {"server ID"};
						Description = "Removes a specific exported log from the datastore";
						AdminLevel = GLOBAL_LOGS_PERMS.Delete;
						Function = function(plr: Player, args: {string})
							assert(args[1], "Server ID not specified")
							local success, res = pcall(function()
								local existed = false
								GlobalDataStore:UpdateAsync(DATASTORE_KEY, function(currentLogs)
									if currentLogs and currentLogs[args[1]] then
										existed = true
										currentLogs[args[1]] = nil
									end
									return currentLogs
								end)
								return existed
							end)
							if success then
								server.Functions.Hint((if res then "Successfully deleted global log: " else "Global log not found: ")..args[1], {plr})
							else
								error("An error occurred whilst attempting to call RemoveAsync.")
							end
						end
					}

					server.Commands.ClearExportedLogs = {
						Prefix = server.Settings.Prefix;
						Commands = {"clearexportedlogs"};
						Args = {};
						Description = "Removes all exported logs from the datastore";
						AdminLevel = GLOBAL_LOGS_PERMS.Clear;
						Function = function(plr: Player, args: {string})
							if server.Remote.GetGui(plr, "YesNoPrompt", {Question = "Would you like to delete all exported global logs?"}) == "Yes" then
								if
									pcall(function()
										GlobalDataStore:RemoveAsync(DATASTORE_KEY)
									end)
								then
									server.Functions.Hint("Successfully cleared all global exported logs.", {plr})
								else
									error("Error occurred clearing global exported logs.")
								end
							end
						end
					}

					server.Commands.ExportGlobalLog = {
						Prefix = server.Settings.Prefix;
						Commands = {"exportgloballog", "exportgloballogs", "exportlogs", "exportlog"};
						Args = {};
						Description = "Manually export the global logs for this server";
						AdminLevel = GLOBAL_LOGS_PERMS.Export;
						Function = function(plr: Player, args: {string})
							if server.Functions.ExportGlobalLog(true) then
								server.Functions.Hint("Exported the global log for this server.", {plr})
							else
								error("Error exporting global log for this server.")
							end
						end
					}

				end, function(err)
					warn("[CRITICAL] Global logging plugin failed to load:", err)
				end)
			end
	

--[[

Credits

hallowxd - "wrote" the "majority" of the script
ccuser44 - originally wrote the verification lock before it was implemented here 
Expertcoderz and Dimenpsynol - originally wrote the logging script before it was implemented here





]]
