#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;
#include scripts\chat_commands;
Init()
{
    level thread onplayerconnect();
    CreateCommand(level.chat_commands["ports"], "w", "function", ::cmd_withdraw, 1);
    CreateCommand(level.chat_commands["ports"], "d", "function", ::cmd_deposit, 1);
    CreateCommand(level.chat_commands["ports"], "b", "function", ::cmd_balance, 1);
    CreateCommand(level.chat_commands["ports"], "h", "function", ::cmd_help, 1);
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
    self iPrintlnBold("^6Bank System Active.");
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
        self iPrintlnBold("^6Score is already at max.");
        return;
    }
    if (!isDefined(args) || args.size < 2) 
    {
        self iPrintlnBold("^1Usage: !w <amount/all>");
        return;
    }
    amt_input = args[1];
    withdraw_amt = (amt_input == "all") ? bank_val : int(amt_input);
    if (withdraw_amt <= 0) return;
    if (withdraw_amt > bank_val)
    {
        self iPrintlnBold("^6Insufficient Bank Balance.");
        return;
    }
    if ((self.score + withdraw_amt) > score_limit)
    {
        withdraw_amt = score_limit - self.score;
    }
    self.pers["bank"] -= withdraw_amt;
    self.score += withdraw_amt;
    self iPrintlnBold("^6Withdrew: ^2" + format_with_commas(withdraw_amt));
    self update_file(self.pers["bank"]);
}
cmd_deposit(args)
{
    bank_val = int(self.pers["bank"]);
    if (!isDefined(args) || args.size < 2)
    {
        self iPrintlnBold("^1Usage: !d <amount/all>");
        return;
    }
    amt_input = args[1];
    deposit_amt = (amt_input == "all") ? self.score : int(amt_input);
    if (deposit_amt <= 0 || self.score < deposit_amt)
    {
        self iPrintlnBold("^6Not enough points.");
        return;
    }
    self.pers["bank"] += deposit_amt;
    self.score -= deposit_amt;
    self iPrintlnBold("^6Deposited: ^2" + format_with_commas(deposit_amt));
    self update_file(self.pers["bank"]);
}
cmd_balance(args)
{
    self iPrintlnBold("^6Balance: ^2" + format_with_commas(self.pers["bank"]));
}
cmd_help(args)
{
    self iPrintlnBold("^2!w <amt> ^6| ^2!d <amt> ^6| ^2!b");
}
update_file(val)
{
    path = "bank/" + self getGuid() + ".txt";
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