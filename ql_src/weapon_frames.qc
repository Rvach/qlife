/*
============
W_HandlePlayerFrame

Handle player weapon model
============
*/
void() W_HandlePlayerFrame =
{
	if (!self.weaponframe)
		return;

	if (self.weaponframe_time >= time)
		return;

	switch (self.weapon)
	{
	case W_BLASTER:
		// // axe frames can start at 1 or 5
		// self.weaponframe_time = time + 0.1;
		// self.weaponframe = self.weaponframe + 1;
		// if (self.weaponframe > 12)
		// 	self.weaponframe = 8;
		// return;
    case W_SUPER_BLASTER:
		// self.weaponframe_time = time + 0.1;
		// self.weaponframe = self.weaponframe + 1;
        // if (self.weaponframe > 73)
		// 	self.weaponframe = 63;
        // else 
        //     self.weaponframe = 63;
		// return;
	case W_AUTOGUN:
	case W_RPG:
		// // cycle until fire button is released
		// if (self.weaponstate != WS_IDLE)
 		// {
		// 	self.weaponframe_time = time + 0.1;
  		// 	self.weaponframe = self.weaponframe + 1;
  		// 	if (self.weaponframe > 8)
  		// 		self.weaponframe = 1;
  		// }
  		// else
  		// 	self.weaponframe = 0;

		// return;
	case W_CROSSBOW:
		// // cycle until fire button is released
		// if (self.weaponstate != WS_IDLE)
		// {
		// 	self.weaponframe_time = time + 0.1;
		// 	self.weaponframe = self.weaponframe + 1;
		// 	if (self.weaponframe > 4)
		// 		self.weaponframe = 1;
		// }
		// else
		// 	self.weaponframe = 0;
		// return;
	default:
		self.weaponframe = self.weaponframe + 1;
		self.weaponframe_time = time + 0.1;
		if (self.weaponframe > 0)
			self.weaponframe = 0;
	}
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	local INTEGER scount;

	W_HandlePlayerFrame();
	// check if previous attack finished but continue weapon charge to handle immediate discharge on button0 release
	if (time < self.attack_finished && self.charging_weapon < 1)
		return;

	if (self.impulse)
		ImpulseCommands ();
	
// check for attack
	if (self.button0)
	{
		scount = 0;
		// play catchup but don't allow more than 4 shots per frame
		while (self.attack_finished <= time)
		{
			if (scount >= 4)
			{
				self.attack_finished = time;
				break;
			}

			W_Attack();
			scount++;
		}
		self.button0_save = scount; // DEBUG
	}
	else
	{
		if(self.button0_save > 0) { // DEBUG
        	_bprint("Attack Button Released\n");
			self.button0_save = 0;
		}
		self.attack_finished = time;
		self.weaponstate = WS_IDLE;
		self.charging_weapon = 0;
	}
};