/**
 * @author Patrick Pézier - http://patrick.pezier.com
 * Composant ColdFusion communiquant avec l'API YouTube Data
 */
component
	accessors="true"
	output="false"
	{

		/* encodage */
		pageencoding "utf-8";

		/* propriétés */
		property name="key"			type="string"; // API key fournie par YouTube
		property name="accessToken"	type="string"; // API key fournie par YouTube

		/* constantes */
		this.API_URL = "https://www.googleapis.com/youtube/v3"; // url racine de l'API


		/**
		 * constructeur
		 */
		public youtube function init( string key="", string access_token="" ){
			this.setKey(arguments.key);
			this.setAccessToken(arguments.access_token);
			return(this);
		}


		/**
		 * Appelle l'API
		 * @endPoint.hint	endpoint demandé
		 * @params.hint		struct de paramètres
		 * @method.hint		méthode (seule GET est implémentée)
		 */
		public any function callAPI( string endPoint="", struct params={}, string method="GET" ){

			/* préparation de l'appel à l'API YouTube Data */
			var httpService = new http( method="#arguments.method#" );
			httpService.setUrl(this.API_URL & endpoint);

			/**
			 * définition d'une struct pour les headers et les paramètres
			 * et gestion de l'authentification par access_token ou key
			 */
			headers = {};
			if (len(this.getAccessToken()))
				structInsert(headers, "Authorization", "Bearer "&this.getAccessToken()); // authentification par access_token
			else if (len(this.getKey()))
				structInsert(arguments.params, "key", this.getKey()); // authentification par key
			for (structkey in headers)
				httpService.addParam(type="HEADER", name="#structkey#", value="#structFind(headers,structkey)#");

			/* ajout des paramètres en fonction de la méthode */
			switch(uCase(method)){

				case "GET":
					for (structkey in arguments.params)
						httpService.addParam(type="URL", name="#structkey#", value="#structFind(arguments.params,structkey)#");
				break;

				case "POST": case "DELETE": case "LIST": case "PUT":
				break;

				default:
					return( "Erreur : Méthode non prise en charge par l'API." );
				break;

			} // fin switch

			/* appel de l'API */
			var result = httpService.send().getPrefix();

			/**
			 * traitement du contenu renvoyé
			 *	200 = OK		= Requête traitée avec succès
			 */
			if (val(result.statusCode) eq 200) {
				if (isJSON(result.fileContent))
					/* retour de type Json */
					return( deserializeJSON(result.fileContent) );
				else if (isXML(result.fileContent))
					/* retour de type XML */
					return( xmlParse(result.fileContent) );
				else
					return( result );
			} else { // erreur
				WriteDump(result);
				return( "Erreur : " & result.statusCode );
			} // fin if

		} // fin function callAPI


		/**
		 * Liste toutes les playlists d'un channel
		 * @params.hint		struct de paramètres
		 */
		public any function playlistsListByChannelId( struct params={} ){

			param name="arguments.params.part"			type="string"	default="snippet,contentDetails";
			param name="arguments.params.maxResults"	type="integer"	default="25";

			var result = this.callAPI("/playlists", arguments.params);

			if ( isStruct(result) and structKeyExists(result,"kind") and not compare(result.kind,"youtube##playlistListResponse") )
				return( result );
			else
				return( structNew() );

		} // fin function playlistsListByChannelId


		/**
		 * Liste tous les items d'une playlist
		 * @params.hint		struct de paramètres
		 */
		public any function playlistItemsListByPlaylistId( struct params={} ){

			param name="arguments.params.part"			type="string"	default="snippet,contentDetails";
			param name="arguments.params.maxResults"	type="integer"	default="25";

			var result = this.callAPI("/playlistItems", arguments.params);

			if ( isStruct(result) and structKeyExists(result,"kind") and not compare(result.kind,"youtube##playlistItemListResponse") )
				return( result );
			else
				return( structNew() );

		} // fin function playlistsListByChannelId


	}
