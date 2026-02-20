init()
{
    level thread onPlayerConnect();
}
onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSay();
    }
}
onPlayerSay()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("say", message);
        if (message[0] == "!")
        {
            args = strTok(message, " ");
            command = toLower(args[0]);
            if (command == "!suggest" || command == "!s" || command == "!suggestion")
            {
                if (!isDefined(args[1]))
                {
                    self sendClientMessage("Usage: !suggest <your suggestion>");
                    continue;
                }
                suggestion = "";
                for (i = 1; i < args.size; i++)
                {
                    suggestion += args[i] + " ";
                }
                self thread sendWebhook(suggestion);
                self sendClientMessage("Suggestion sent! Thank you.");
            }
        }
    }
}
sendWebhook(suggestion)
{
    if(!isDefined(self)) return;
    serverName = getDvar("sv_hostname");
    avatar = "https://nfld99.com/Bo2/mp.png";
    if (isSubStr(toLower(getDvar("g_gametype")), "zm") || isSubStr(toLower(getDvar("ui_gametype")), "zm"))
    {
        avatar = "https://nfld99.com/Bo2/zm.png";
    }
    headers = [];
    headers["Content-Type"] = "application/json";
    embed = [];
    embed["title"] = serverName + " Suggestion";
    embed["description"] = suggestion;
    embed["color"] = 15158528;
    field_player = [];
    field_player["name"] = "Player";
    field_player["value"] = self.name + " (" + self getGuid() + ")";
    field_player["inline"] = true;
    embed["fields"] = [];
    embed["fields"][0] = field_player;
    data = [];
    data["embeds"] = [];
    data["embeds"][0] = embed;
    data["username"] = serverName + " Bot";
    data["avatar_url"] = avatar;
    req = httpPost("https://discord.com/api/webhooks/REDACTED/REDACTED", jsonSerialize(data, 0), headers);
    req waittill("done", result);
}
sendClientMessage(msg)
{
    if(isSubStr(toLower(getDvar("g_gametype")), "zm"))
    {
        self iprintlnbold(msg);
    }
    else
    {
        self tell(msg);
    }
}