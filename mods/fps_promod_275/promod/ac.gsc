main()
{
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

        if( !isDefined(player.pers["onAnticheat"] ))
        {
		    player thread monitorAC();
        }
    }
}

monitorAC()
{
	self endon("ac_online");
    self endon("disconnect");

    monitorMatchInfo();

	for(;;)
	{
        if( isDefined( self.pers["team"] ) && ( self.pers["team"] == "allies" || self.pers["team"] == "axis" ) )
        {
            getAcStatus();            
        }

        wait 5;
	}
}

monitorMatchInfo()
{
    if( getDvar("fps_comp_type") == "" || getDvar("fps_comp_name") == "" )
    {
        getMatchInfo();            
    }
}

onMatchIdChange()
{
    getMatchInfo();

    wait 1;

    for ( i = 0; i < level.players.size; i++ )
	{
        player = level.players[i];
        player.pers["onAnticheat"] = undefined;

        if( !isDefined(player.pers["onAnticheat"] ))
            player thread monitorAC();
    }
}

isOnAnticheat()
{
    if ( isDefined(self.pers["onAnticheat"]) && self.pers["onAnticheat"] )
        return true;
    else    
        return false;
}

setPlayerRank()
{
    if ( isOnAnticheat())
        self setRank(6, 0);
    else 
        self setRank(0, 1);
}

getAcStatus()
{
    httpgetjson("https://fpschallenge.eu/api/match/" + level.fps_match_id + "/users", ::callback, self);
    wait 1;
}

getMatchInfo()
{
    httpgetjson("https://fpschallenge.eu/api/v1/match/" + level.fps_match_id + "/info", ::matchInfoCallback);
    wait 1;
}

matchInfoCallback(handle)
{
    if( handle == 0 )
        iprintln("Error getting match info");   
    else
    {
        name = jsongetstring(handle, "competitionName");
        type = jsongetstring(handle, "competitionType");
        size = jsongetint(handle, "playerBaseCount");

        if( isDefined(name) && isDefined(type))
        {
            iprintln(type + " - " + name);
            setDvar("fps_comp_type", type);
            setDvar("fps_comp_name", name);
            setDvar("fps_comp_size", size * 2);
        }
    }
    
    jsonreleaseobject(handle);
}

callback(handle)
{
    if( handle == 0 )
        self iprintln("Error getting anticheat status");   
    else
    {
        steamid = self getsteamid64();
        path = steamid + ".anticheatRunning";
        teamid = steamid + ".teamId";
        userid = steamid + ".userId";
        teamname = steamid + ".teamName";
        teamtag = steamid + ".teamTag";
        username = steamid + ".username"; 

        anticheatRunning = jsongetint(handle, path);

        if( isDefined(anticheatRunning) && isDefined(self))
        {
            if( anticheatRunning == 1 )
            {
                self notify("ac_online");
                self.pers["onAnticheat"] = true;
                self.pers["teamId"] = jsongetint(handle, teamid); 
                self.pers["userId"] = jsongetint(handle, userid); 
                self.pers["teamName"] = jsongetstring(handle, teamname); 
                self.pers["teamTag"] = jsongetstring(handle, teamtag);
                self.pers["username"] = jsongetstring(handle, username);
                self setRank(6, 0);

                // solo-queue; ladder; tournament
                //if( isDefined( level.fps_match_type ) && level.fps_match_type != "undefined" )
                if ( getDvar("fps_comp_type") == "solo-queue" )
                {
                    self.name = self.pers["username"];
                }
                //else //if ( level.fps_match_type == "ladder" || level.fps_match_type == "tournament" )
                else
                {
                    self.name = self.pers["teamTag"] + " " + self.pers["username"];
                    //iprintln(level.fps_comp_type);
                }
                //self.name = self.pers["teamTag"] + " " + self.pers["username"];
                
                self iprintln("Anticheat status online - " + self.pers["username"]);
            }
            else 
            {
                if( !isDefined(self.pers["ac_checks_attempts"] ))
                {
                    self.pers["ac_checks_attempts"] = 1;
                    self iprintln("Anticheat status offline - " + self.name);
                }
                else if( self.pers["ac_checks_attempts"] <= 2 )
                {
                    self.pers["ac_checks_attempts"]++;
                    self iprintln("Anticheat status offline - " + self.name);
                }
                else 
                {
                    exec("kick " + self getEntityNumber() + " " + self.name + " is not allowed to play in this match, ID: ^3" + level.fps_match_id +"^7. Make sure you have proper SteamID64 set on your ^5fpschallenge^7.^5eu^7 profile page and that you are running ^5FPS ^7Anticheat.");
                }
            }
        }else {
            exec("kick " + self getEntityNumber() + " " + self.name + " is not allowed to play in this match, ID: ^3" + level.fps_match_id +"^7. Make sure you have proper SteamID64 set on your ^5fpschallenge^7.^5eu^7 profile page and that you are running ^5FPS ^7Anticheat.");
        }
    }
    
    jsonreleaseobject(handle);
}




