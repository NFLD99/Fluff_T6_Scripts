#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;
init()
{
    level thread onplayerconnect();
    chat::register_command("!w", ::cmd_withdraw, true);
    chat::register_command("!d", ::cmd_deposit, true);
    chat::register_command("!b", ::cmd_balance, true);
    chat::register_command("!h", ::cmd_help, true);
}
onplayerconnect()
{
    for (;;)
    {
        level waittill("connecting", player);
        player thread onplayerspawned();
        player thread init_bank();
    }
}
onplayerspawned()
{
    level endon("game_ended");
    self endon("disconnect");
    self waittill("spawned_player");
    // self create_bank_hud();
    self tell("^6Bank System Active.");
}
create_bank_hud()
{
    if (isDefined(self.bank_hud))
    {
        self.bank_hud destroy();
    }
    self.bank_hud = newClientHudElem(self);
    self.bank_hud.alignX = "left";
    self.bank_hud.alignY = "top";
    self.bank_hud.horzAlign = "left";
    self.bank_hud.vertAlign = "top";
    self.bank_hud.x = 5;
    self.bank_hud.y = 10;
    self.bank_hud.fontScale = 1.4;
    self.bank_hud.alpha = 1;
    self.bank_hud.hidewheninmenu = 1;
    self update_bank_hud();
}
update_bank_hud()
{
    if (isDefined(self.bank_hud))
    {
        val = isDefined(self.pers["bank"]) ? self.pers["bank"] : 0;
        self.bank_hud setText("^7Bank: ^2$" + format_with_commas(val));
    }
}
init_bank()
{
    self endon("disconnect");
    path = "bank/" + self getGuid() + ".txt";
    if (!directoryExists("bank"))
    {
        createDirectory("bank");
    }
    if (!fileExists(path))
    {
        writeFile(path, "0");
    }
    self.pers["bank"] = int(readFile(path));
}
cmd_withdraw(args)
{
    score_limit = 1000000;
    bank_val = int(self.pers["bank"]);
    if (self.score >= score_limit)
    {
        self tell("^6Score is already at max.");
        return;
    }
    if (!isDefined(args) || args.size < 2) return;
    amt_input = args[1];
    withdraw_amt = (amt_input == "all") ? bank_val : int(amt_input);
    if (withdraw_amt <= 0) return;
    if (withdraw_amt > bank_val)
    {
        self tell("^6Insufficient Bank Balance.");
        return;
    }
    if ((self.score + withdraw_amt) > score_limit)
    {
        withdraw_amt = score_limit - self.score;
    }
    self.pers["bank"] -= withdraw_amt;
    self.score += withdraw_amt;
    self tell("^6Withdrew: ^2" + format_with_commas(withdraw_amt));
    self update_file(self.pers["bank"]);
    // self update_bank_hud();
}
cmd_deposit(args)
{
    bank_val = int(self.pers["bank"]);
    if (!isDefined(args) || args.size < 2) return;
    amt_input = args[1];
    deposit_amt = (amt_input == "all") ? self.score : int(amt_input);
    if (deposit_amt <= 0 || self.score < deposit_amt)
    {
        self tell("^6Not enough points.");
        return;
    }
    self.pers["bank"] += deposit_amt;
    self.score -= deposit_amt;
    self tell("^6Deposited: ^2" + format_with_commas(deposit_amt));
    self update_file(self.pers["bank"]);
    // self update_bank_hud();
}
cmd_balance(args)
{
    self tell("^6Balance: ^2" + format_with_commas(self.pers["bank"]));
}
cmd_help(args)
{
    self tell("^2!w <amt> ^6| ^2!d <amt> ^6| ^2!b");
}
update_file(val)
{
    path = "bank/" + self getGuid() + ".txt";
    // We save as a raw string of numbers for the reader to parse
    writeFile(path, raw_int_to_string(val));
}
format_with_commas(n)
{
    n = int(n);
    if (n == 0) return "0";
    digits = "0123456789";
    res = "";
    count = 0;
    while (n > 0)
    {
        if (count > 0 && count % 3 == 0)
        {
            res = "," + res;
        }
        d = n % 10;
        res = getSubStr(digits, d, d + 1) + res;
        n = int(n / 10);
        count++;
    }
    return res;
}
raw_int_to_string(n)
{
    n = int(n);
    if (n == 0) return "0";
    digits = "0123456789";
    res = "";
    while (n > 0)
    {
        d = n % 10;
        res = getSubStr(digits, d, d + 1) + res;
        n = int(n / 10);
    }
    return res;
}