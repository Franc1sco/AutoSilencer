#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

new Handle:cookie = INVALID_HANDLE;
new bool:option_cookie[MAXPLAYERS + 1] = {true,...};

new bool:primera[2048] = false;

public Plugin:myinfo =
{
	name = "SM Autosilencer",
	author = "Franc1sco franug",
	description = "oh yeah",
	version = "1.1",
	url = "http://www.clanuea.com"
};

public OnPluginStart()
{
	for(new i = 1; i < MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
	
	cookie = RegClientCookie("Autosilencer On/Off", "", CookieAccess_Private);
	new info;
	SetCookieMenuItem(CookieMenuHandler, any:info, "Autosilencer");
	CreateConVar("sm_autosilencer_version", "1.1", "ok", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);
	
}

public OnEntityCreated(entity, const String:classname[])
{
	
	if(StrContains(classname, "weapon_") == 0) 
	{
		primera[entity] = false;
	}
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_WeaponEquip, Hook_OnWeaponEquip);
}

public Action:Hook_OnWeaponEquip(client, weapon)
{
	if(primera[weapon]) return;
	else primera[weapon] = true;
	
	if(!option_cookie[client]) return;
	
	decl String:item[20]; item[0] = '\0';
	GetEdictClassname(weapon, item, sizeof(item));

	if ((StrEqual(item, "weapon_m4a1") || StrEqual(item, "weapon_usp"))){
		SetEntProp(weapon, Prop_Send, "m_bSilencerOn", 1);
		SetEntProp(weapon, Prop_Send, "m_weaponMode", 1);
	}
}


// Pref

public CookieMenuHandler(client, CookieMenuAction:action, any:info, String:buffer[], maxlen)
{
	if (action == CookieMenuAction_DisplayOption)
	{
		decl String:status[10];
		if (option_cookie[client])
		{
			Format(status, sizeof(status), "Enabled");
		}
		else
		{
			Format(status, sizeof(status), "Disabled");
		}
		
		Format(buffer, maxlen, "Autosilencer: %s", status);
	}
	// CookieMenuAction_SelectOption
	else
	{
		option_cookie[client] = !option_cookie[client];
		
		if (option_cookie[client])
		{
			SetClientCookie(client, cookie, "On");
			PrintToChat(client, "\x04Autosilencer enabled");
		}
		else
		{
			SetClientCookie(client, cookie, "Off");
			PrintToChat(client, "\x04Autosilencer disabled");

		}
		
		ShowCookieMenu(client);
	}
}

public OnClientCookiesCached(client)
{
	option_cookie[client] = GetCookie(client);
}

bool:GetCookie(client)
{
	decl String:buffer[10];
	GetClientCookie(client, cookie, buffer, sizeof(buffer));
	
	return !StrEqual(buffer, "Off");
}