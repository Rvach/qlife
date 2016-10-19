// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");  // new rocket explosion
	precache_sound ("weapons/rocket1i.wav");        // spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav"); // player shotgun
	precache_sound ("weapons/ric1.wav");    // ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");    // ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");    // ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");  // super spikes
	precache_sound ("weapons/tink1.wav");   // spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav"); // grenade launcher
	precache_sound ("weapons/bounce.wav");          // grenade bounce
	precache_sound ("weapons/shotgn2.wav"); // super shotgun

    precache_sound ("misc/basekey.wav");    // Laser Trip Bomb activate sound
    precache_sound ("sounds/weapons/deploy.wav");  // Laser Trip Bomb weapon sound
    precache_model ("progs/WORLD/wrld_tripmine.mdl");         // Laser Trip Bomb model

	precache_model("progs/laser.MDL"); // Laser for gauss
	precache_sound("sounds/weapons/gauss2.wav"); // Laser for gauss
}

#define crandom() (2*(random()-0.5))

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local   vector  source;
	local   vector  org;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, 20);
		if (deathmatch > 3)
			T_Damage (trace_ent, self, self, 75, MOD_AXE);
		else
			T_Damage (trace_ent, self, self, 20, MOD_AXE);
	}
	else
	{       // hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);

		TE_gunshot(org);
	}
};


//============================================================================

/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local   entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');            
	setorigin (missile, org);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity  multi_ent;
float   multi_damage;
INTEGER multi_mod;

vector  blood_org;
float   blood_count;

vector  puff_org;
float   puff_count;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
	blood_count = 0;
	puff_count = 0;
	multi_mod = MOD_NONE;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage, multi_mod);
};

void(entity hit, float damage, INTEGER mod) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent || mod != multi_mod)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

void() Multi_Finish =
{
	if (puff_count)
		TE_gunshot(puff_org);

	if (blood_count)
		SpawnBlood(blood_org, blood_count);
};

/*
==============================================================================
BULLETS
==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir, INTEGER mod) TraceAttack =
{
	local   vector  vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		blood_count = blood_count + 1;
		blood_org = org;
		AddMultiDamage (trace_ent, damage, mod);
	}
	else
	{
		puff_count = puff_count + 1;
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread, INTEGER mod) FireBullets =
{
	local   vector direction;
	local   vector  src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir*2048, FALSE, self);
	puff_org = trace_endpos - dir*4;

	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction, mod);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM); 

	VK_smallkick(self);
	
	if (deathmatch != 4)
	{
		self.ammo_shells_real -= 1;
		W_UpdateAmmoCounts(self);
	}

	dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0', MOD_SHOTGUN);
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM); 

	VK_bigkick(self);
	
	if (deathmatch != 4)
	{
		self.ammo_shells_real -= 2;
		W_UpdateAmmoCounts(self);
	}

	dir = aim (self, 100000);
	FireBullets (14, dir, '0.14 0.08 0', MOD_SUPERSHOTGUN);
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	if (deathmatch != 4)
	{
		self.ammo_rockets_real -= 1;
		W_UpdateAmmoCounts(self);
	}
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	VK_smallkick(self);
	PRJ_FireProjectile(self, 
		"progs/missile.mdl", 
		self.origin + v_forward*8 + '0 0 16', 
		aim(self, 1000) * 1000,
		PE_EXPLOSION, 
		100+random()*20, 
		MOD_ROCKET, 
		5);
	PRJ_SetRadiusDamage(120, 160, MOD_ROCKETRADIUS);
};

/*
===============================================================================
LIGHTNING
===============================================================================
*/

void(entity from, float damage, INTEGER lmod) LightningHit =
{
	TE_lightningblood(trace_endpos);

	T_Damage (trace_ent, from, from, damage, lmod);
};

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage, INTEGER lmod) LightningDamage =
{
	local entity            e1, e2;
	local vector            f;
	
	f = p2 - p1;
	f = normalize(f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);

	if (trace_ent.takedamage)
		LightningHit (from, damage, lmod);
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
		LightningHit (from, damage, lmod);
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
		LightningHit (from, damage, lmod);
};


void() W_FireLightning =
{
	local   vector          org;
	local   float           cells;
	local   INTEGER		expmod;

	if (self.ammo_cells_real < 1)
	{
		W_WeaponSwitch (W_BestWeapon ());
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		if (deathmatch > 3)
		{
			if (random() <= 0.5)
			{
				T_Damage (self, self, self.owner, 4000, MOD_SELFWATER);
				return;
			}
		}

		cells = self.ammo_cells_real;
		self.ammo_cells_real = 0;
		W_WeaponSwitch (W_BestWeapon ());
		expmod = MOD_SHAFTWATER;
		if (self.watertype == CONTENT_SLIME)
			expmod = MOD_SHAFTSLIME;
		else if (self.watertype == CONTENT_LAVA)
			expmod = MOD_SHAFTLAVA;
		T_RadiusDamage (self, self, 35*cells, 40+35*cells, world, expmod);
		return;
	}

	if (self.lightning_sound < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.lightning_sound = time + 0.6;
	}
	VK_smallkick(self);

	if (deathmatch != 4)
	{
		self.ammo_cells_real -= 1;
		W_UpdateAmmoCounts(self);
	}

	org = self.origin + '0 0 16';
	
	traceline (org, org + v_forward*600, TRUE, self);

	TE_lightning2(self, org, trace_endpos);

	LightningDamage (self.origin, trace_endpos + v_forward*4, self, 30, MOD_SHAFT);
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local vector vel;

	if (deathmatch != 4)
	{
		self.ammo_rockets_real -= 1;
		W_UpdateAmmoCounts(self);
	}
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	if (self.v_angle_x)
		vel = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		vel = aim(self, 10000) * 600;
		vel_z = 200;
	}

	VK_smallkick(self);
	PRJ_FireProjectile(self, "progs/grenade.mdl", self.origin, vel, PE_EXPLOSIONGROUND, 0, 0, 2.5);
	PRJ_SetRadiusDamage(120, 160, MOD_GRENADE);
	PRJ_SetTouchNExplodeProjectile(); //PRJ_SetBouncyProjectile();

	if (deathmatch == 4)
	{
		self.attack_finished = time + 1.1;
		T_Damage (self, self, self.owner, 10, MOD_GRENADE);
	}
};


//=============================================================================
void(float ox) W_FireSpikes =
{
	if (self.ammo_nails_real < 1)
	{
		W_WeaponSwitch (W_BestWeapon ());
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	if (deathmatch != 4)
	{
		self.ammo_nails_real -= 1;
		W_UpdateAmmoCounts(self);
	}

	VK_smallkick(self);
	PRJ_FireProjectile(self,
		"progs/spike.mdl",
		self.origin + '0 0 16' + v_right*ox,
		aim(self, 1000) * 1000,
		PE_SPIKE,
		9,
		MOD_SPIKE,
		6);
};

void() W_FireSuperSpikes =
{
	if (self.ammo_nails_real < 2)
	{
		W_FireSpikes(0);
		return;
	}
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	if (deathmatch != 4)
	{
		self.ammo_nails_real -= 2;
		W_UpdateAmmoCounts(self);
	}

	VK_smallkick(self);
	PRJ_FireProjectile(self,
		"progs/s_spike.mdl",
		self.origin + '0 0 16',
		aim(self, 1000) * 1000,
		PE_SUPERSPIKE,
		18,
		MOD_SUPERSPIKE,
		6);
};

void() spike_touch;
void() superspike_touch;

void() LTB_Detonate_TripMine2 =
{
        self.th_pain = SUB_Null;
        self.th_die = SUB_Null;         // switched to null to avoid chain reaction when exploding (repeatedly kills itself!)
        self.owner = self.enemy;        // Return Property rights so the player gets credit

        T_RadiusDamage (self, self.owner, 200, 300, world, MOD_HLIFE); // Do some damage

        WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte (MSG_BROADCAST, TE_EXPLOSION);
        WriteCoord (MSG_BROADCAST, self.origin_x); // Standard Textbook explosion code
        WriteCoord (MSG_BROADCAST, self.origin_y);
        WriteCoord (MSG_BROADCAST, self.origin_z);

        remove (self);
};
void() LTB_Explode_TripMine =
{
        sound (self, CHAN_AUTO, "misc/basekey.wav", 1, ATTN_NORM);
        self.nextthink = time + 0.2;
        self.think = LTB_Detonate_TripMine2;      // A quick little function to play the trigger wav before detonation
};



void() LTB_Pain_TripMine =
{
                self.health = 40;       //didn't kill it.....probably a distant explosion
};



void() LTB_Arm_TripMine =

{
        local vector org;                               // Origin of the LTB
        local vector targ;                      // Target "       "
        
        makevectors(self.angles);               // Load the current looking position into v_forward
        org = self.origin + self.view_ofs;      // Set the origin;
        targ = org + v_forward * 2000;  // 2000 is the maximum distance of the bomb
        traceline(org, targ, FALSE, self);      // Traceline outward
        if (trace_fraction == 1.0)              // If hit nothing in 2000 units
        {
                LTB_Explode_TripMine(); // Explode if wall is too far away
                return;
        }
        if ((trace_ent == self.enemy) && (self.weapon == FALSE)) //Weapon indicates if the LTB is armed yet
        {                                                                          //And enemy is the owner
                self.nextthink = time + 1; // Don't Arm until player is out of the way
                self.think = LTB_Arm_TripMine;           // Wait yet another second (move it buster!)
                return;                 
        }
        if (self.weapon == FALSE)               // If not armed...
                self.weapon = TRUE; // arm....watch out!
        if ((trace_ent.velocity != '0 0 0') || (trace_ent.flags & FL_MONSTER)) // If object is moving or monster
        {// The above FL monster check was put in because some monsters could walk through
        // The beam without being detected (they don't have a velocity, they're using movetogoal())                     
                LTB_Explode_TripMine();  // Kaboom!
                return;
        }
        if (self.attack_finished < time)        // Attack_finished keeps track of when the beam should be refeshed
        {
        WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte (MSG_BROADCAST, TE_LIGHTNING1);               // Fire lightning two.
        WriteEntity (MSG_BROADCAST, self);
        WriteCoord (MSG_BROADCAST, org_x);                      //This is a lighting brodcast.
        WriteCoord (MSG_BROADCAST, org_y);
        WriteCoord (MSG_BROADCAST, org_z);
        WriteCoord (MSG_BROADCAST, trace_endpos_x);     // it happens every .2 secs
        WriteCoord (MSG_BROADCAST, trace_endpos_y);
        WriteCoord (MSG_BROADCAST, trace_endpos_z);     // but the think function occurs evey .07
        self.attack_finished = time + 0.2;                      // this allows fast reaction on the beam
        }                                                               // without crowding the network with broadcasts

        self.think = LTB_Arm_TripMine;
        self.nextthink = time + 0.07;                   // 0.07 secs before checking again
};

/*
================
W_FireLTB Laser Trip Bomb --(C) 1997 Frika C
================
*/
void() W_FireLTB =
{
        local   vector  source;         // Where the player is
        local entity    lasertrip;      // New entity for spawning

        
        makevectors (self.v_angle);     // Make a vector of the players facing angle
        source = self.origin + '0 0 16';        // Up a little
        traceline (source, source + v_forward*64, FALSE, self); // Trace a line straight out
        if (trace_fraction == 1.0)      // hit nothing
                return;
        if (trace_plane_normal_z != 0)  // Wall is not perfectly vertical
                return;                         // can't stick to floor or slope....
        if (trace_ent != world)         // hit a door, monster etc.
                return;
        self.currentammo = self.ammo_nails = self.ammo_nails - 10;      // Take away 10 nails  
        lasertrip = spawn();            // Spawn a new dynamic entity
        lasertrip.owner = world;        // If the player is the owner he can't trigger it!
        lasertrip.enemy = self;         // Keep track of the owner to give him credit though
        lasertrip.movetype = MOVETYPE_NONE;     // doesn't move
        lasertrip.solid = SOLID_BBOX;
        lasertrip.classname = "laser_trip_bomb";        // Name for it
        lasertrip.angles = vectoangles(trace_plane_normal);     // This aligns it perpendicular to the wall it struck
        lasertrip.weapon = FALSE;               // weapon is used to flag if the bomb has been armed or not

        lasertrip.takedamage = DAMAGE_YES;      // Can be destroyed
        lasertrip.health = 40;
        lasertrip.th_pain = LTB_Pain_TripMine;           // This allows other explosions trigger it's explosion
        lasertrip.th_die = LTB_Detonate_TripMine2;

        lasertrip.think = LTB_Arm_TripMine;              // Arm in one second
        lasertrip.nextthink = time + 1;
        lasertrip.attack_finished = time + 1;//Attack_finished keeps track of how long until it should re-draw the beam
        setmodel (lasertrip, "progs/WORLD/wrld_tripmine.mdl");  // set the model
        setsize (lasertrip, '0 0 0', '0 0 0');  // See below            

        setorigin (lasertrip, trace_endpos);
        sound (self, CHAN_WEAPON, "sounds/weapons/deploy.wav", 1, ATTN_NORM); // Play the deployment sound
};

/*
================
W_FireGauss
================
*/
void() W_firegauss_stage_two = 
{
	makevectors(self.v_angle - self.v_angle * trace_plane_normal * WEAPON_ROCKET * trace_plane_normal);
	traceline(self.trace_endpos_temp, self.trace_endpos_temp + v_forward * 10000000, 0, self);
	if (trace_ent.health)
	{
		//self.hit_loc = HitLocation(trace_ent, trace_endpos);
		T_Damage(trace_ent, self, self, SVC_INTERMISSION * self.hit_loc, MOD_HLIFE);
	}
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING3);
	WriteEntity(MSG_BROADCAST, trace_ent);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_x);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_y);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);
	//SpawnBlood(self.trace_endpos_temp, v_forward * CONTENT_SOLID, SVC_INTERMISSION, 1, 1);
	//SpawnBlood(trace_endpos, v_forward * CONTENT_SOLID, SVC_INTERMISSION, 1, 1);
	self.angle_1 = vectoangles(self.vec_temp - self.trace_endpos_temp);
	self.angle_2 = vectoangles(self.trace_endpos_temp - trace_endpos);
	self.endangle = self.angle_1 - self.angle_2;
	// sprint(self, "self.angle_1    ");
	// sprint(self, vtos(self.angle_1));
	// sprint(self, "\n");
	// sprint(self, "self.angle_2    ");
	// sprint(self, vtos(self.angle_2));
	// sprint(self, "\n");
	// sprint(self, "self.endangle    ");
	// sprint(self, vtos(self.endangle));
	// sprint(self, "\n");
	// sprint(self, "trace_plane_normal");
	// sprint(self, vtos(trace_plane_normal));
	// sprint(self, "\n");
	// sprint(self, "normalize angle_1 - angle_2   ");
	// sprint(self, vtos(normalize(self.angle_1 - self.angle_2)));
	// sprint(self, "\n");
};

void(float ox) W_FireGauss = 
{
	local vector vec;
	makevectors(self.v_angle);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_cells = self.ammo_cells - WEAPON_ROCKET;
	vec = self.origin + '0 0 17' + v_right * WEAPON_SPIKES + v_forward * MENU_FLAGS2;
	traceline(vec, self.origin + '0 0 17' + v_right * WEAPON_SPIKES + v_forward * 10000000, 0, self);
	if (trace_ent.health)
	{
		// self.hit_loc = HitLocation(trace_ent, trace_endpos); // Checn Headshots & other
		T_Damage(trace_ent, self, self, SVC_INTERMISSION * self.hit_loc, MOD_HLIFE);
	}
	self.vec_temp = vec;
	self.trace_endpos_temp = trace_endpos - v_forward * WEAPON_SPIKES;
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING3);
	WriteEntity(MSG_BROADCAST, trace_ent);
	WriteCoord(MSG_BROADCAST, vec_x);
	WriteCoord(MSG_BROADCAST, vec_y);
	WriteCoord(MSG_BROADCAST, vec_z);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_x);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_y);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_z);
	self.think = W_firegauss_stage_two;
	self.nextthink = time + 0.000000;
};

void(float ox) W_FireGaussSecondary = 
{
	local vector dir;
	local entity old;
	local vector vec;
	makevectors(self.v_angle);
	local vector vecSrc =   self.origin + '0 0 16' + v_forward*8;
    local vector vecDest =  self.origin + '0 0 16' + v_forward*10000000;
    float n;
	if (self.ammo_cells < WEAPON_SHOTGUN)
	{
		self.weapon = W_BestWeapon();
							self.currentammo = self.ammo_cells;
							self.weaponmodel = "progs/v_nail2.mdl";
							self.items = self.items | IT_CELLS;
		return;
	}
	self.attack_finished = time + 0.2;
	sound(self, CHAN_WEAPON, "sounds/weapons/gauss2.wav", WEAPON_SHOTGUN, ATTN_NORM);
	self.currentammo = self.ammo_cells = self.ammo_cells - WEAPON_SHOTGUN;
    // vecSrc = self.origin + '0 0 17' + v_right * WEAPON_SPIKES + v_forward * MENU_FLAGS2;
    // vecDest = self.origin + '0 0 17' + v_right * WEAPON_SPIKES + v_forward * 10000000;
    vecSrc =   self.origin + '0 0 16' + v_forward*8;
    vecDest =  self.origin + '0 0 16' + v_forward*10000000;
	
    traceline(vecSrc, vecDest, FALSE, self);
    vector trForward_endpos = trace_endpos;
    if (trace_ent.health)
	{
		// self.hit_loc = HitLocation(trace_ent, trace_endpos); // Checn Headshots & other
		T_Damage(trace_ent, self, self, self.gausscharge * 15 * self.hit_loc, MOD_HLIFE);

        // do small radius dmg on hit point -----------------------------------------------------------------------------
        local entity dmg_small_gauss_radius;
        dmg_small_gauss_radius = spawn();
        T_RadiusDamage (trace_ent, self.owner, 100, 100, world, MOD_HLIFE);
	}
	else{
        // float n = -(trace_plane_normal_x*vecSrc_x + trace_plane_normal_y*vecSrc_y + trace_plane_normal_z*vecSrc_z); // -DotProduct(tr.vecPlaneNormal, vecSrc);

        // try punching through wall if secondary attack (primary is incapable of breaking through) ---------------------
		traceline( trForward_endpos + v_forward * 50, trForward_endpos, FALSE, world);
        vector trBackward_endpos = trace_endpos;
        
        if (!trace_allsolid)
        {
            _bprint("trace_allsolid branch\n");
            float flDamage = 200;
            // trace backwards to find exit point -----------------------------------------------------------------------
            traceline( trBackward_endpos, trForward_endpos, FALSE, world);
            trBackward_endpos = trace_endpos;
            n = vlen(trBackward_endpos - trForward_endpos);

            if (n > 5 ) //n < flDamage
            {
                // if (n == 0) n = 1;
                // flDamage -= n;

                float damage_radius;
                damage_radius = flDamage * 2.5;
                
                // local entity dmg_gauss_radius;
                // dmg_gauss_radius = spawn();
                // dmg_gauss_radius.origin = trBackward_endpos + vecSrc * 8;
                //T_RadiusDamage (dmg_gauss_radius, self.owner, 200, 100, world, MOD_HLIFE); // Do some Radius damage
                PRJ_FireProjectile(self, 
                    "progs/lavaball.mdl", 
                    trBackward_endpos, 
                    aim(self, 0) * 0,
                    PE_EXPLOSION, 
                    100+random()*20, 
                    MOD_ROCKET, 
                    5);
                PRJ_SetRadiusDamage(300, 300, MOD_ROCKETRADIUS);
                
                // ::RadiusDamage( beam_tr.vecEndPos + vecSrc * 8, pev, m_pPlayer->pev, flDamage, damage_radius, CLASS_NONE, DMG_BLAST );
				//CSoundEnt::InsertSound ( bits_SOUND_COMBAT, pev->origin, NORMAL_EXPLOSION_VOLUME, 3.0 );

                // continue gauss beam from exitpoint to attack destination ---------------------------------------------
                traceline( trBackward_endpos, vecDest, FALSE, self);
                if(trace_ent.health)
                {
                    // self.hit_loc = HitLocation(trace_ent, trace_endpos); // Checn Headshots & other
                    T_Damage(trace_ent, self, self, self.gausscharge * 15 * self.hit_loc, MOD_HLIFE);
                }
            }
        }

		// VK_smallkick(self);
		// PRJ_FireProjectile(self, 
		// 	"progs/missile.mdl", 
		// 	trace_endpos + (-100.0*trace_plane_normal), 
		// 	aim(self, 0) * 0,
		// 	PE_EXPLOSION, 
		// 	100+random()*20, 
		// 	MOD_ROCKET, 
		// 	5);
		// PRJ_SetRadiusDamage(300, 300, MOD_ROCKETRADIUS);
	}
	vec = self.origin + '0 0 17' + v_right * WEAPON_SPIKES + v_forward * MENU_FLAGS2;
	self.trace_endpos_temp = trForward_endpos - v_forward * WEAPON_SPIKES;
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING1);
	WriteEntity(MSG_BROADCAST, trace_ent);
	WriteCoord(MSG_BROADCAST, vec_x);
	WriteCoord(MSG_BROADCAST, vec_y);
	WriteCoord(MSG_BROADCAST, vec_z);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_x);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_y);
	WriteCoord(MSG_BROADCAST, self.trace_endpos_temp_z);
	self.punchangle_x = CONTENT_SOLID;
	self.gaussspeed = WM_UNINIT;
	self.gausscharge = WM_UNINIT;
	self.stopgausscharge = WM_UNINIT;
	self.think = W_firegauss_stage_two;
	self.nextthink = time + GYRO_TURBULENCEMOD_AIR;
};

/*
================
W_FireGaussV2
================
*/
void(vector org, vector dir) gauss_primary = 
{
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.angles = vectoangles(dir);
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + MENU_BOTS;
	setmodel(newmis, "progs/laser.MDL");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	self.velocity = dir * -30;
	newmis.velocity = dir * 100000;
};

void(float ox) W_FireGaussV2 = 
{
	local vector dir;
	local entity old;
	makevectors(self.v_angle);
	if (self.ammo_cells < WEAPON_SHOTGUN)
	{
		self.weapon = W_BestWeapon();
							self.currentammo = self.ammo_cells;
							self.weaponmodel = "progs/v_nail2.mdl";
							self.items = self.items | IT_CELLS;
		return;
	}
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_cells = self.ammo_cells - WEAPON_SHOTGUN;
	dir = aim(self, 1000);
	gauss_primary(self.origin + '0 0 16' + v_right * WEAPON_SPIKES, dir);
};

void(vector org, vector dir) gauss_secondary = 
{
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.angles = vectoangles(dir);
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + MENU_BOTS;
	setmodel(newmis, "progs/laser.MDL");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	self.velocity = dir * self.gausscharge * -40;
	newmis.velocity = dir * 100000;
};

void(float ox) W_FireGaussV2Secondary = 
{
	local vector dir;
	local entity old;
	makevectors(self.v_angle);
	if (self.ammo_cells < WEAPON_SHOTGUN)
	{
		self.weapon = W_BestWeapon();
							self.currentammo = self.ammo_cells;
							self.weaponmodel = "progs/v_nail2.mdl";
							self.items = self.items | IT_CELLS;
		return;
	}
	self.attack_finished = time + 0.2;
	sound(self, CHAN_WEAPON, "weapons/gauss2.wav", WEAPON_SHOTGUN, ATTN_NORM);
	self.currentammo = self.ammo_cells = self.ammo_cells - WEAPON_SHOTGUN;
	dir = aim(self, 1000);
	gauss_secondary(self.origin + '0 8 16', dir);
	self.punchangle_x = CONTENT_SOLID;
	self.gaussspeed = WM_UNINIT;
	self.gausscharge = WM_UNINIT;
	self.stopgausscharge = WM_UNINIT;
};
/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() spike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9, MOD_HLIFE);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18, MOD_HLIFE);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};