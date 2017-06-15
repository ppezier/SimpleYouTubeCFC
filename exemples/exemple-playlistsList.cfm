<cfscript>

    /* récupération de la config de l'API */
    config = deserializeJson(fileRead(expandPath("./config.json")));

    /* Instantiation */
    youtube = new youtube( key=config.key );

    /* Récup des playlists */
    playlists = youtube.playlistsListByChannelId( {"channelId"="UC_x5XG1OV2P6uZZ5FSM9Ttw", "maxResults"="50"} );
    WriteDump(playlists);

</cfscript>
