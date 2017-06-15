<cfscript>

    /* récupération de la config de l'API */
    config = deserializeJson(fileRead(expandPath("./config.json")));

    /* Instantiation */
    youtube = new youtube( key=config.key );

    /* Récup des éléments de la playlist */
    playlistItems = youtube.playlistItemsListByPlaylistId( {"playlistId"="PLBCF2DAC6FFB574DE", "maxResults"="50"} );
    WriteDump(playlistItems);

</cfscript>
