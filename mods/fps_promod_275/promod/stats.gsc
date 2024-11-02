startServerRecord( player )
{
    ent = player getentitynumber();
    name = generateRandomString(10);
    if( !(player isServerRecordingDemo()) )
        exec( "record " + ent + " " + name);
}

stopServerRecord()
{
    exec( "stoprecord all" );
}

generateRandomString(length)
{    
    list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    string = "";

    for (i = 0; i < length; i++)
    {
        random_int = randomintrange(0, list.size);
        string += list[random_int];
    }

    return string;
}

cancelMatch( ids )
{
    playerIds = createString( ids );

    httppostjson("https://codtv.eu/api/promod/stats/match/cancel", 
        level.fps_match_id + ";" + 
        playerIds
        , ::dataCallback
    );

    //exec("kick all " + "^1Match has been canceled.");
    iprintln("^1Match has been cancelled.");
    
}

dmFinished( player )
{
    if( isDefined( player ))
        iprintln( player.name );
}

updateGunX( player, value )
{
    httppostjson("https://codtv.eu/api/promod/settings/player/gunx", 
        player getSteamId64() + ";" + 
        toLower( getDvar( "fs_game" ) ) + ";" + 
        value
        , ::dataCallback
    );
}

updateFovScale( player, value )
{
        httppostjson("https://codtv.eu/api/promod/settings/player/fov", 
        player getSteamId64() + ";" + 
        toLower( getDvar( "fs_game" ) ) + ";" + 
        value
        , ::dataCallback
    );
}

createString( array )
{
    // Initialize an empty string
    result = "";

    // Iterate over the array elements
    for ( i = 0; i < array.size; i++ )
    {
        // Append the value, add a comma only if it's not the first element
        if ( i > 0 )
        {
            result += ";";
        }
        result += array[i];
    }

    return result;
}

mapStarted()
{
    match_id = level.fps_match_id;
    map_name = level.script;	
    type = getDvar("fps_comp_type");
    mr = game["MR"];
    server_ip = toLower( getDvar( "net_ip" ) );
    server_port = toLower( getDvar( "net_port" ) );
    server_hostname = toLower( getDvar( "sv_hostname" ) );
    server_rcon = toLower( getDvar( "rcon_password" ) );
    server_password = toLower( getDvar( "g_password" ) );
    server_mode = toLower( getDvar( "fs_game" ) );
    server_verified = 0;
    promod_mode = toLower( getDvar( "promod_mode" ) );
    sv_fps = toLower( getDvar( "sv_fps" ) );
    sv_pure = toLower( getDvar( "sv_pure" ) );
    g_antilag = toLower( getDvar( "g_antilag" ) );
    g_gravity = toLower( getDvar( "g_gravity" ) );
    g_friendlyPlayerCanBlock = toLower( getDvar( "g_friendlyPlayerCanBlock" ) );
    g_FFAPlayerCanBlock = toLower( getDvar( "g_FFAPlayerCanBlock" ) );

    allies_name = "-";
    allies_tag = "-";
    axis_name = "-";
    axis_tag = "-";

    allies_id = findTeamId("allies");
    allies_name = findTeamName( allies_id );
    allies_tag = findTeamTag( allies_id );

    axis_id = findTeamId("axis");
    axis_name = findTeamName( axis_id );
    axis_tag = findTeamTag( axis_id );

    httppostjson("https://codtv.eu/api/promod/stats/map/start", 
         match_id + ";" + 
         map_name + ";" + 
         type + ";" + 
         mr + ";" + 
         server_verified + ";" +
         server_ip + ";" +
         server_port + ";" +
         server_hostname + ";" +
         server_rcon + ";" +
         server_password + ";" +
         server_mode + ";" +
         promod_mode + ";" +    
         sv_fps + ";" + 
         sv_pure + ";" +      
         g_antilag + ";" + 
         g_gravity + ";" + 
         g_friendlyPlayerCanBlock + ";" + 
         g_FFAPlayerCanBlock + ";" + 
         allies_id + ";" + 
         allies_name + ";" +
         allies_tag + ";" +
         axis_id + ";" + 
         axis_name + ";" +
         axis_tag
        , ::gameStartedCallback
	);
}

clipReport( player, round, clipTime )
{
    if ( isDefined( timeUntilRoundEnd() ) )
		timeInRound = ( timeUntilRoundEnd() - level.postRoundTime );
	else 
		timeInRound = 0;

    if (timeInRound != 0)
    {
        httppostjson("https://codtv.eu/api/promod/stats/map/player/clip", 
            level.fps_match_id + ";" + 
            level.script + ";" +
            player.pers["username"] + ";" +
            player getSteamId64() + ";" +
            round + ";" + 
            timeInRound + ";" +
            clipTime + ";" +
            player.origin
            , ::dataCallback
        );
    }        
}

bombReport( player, label, type, round )
{
    if ( isDefined( timeUntilRoundEnd() ) )
		time = ( timeUntilRoundEnd() - level.postRoundTime );
	else 
		time = 0;

    httppostjson("https://codtv.eu/api/promod/stats/map/bomb", 
        level.fps_match_id + ";" + 
        level.script + ";" +
        player.pers["username"] + ";" +
        player getSteamId64() + ";" +
        label + ";" +
        type + ";" +
        time + ";" +
        round
        , ::gameStartedCallback
	);
}

//thread promod\stats::scoreReport( game["totalroundsplayed"]+1, game["teamScores"]["allies"], game["teamScores"]["axis"], winner, endReasonText );
roundReport( round, allies_score, axis_score, reason, winner, knife_round, ot_active, ot_count )
{
        httppostjson("https://codtv.eu/api/promod/stats/map/round", 
        level.fps_match_id + ";" + 
        level.script + ";" + 
        round + ";" + 
        allies_score + ";" + 
        axis_score + ";" + 
        reason + ";" +
        winner + ";" +
        knife_round + ";" +
        ot_active + ";" +
        ot_count
        , ::dataCallback
	);
}

// roundReport( round, )
// {
//     httppostjson("https://cod4mm.eu/api/promod/stats/match/halftime", 
//         level.fps_match_id + ";" + 
//         level.script + ";" +

//         , ::gameStartedCallback
// 	);
// }

findTeamName( teamId, team )
{

    for(i = 0; i < level.players.size; i++) 
    {
        player = level.players[i];

        if ( isDefined( player.pers["teamId"]) && player.pers["teamId"] == teamId )
        {
            return player.pers["teamName"];
        }
    }

    return "Not available";
}

findTeamTag( teamId )
{
    for(i = 0; i < level.players.size; i++) 
    {
        player = level.players[i];

        if ( isDefined( player.pers["teamId"]) && player.pers["teamId"] == teamId )
        {
            return player.pers["teamTag"];
            //game[team+"TeamName"] = player.pers["teamName"];
        }
    }
    //game[team+"TeamName"] = "Not available";
    return "Not available";
}


halftime()
{
    httppostjson("https://codtv.eu/api/promod/stats/map/halftime", 
        level.fps_match_id + ";" + 
        level.script
        , ::gameStartedCallback
	);
}

timeUntilRoundEnd()
{
	// Check if the game has already ended
	if ( level.gameEnded )
	{
		// Calculate the time passed since the game ended
		timePassed = (getTime() - level.gameEndTime) / 1000;
		// Calculate the remaining time based on the post-round time
		timeRemaining = level.postRoundTime - timePassed;

		// If the remaining time is negative, return 0
		if ( timeRemaining < 0 )
			return 0;
		// Return the remaining time
		return timeRemaining;
	}

	// Check if in overtime, no time limit set, or start time not defined
	if ( level.inOvertime || level.timeLimit <= 0 || !isDefined( level.startTime ) )
		return undefined;

	// Calculate the time passed since the round started
	timePassed = (getTime() - level.startTime)/1000;
	// Calculate the remaining time based on the time limit and post-round time
	timeRemaining = (level.timeLimit * 60) - timePassed;

	// Return the remaining time plus the post-round time
	return timeRemaining + level.postRoundTime;
}

publicMapStarted()
{
    match_id = level.fps_match_id;
    map_name = level.script;	
    type = "public";
    mr = 0;
    allies_id = 0;
    allies_name = "";
    allies_tag = "";
    axis_id = 0;
    axis_name = "";
    axis_tag = "";

    if ( isDefined( game["alliesTeamId"] ) )
    {
        allies_id = game["alliesTeamId"];
        allies_name = findTeamName("allies");
        allies_tag = findTeamTag("allies");
    }
    if ( isDefined( game["axisTeamId"] ) )
    {
        axis_id = game["axisTeamId"];
        axis_name = findTeamName("axis");
        axis_tag = findTeamTag("axis");
    }

    httppostjson("https://codtv.eu/api/promod/stats/public/player/stats", 
         match_id + ";" + 
         map_name + ";" + 
         type + ";" + 
         mr + ";" + 
         allies_id + ";" + 
         allies_name + ";" +
         allies_tag + ";" +
         axis_id + ";" + 
         axis_name + ";" +
         axis_tag
        , ::dataCallback
	);
}

initPlayers()
{
    // Wait to sync map start info
    wait 1;

    // Debugging statement to check number of players
    //iPrintln("Number of players: " + level.players.size);

    // Iterate through each player
    for (i = 0; i < level.players.size; i++)
    {
        // Check if the player has a valid teamId
        if (isDefined(level.players[i].pers["teamId"]))
        {
            // Get player information
            match_id = level.fps_match_id;
            map_name = level.script;
            teamName = level.players[i].pers["teamName"];
            teamId = level.players[i].pers["teamId"];
            steamId = level.players[i] getSteamId64();
            playerId = level.players[i] getplayerid64();
            username = level.players[i].pers["username"];
            ip = level.players[i] getip();
            //country = level.players[i] getgeolocation(1);
            round = game["totalroundsplayed"] + 1;

            // Construct player info string
            playerInfoString = match_id + ";" + map_name + ";" + teamName + ";" + teamId + ";" + steamId + ";" + playerId + ";" + username + ";" + ip + ";" + round;

            // Debugging statement to check player info string
            //iPrintln("Sending player info: " + playerInfoString);

            // Send player info
            httppostjson("https://codtv.eu/api/promod/stats/map/player/init", 
                playerInfoString,
                ::dataCallback
            ); 
        }
        //else
        //{
            // Debugging statement for players without teamId
            //iPrintln("Player " + i + " does not have a teamId");
        //}

        wait 1; // Adjust if needed
    }
}

processKillData(attacker, victim, attacker_data, victim_data, kill_data)
{
    attacker_steam_id = 0;
    attacker_name = 0;
    attacker_team_name = 0;

    victim_steam_id = 0;
    victim_team_name = 0;
    victim_name = 0;
    
    clutchKills = 0;
    clutchSituation = 0;
    is_wallbang = 0;
    knifeRound = game["PROMOD_KNIFEROUND"];
      

    if( isPlayer( attacker ) && !attacker.isBot )
    {
        attacker_steam_id = attacker getsteamid64();
        attacker_name = attacker.pers["username"];
        attacker_team_name = attacker.pers["teamName"];
        clutchKills = attacker.clutchKills;
		clutchSituation = attacker.clutchSituation;
    }

    if( isPlayer( victim ) && !victim.isBot )
    {
        victim_steam_id = victim getsteamid64();
        victim_pid = victim getplayerid64();
        victim_ip = victim getip();
        victim_team_name = victim.pers["teamName"];
        victim_country = victim getgeolocation(1);
        victim_name = victim.pers["username"];
    }

    httppostjson("https://codtv.eu/api/promod/stats/map/player/kill",
        attacker_steam_id + ";" +
        attacker_name + ";" +
        attacker_team_name + ";" +
        attacker_data + ";" +     
        clutchSituation + ";" +
        clutchKills + ";" +        
        victim_steam_id + ";" +
        victim_name + ";" +
        victim_team_name + ";" +
        victim_data + ";" +
        kill_data + ";" + 
        knifeRound
        , ::dataCallback
    );
}

findTeamId( team )
{
    teamIdCheck = 0;
    teamTempIds = [];
    teamSize = 0;
	majorityTeamId = 0;

    for (i = 0; i < level.players.size; i++)
    {
        // Check if the player has a valid teamId
        if (isDefined(level.players[i].pers["teamId"]) && level.players[i].pers["team"] == team)
        {
            teamTempIds[teamSize] = level.players[i].pers["teamId"];
            teamSize++;
        }
    }

	// Handle 1v1 scenario
    if (teamSize == 1)
    {
        //setTeamId( teamTempIds[0], team ); // Return the teamId for the solo player
        return teamTempIds[0];
    }

    // Check if the team has players with the same teamId
    if (teamSize > 1)
    {
        bubbleSort(teamTempIds);
        majorityTeamId = findMajority(teamTempIds);

        if (countOccurrences(teamTempIds, majorityTeamId) >= teamSize / 2)
        {
            return majorityTeamId;
        }
    }

    return -1;
}

setTeamId( id, team )
{
	game[team+"TeamId"] = id;
}

setTeamName( id, team )
{
	game[team+"TeamName"] = id;
}

setTeamTag( id, team )
{
	game[team+"TeamTag"] = id;
}

// Helper function to find the majority element in an array
findMajority(arr)
{
    count = 1;
    majorityElement = arr[0];
    
    for (i = 1; i < arr.size; i++)
    {
        if (arr[i] == majorityElement)
        {
            count++;
        }
        else
        {
            count--;

            if (count == 0)
            {
                majorityElement = arr[i];
                count = 1;
            }
        }
    }

    return majorityElement;
}

// Helper function to count occurrences of an element in an array
countOccurrences(arr, element)
{
    count = 0;
    
    for (i = 0; i < arr.size; i++)
    {
        if (arr[i] == element)
        {
            count++;
        }
    }

    return count;
}

bubbleSort(arr)
{
    for (i = 0; i < arr.size - 1; i++)
    {
        for (j = 0; j < arr.size - i - 1; j++)
        {
            if (arr[j] > arr[j + 1])
            {
                // Swap arr[j] and arr[j+1]
                temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

gameStartedCallback( handle )
{
    jsonreleaseobject( handle );
}

mapFinished( winnerTeamId )
{
    // Wait for player stats to save
    wait 3;

    match_id = level.fps_match_id;
    map_name = level.script;

    string = match_id + ";" + map_name + ";" + winnerTeamId;

    httppostjson("https://codtv.eu/api/promod/stats/map/finish", 
        string
        , ::dataCallback
    ); 
}

sendPublicStatsData()
{
    steamid = self getsteamid64();
	name = self.name;
	country = self getgeolocation(1);
	score = self getPersStat( "score" );
	deaths = self getPersStat( "deaths" );
	suicides = self getPersStat( "suicides" );
	kills = self getPersStat( "kills" );
	headshots = self getPersStat( "headshots" );
	assists = self getPersStat( "assists" );
    damage_taken = self getPersStat("damage_taken");
    damage_done = self getPersStat("damage_done");
	shots = self getPersStat("shots");
	hits = self getPersStat("hits");
    plants = self getPersStat("plants");
    defuses = self getPersStat("defuses");
    ip = self getip();
	map_name = level.script;
	match_id = level.fps_match_id;

    httppostjson("https://cod4mm.eu/api/statistics/public/stats",
        steamid + ";" +
        name + ";" +
        country + ";" +
        score + ";" +
        deaths + ";" +
        suicides + ";" +
        kills + ";" +
        headshots + ";" +
        assists + ";" +
        damage_taken + ";" +
        damage_done + ";" +
        shots + ";" +
        hits + ";" +
        plants + ";" +
        defuses + ";" +
        ip + ";" +
        map_name + ";" +
        match_id
    , ::dataCallback);
}


sendStatsData()
{

	steamid = self getsteamid64();
    playerid = self getplayerid64();
	name = self getPersStat( "username" );
	country = self getgeolocation(1);
	score = self getPersStat( "score" );
	deaths = self getPersStat( "deaths" );
	suicides = self getPersStat( "suicides" );
	kills = self getPersStat( "kills" );
	headshots = self getPersStat( "headshots" );
	assists = self getPersStat( "assists" );
	teamkills = self getPersStat("teamkills");
    friendly_damage_taken = self getPersStat("friendly_damage_taken");
    friendly_damage_done = self getPersStat("friendly_damage_done");
    damage_taken = self getPersStat("damage_taken");
    damage_done = self getPersStat("damage_done");
	shots = self getPersStat("shots");
	hits = self getPersStat("hits");
    plants = self getPersStat("plants");
    defuses = self getPersStat("defuses");
    teamname = self getPersStat("teamName");
    round_report = game["totalroundsplayed"] + 1;
	ip = self getip();
    map_name = level.script;
	match_id = level.fps_match_id;

    httppostjson("https://codtv.eu/api/promod/stats/map/player/stats",
        steamid + ";" +
        playerid + ";" +
        name + ";" +
        country + ";" +
        score + ";" +
        deaths + ";" +
        suicides + ";" +
        kills + ";" +
        headshots + ";" +
        assists + ";" +
        teamkills + ";" +
        friendly_damage_taken + ";" +
        friendly_damage_done + ";" +
        damage_taken + ";" +
        damage_done + ";" +
        shots + ";" +
        hits + ";" +
        plants + ";" +
        defuses + ";" +
        teamname + ";" +
        round_report + ";" +
        ip + ";" +
        map_name + ";" +
        match_id
    , ::dataCallback);
}


dataCallback( handle )
{
	jsonreleaseobject( handle );
}

getPersStat( dataName )
{
	return self.pers[dataName];
}