
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <geoip>

#define PLUGIN_VERSION "1.0.0"

ConVar g_ShowIP = null;

public Plugin myinfo =
{
	name		= "Player connections",
	author		= "abnerfs",
	description = "Shows a message everytime someone joins or leaves the server",
	version		= PLUGIN_VERSION,
	url			= "https://github.com/abnerfs"
};

public OnPluginStart()
{
	HookEvent("player_disconnect", Disconnect, EventHookMode_Pre);
	AutoExecConfig(true, "abner_player_connections");
	LoadTranslations("abner_player_connections.phrases");

	g_ShowIP = CreateConVar("abner_player_connections_show_ip", "0", "Whether it should show ip on connection or not");
}

public OnClientPostAdminCheck(client)
{
	CreateTimer(1.0, AnnounceTimer, client);
}

public Action Disconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || IsFakeClient(client))
		return Plugin_Continue;

	char steamId[64];
	char szIp[64];
	char country[50];
	char reason[255];

	GetClientIP(client, szIp, sizeof(szIp), true);
	if (!GeoipCountryEx(szIp, country, sizeof(country), client))
	{
		Format(country, sizeof(country), "%t", "unknown");
	}
	GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));
	GetEventString(event, "reason", reason, sizeof(reason));

	CPrintToChatAll("%t%t", "prefix", "disconnect", client, steamId, reason, country);
	return Plugin_Continue;
}

public Action AnnounceTimer(Event timer, any client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return Plugin_Continue;

	char steamId[64];
	char szIp[64];
	char country[50];

	GetClientIP(client, szIp, sizeof(szIp), true);
	if (!GeoipCountryEx(szIp, country, sizeof(country), client))
	{
		Format(country, sizeof(country), "%t", "unknown");
	}
	GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));

	CPrintToChatAll("%t%t", "prefix", "join_name", client);
	CPrintToChatAll("%t%t", "prefix", "join_steam", steamId);
	if (GetConVarBool(g_ShowIP))
		CPrintToChatAll("%t%t", "prefix", "join_ip", szIp);
	CPrintToChatAll("%t%t", "prefix", "join_country", country);
	return Plugin_Continue;
}

stock bool IsValidClient(client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
	if (!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}
