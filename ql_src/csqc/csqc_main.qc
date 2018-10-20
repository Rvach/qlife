float(string str) CSQC_ConsoleCommand =
{
	local float args;
	args = tokenize(str);

	switch(argv(0))
	{
	    default:
		return FALSE;
	}
	return TRUE;
};

var float autocvar_dp_workarounds_allow = TRUE;
var float autocvar_dp_workarounds_force = FALSE;
void(float reqid, float response, string body) URI_Get_Callback =
{
	print(body);
};
.string ip;
.string netname;
float pn;
string pf;

void() UpdateInfoOnFragsCountChange = 
{
    if(pf != getplayerkeyvalue(pn, "frags"))
    {
        pf = getplayerkeyvalue(pn, "frags");
        local float file = fopen("cs_report.json",FILE_WRITE);
        fputs(file,"{");
            fputs(file, "frags : ");          fputs(file, getplayerkeyvalue(pn, "frags"));
            fputs(file,",server_info : {");
                fputs(file, "mapname : ");      fputs(file, mapname);
                fputs(file,",at_net_srv_id : ");fputs(file, serverkey("at_net_srv_id"));    // Look up a key in the server's public serverinfo string
                fputs(file,",id : ");           fputs(file, serverid);                      // unique id of server in a server cluster
                fputs(file,",name : ");         fputs(file, SERVERKEY_SERVERNAME);
                fputs(file,",constate : ");     fputs(file, SERVERKEY_CONSTATE);
                fputs(file,",protocol : ");     fputs(file, SERVERKEY_PROTOCOL);
                fputs(file,",ip : ");           fputs(file, SERVERKEY_IP);
            fputs(file," }\n");
        fputs(file," }\n");
        fclose(file);
    }
}

void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
        pn = player_localnum;
        pf = "";

        local float file = fopen("test.txt",FILE_APPEND);
        fputs(file,"Hello!\n");
        fclose(file);
};
	
void() CSQC_Shutdown = 
{
        local float file = fopen("test.txt",FILE_APPEND);
        fputs(file,"Goodbye!\n");
        fclose(file);
};

// float (float event, float parama, float paramb, float devid) CSQC_InputEvent =
// {

// };

void(float width, float height, float do2d) CSQC_UpdateView =
{
    clearscene();
    setviewprop(VF_DRAWWORLD, 1);
    setviewprop(VF_DRAWCROSSHAIR, 1);
    setviewprop(VF_DRAWENGINESBAR, 1);
    addentities(0 | 1 | 2);
    renderscene();

    UpdateInfoOnFragsCountChange();
};


//void(float width, float height, float do2d) CSQC_UpdateView_Loading = CSQC_UpdateView;