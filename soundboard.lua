function logger(s)
	local PREFIX = "Soundboard::";
	print(PREFIX .. s);
	return;
end

do
	local LIP = require 'LIP';
	
	local VERSION = "0.4";
	local CONFIG_FILE = "config.ini";

	logger("Initializing options");
	local options = LIP.load(CONFIG_FILE);
	logger("Options initialized");
	logger("Initializing soundlist");

	local soundlists = {};
	-- Parsing filenames from the option string
	for i in string.gmatch(options.general.SOUNDLISTS, "%S+") do
		table.insert(soundlists, i);
	end

	local soundlist = {};
	-- Merge all soundlist files to 'soundlist'
	for i, j in pairs(soundlists) do
		logger("Loading soundlist " .. j);
		tmp = LIP.load(j);
		-- Loop through all sections in the current soundlist
		for l,m in pairs(tmp) do
			soundlist[l] = soundlist[l] or {};
			-- Loop through all key-value -pairs on the current section
			for o, p in pairs(tmp[l]) do soundlist[l][o] = p; end
		end
	end

	logger("Soundlist initialized");

	piepan.On("connect", function()
		logger("Connected");
	end)

	piepan.On("message", function(e)

		if e.Sender == nil then
			return
		end

		-- Todo:: make namespaces actually functional
		local s = string.match(e.Message, "!(%w+)")

		-- Look for sound by the name of s
		-- found will have all found soundfile names
		local found = {};
		for section, keys in pairs(soundlist) do
			if keys[s] ~= nil then
				table.insert(found, keys[s]);
			end
		end
		piepan.Audio.New({
			filename = "sounds/" .. found[1];
		}):Play();
	end)
end
