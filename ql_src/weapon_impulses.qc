/*
============
ImpulseCommands

============
*/
void () parse_hl_crap;
void (float do_mats, string s1, string s2) parse_hl_map;
void (string s1, string s2, string s3) hl_swap_ents;
void () hl_batch_convert;
void() ImpulseCommands =
{
	local entity test;
	local string mname;
	mname = "c1a4b";
	
	switch (self.impulse) {
	case 1 .. 9:
		W_ChangeWeapon ();
		break;
	case 10:
		CheatCommand ();
		break;
	case 11:
		CycleWeaponCommand ();
		break;
	case 12:
		ServerflagsCommand ();
		break;
	case 13:
		CycleWeaponReverseCommand ();
		break;
#ifdef HALFLIFE
	case 202:
        if(self.crouchflags != #CROUCH_ON) {
			// crouch code // TODO Refactor
			setsize(self, VEC_HULL_MIN, VEC_HULL_CROUCH);
			self.crouchflags = #CROUCH_ON;
			self.view_ofs_z = 35; 
			// crouch code
        } 
		else {
            // self.crouchflags = #CROUCH_TRYSTAND;
        }
		break;
	case 203:
		self.crouchflags = #CROUCH_TRYSTAND;
		break;
	case 104:
		FindUseEntity(self, 0);
		break;
	case 105:
		FindEntities(self);
		break;
	case 106:
		_bprint(vtos(self.origin), "\n");
		break;
	case 107:
		FindUseEntity(self, 1);
		break;
	case 109:
		parse_hl_crap();
		break;
	case 110:
		test = find(world, classname, "trigger_once");
		while (test)
		{
			if (test.target == "retinalscan") {
				//_bprint("I EXIST at", vtos(self.origin), "\n");
				setorigin(self, (test.absmax+test.absmin)*.5);
			}
			test = find(test, classname, "trigger_once");
		}
		break;
	case 120:
		FindUseEntity(self, 2);
		break;
	case 121:
		parse_hl_map(1, mname, mname);
		break;
	case 122:
		hl_swap_ents(mname,mname,mname);
		break;
	case 123:
		_bprint(" no mats being parsed\n");
		parse_hl_map(0, "toconv", "toconv");
		break;
	case 124:
		hl_batch_convert();
		break;
	// -- start -- secondary fire mode section
    case 210:
        self.secondary_attack_mode = 0; // primary trigger
		break;
    case 211:
        self.secondary_attack_mode = 1; // secondary trigger
		break;
    case 212:
        W_ToggleFireMode(); // toggle switch
		break;
	case 213:
		W_PostFireAction();
		break;
	// -- end ---- secondary fire mode 
#endif

	}

	self.impulse = 0;
};
