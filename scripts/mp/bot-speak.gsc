init()
{
level thread watchgameend();
}
watchgameend()
{
level waittill("game_ended");
wait 0.5;
bots = get_bot_array();
foreach(bot in bots)
{
if(randomint(1) < 3)
{
bot thread bot_speak_unique_quote();
wait randomfloatrange(1.5,2.0);
}
}
}
bot_speak_unique_quote()
{
name = self.name;
winQuotes = [];
lossQuotes = [];
won = isdefined(level.winningTeam) && self.team == level.winningTeam;
switch(name)
{
case "Blunt_Bunny": winQuotes = array("Rolled that lobby smooth, GG fluffy blaze bunny","Clean hops and green tops, GG weed whiskers","Packed the round tight, GG puff tail"); lossQuotes = array("Bowl went cold but fluff stays, GG haze bunny","Ashes this round, still soft fur, GG","Lost the spark but kept the fluff, GG"); break;
case "Buds-Bunny": winQuotes = array("Best buds bloom on top, GG fluff nug","Sticky plays paid off, GG bud bunny","Fresh harvest victory, GG green fluff");                    lossQuotes = array("Wilted this match, still fluffy, GG bud","Bad crop round, GG soft hopper","No bloom today, GG leaf tail"); break;
case "Chronic-Cottontail": winQuotes = array("Chronic pressure worked, GG smoke fluff","Long burn victory, GG haze tail","Lit from start to burrow, GG");                      lossQuotes = array("Burned out early, GG dusty fluff","Smoke faded fast, GG soft tail","Chronic nap round, GG"); break;
case "Dank-Hare_420": winQuotes = array("Dank hops secured it, GG 420 fluff","High score high fur, GG blaze bunny","Cloud nine finish, GG");                                   lossQuotes = array("Low stash round, GG fluff","No dank luck, GG haze hop","Dry hit match, GG"); break;
case "Grass-Rabbit": winQuotes = array("Touched grass and grew, GG green fluff","Field was loud and leafy, GG","Grass buff carried, GG smoke tail");                           lossQuotes = array("Grass too tall today, GG fluff","Weeds got me, GG soft hop","Lost in the field, GG"); break;
case "Herb_Hopper": winQuotes = array("Herb powered victory hops, GG","Seasoned and smoky, GG fluff","Spiced with green wins, GG");                                            lossQuotes = array("Herb ran out, GG fluffy","No seasoning today, GG","Mild batch round, GG"); break;
case "Hoppy-Potter": winQuotes = array("Magic herb mix worked, GG fluff spell","Potion of smoke hit, GG","Wizard weed wins, GG");                                              lossQuotes = array("Potion fizzled, GG fluff","Spellbook soggy, GG","Magic smoke missed, GG"); break;
case "Mary-Jane-Hare": winQuotes = array("Mary Jane boost active, GG fluff","Sweet leaf sweep, GG","Hare stayed hazy and happy, GG");                                          lossQuotes = array("Leaf fell early, GG fluff","No green queen today, GG","Hazy but defeated, GG"); break;
case "Weed_Whisker": winQuotes = array("Whiskers smelled loud victory, GG","Sniffed the stash win, GG fluff","Tracked with smoke trail, GG");                                  lossQuotes = array("Nose full of defeat, GG fluff","Bad scent round, GG","Trail went cold, GG"); break;
case "Xx_420-Hop_xX": winQuotes = array("420 hop tech wins, GG","Sky high and smoky, GG fluff","Blazed every jump, GG");                                                       lossQuotes = array("Hop tech offline, GG fluff","Grounded and dry, GG","Low cloud loss, GG"); break;
case "Xx_Baked-Bun_xX": winQuotes = array("Baked bun crispy win, GG","Golden toasted hops, GG fluff","Hot tray victory, GG");                                                  lossQuotes = array("Undercooked round, GG fluff","Burned edges only, GG","Half baked match, GG"); break;
case "Xx_Bunny-Hop_xX": winQuotes = array("Hop spam harvest, GG fluff","Carrot and cannabis carry, GG","Bounce and blaze win, GG");                                            lossQuotes = array("Missed hops today, GG fluff","Tripped on leaves, GG","Slow bounce loss, GG"); break;
case "Xx_Cloud-Hop_xX": winQuotes = array("Hotbox clouds cleared, GG fluff","Foggy and flawless win, GG","Sky stash secured, GG");                                             lossQuotes = array("Cloud too thick, GG fluff","Lost in the smoke, GG","Stormy hop loss, GG"); break;
case "Xx_H1gh-Hare_xX": winQuotes = array("High hare higher than ever, GG","Altitude and attitude win, GG fluff","Elevated smoke score, GG");                                  lossQuotes = array("Came down hard, GG fluff","Low altitude round, GG","Grounded hare today, GG"); break;
case "Xx_N1bblez_xX": winQuotes = array("Nibble nibble big win, GG fluff","Munched that stash lobby, GG","Snack sized smoke victory, GG");                                     lossQuotes = array("No snacks left, GG fluff","Crumbs this round, GG","Empty bowl loss, GG"); break;
case "Xx_Puff-Tail_xX": winQuotes = array("Puff tail left smoke, GG","One puff wipe, GG fluff","Cloudy tail carry, GG");                                                       lossQuotes = array("Puff ran out, GG fluff","Tiny cloud round, GG","Tail lost the smoke, GG"); break;
case "Xx_Smokey-Bun_xX": winQuotes = array("Smokey bun dominated, GG fluff","Lane smoked clean, GG","Ash trail victory, GG");                                                  lossQuotes = array("Smoke blew away, GG fluff","Cold ash round, GG","No burn left, GG"); break;
case "Xx_Toasted-Tail_xX": winQuotes = array("Toasted tail roasted all, GG","Extra crispy hops, GG fluff","Golden burn win, GG");                                              lossQuotes = array("Overtoasted and done, GG fluff","Burned too soon, GG","Charred round loss, GG"); break;
default: winQuotes = array("GG fluffy squad","Green and clean GG","Smoke and hop GG");                                                                                         lossQuotes = array("GG soft landing","Fluff retreat GG","Hazy goodbye GG"); break;
}
pool = won ? winQuotes : lossQuotes;
if(pool.size > 0)
{
quote = pool[randomint(pool.size)];
self sayall(quote);
}
}
get_bot_array()
{
players = getplayers();
bots = [];
foreach(player in players)
{
if(isbot_check(player))
bots[bots.size] = player;
}
return bots;
}
isbot_check(player)
{
return isdefined(player.pers["isBot"]) && player.pers["isBot"];
}
