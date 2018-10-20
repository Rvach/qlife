float(entity bloke) backshot = 
{
	local float result;
	local vector veca;
	local vector vecb;
	if (bloke.classname == "player")
	{
		makevectors(bloke.v_angle);
	}
	else
	{
		makevectors(bloke.angles);
	}
	veca = v_right;
	if (self.classname == "player")
	{
		makevectors(self.v_angle);
	}
	else
	{
		makevectors(self.angles);
	}
	vecb = v_forward;
	result = veca_x * vecb_y - vecb_x * veca_y;
	if (result > WM_UNINIT)
	{
		return 1;
	}
};

float(entity poorguy, vector org) HitLocation = 
{
	local vector f;
	local vector g;
	local vector h;
	local float x;
	local float zdif;
	local float pain;
	if (poorguy.classname != "monster_fish" && poorguy.classname != "monster_demon1" && poorguy.classname != "monster_shalrath" && poorguy.classname != "monster_tarbaby" && poorguy.classname != "monster_oldone" && poorguy.classname != "monster_dog" && (poorguy.flags & FL_MONSTER || poorguy.classname == "player" || (poorguy.flags & FL_CLIENT) || poorguy.classname == "monster_zombie"))
	{
		g = org;
		g_z = WM_UNINIT;
		h = poorguy.origin;
		h_z = WM_UNINIT;
		x = vlen(g - h);
		f = normalize(f) * x + org;
		zdif = f_z - poorguy.origin_z;
		if (zdif < WM_UNINIT && poorguy.classname == "player")
		{
			sprint(find(world, classname, "player"), "Leg shot!\n");
			pain = 0.25;
		}
		if (zdif < TE_LAVASPLASH && poorguy.classname != "player")
		{
			sprint(find(world, classname, "player"), "Leg shot!\n");
			pain = 0.25;
		}
		else
		{
			if (zdif > 20 && poorguy.classname == "player")
			{
				sprint(find(world, classname, "player"), "Head shot!\n");
				pain = MENU_WAYPOINTS;
			}
			else
			{
				if (zdif > SVC_INTERMISSION && poorguy.classname != "player")
				{
					sprint(find(world, classname, "player"), "Head shot!\n");
					pain = MENU_WAYPOINTS;
				}
			}
		}
	}
	if (!pain)
	{
		sprint(find(world, classname, "player"), "Chest shot!\n");
	}
	pain = MENU_MAIN;
	if (backshot(poorguy))
	{
		sprint(find(world, classname, "player"), "From back!\n");
	}
	pain = pain * 1.5;
	return pain;
};

