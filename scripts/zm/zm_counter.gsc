#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
init()
{
	level thread setupFeatures();
}
setupFeatures()
{
	level thread drawZombiesCounter();
}
drawZombiesCounter()
{
	zombiesCounter = createServerFontString("objective", 1.4);
	zombiesCounter setPoint("BOTTOM RIGHT", "BOTTOM RIGHT", 0, 0, 0.5);
	zombiesCounter.label = &"^2Zombies: ^6";
	zombiesCounter.x = zombiesCounter.x - 50;
	zombiesCounter.hideWhenInMenu = 1;
	zombiesCounter.archived = 0;
	if (getDvar("ui_zm_mapstartlocation") == "tomb")
	{
		zombiesCounter.y = zombiesCounter.y - 20;
	}
	zombiesCounter.y = zombiesCounter.y - 50;
	zombiesCounter setValue(0);
	flag_wait("initial_blackscreen_passed");
	oldZombiesCount = 0;
	while (1)
	{
		enemies = get_round_enemy_array().size + level.zombie_total;
		if (enemies > 0)
		{
			if (oldZombiesCount != enemies)
			{
				oldZombiesCount = enemies;
				zombiesCounter setValue(enemies);
			}
		}
		else
		{
			zombiesCounter setValue(0);
			zombiesCounter affectElement("alpha", 0.2, 0);
			wait 0.2;
			zombiesCounter affectElement("alpha", 0.5, 1);
			while (get_current_zombie_count() == 0)
			{
				wait 0.05;
			}
			zombiesCounter affectElement("alpha", 0.2, 0);
			wait 0.2;
			zombiesCounter setValue(enemies);
			zombiesCounter affectElement("alpha", 0.5, 1);
		}
		wait 0.5;
	}
}
affectElement(type, time, value)
{
	if (type == "x" || type == "y")
	{
		self moveOverTime(time);
	}
	else
	{
		self fadeOverTime(time);
	}
	if (type == "x")
	{
		self.x = value;
	}
	if (type == "y")
	{
		self.y = value;
	}
	if (type == "alpha")
	{
		self.alpha = value;
	}
	if (type == "color")
	{
		self.color = value;
	}
}