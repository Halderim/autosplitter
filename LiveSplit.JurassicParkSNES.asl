// Jurassic Park SNES Autosplitter
// https://github.com/Halderim/autosplitter

state("higan"){}
state("bsnes"){}
state("snes9x"){}
state("snes9x-x64"){}
state("emuhawk"){}
state("retroarch"){}
state("lsnes-bsnes"){}

startup
{
    settings.Add("objectives", false, "Objectives");
    settings.SetToolTip("objectives", "Split on game objectives");
    settings.Add("generator", false, "Generator on", "objectives");
    settings.SetToolTip("generator", "Split on turning on the generator");
    settings.Add("reboot", false, "Reboot computer", "objectives");
    settings.SetToolTip("reboot", "Split on rebooting the main computer");
    settings.Add("gasPicked", false, "Nervgas optained", "objectives");
    settings.SetToolTip("gasPicked", "Split on Nervgas pickup");
    settings.Add("gasSet", false, "Nervgas planted", "objectives");
    settings.SetToolTip("gasSet", "Split once planted Nervgas");
    settings.Add("visitorCenter", false, "Visitor Center sealed", "objectives");
    settings.SetToolTip("visitorCenter", "Split on sealing Visitor Center");
    settings.Add("security1", false, "Security Level 1", "objectives");
    settings.SetToolTip("security1", "Split on getting Security Level 1");
    settings.Add("security2", false, "Security Level 2", "objectives");
    settings.SetToolTip("security2", "Split on getting Security Level 2");
    settings.Add("shipSent", false, "Ship Communications", "objectives");
    settings.SetToolTip("shipSent", "Split on Ship Communications sent");
    settings.Add("mainlandSent", false, "Mainland Communications", "objectives");
    settings.SetToolTip("mainlandSent", "Split on Mainland Communications sent");

    settings.Add("idCards", false, "ID Cards");
    settings.SetToolTip("idCards", "Split on pickup ID Cards");
    settings.Add("malcomID", false, "Ian Malcom", "idCards");
    settings.SetToolTip("malcomID", "Split on picking up Ian Malcom's ID");
    settings.Add("hammondID", false, "John Hammond", "idCards");
    settings.SetToolTip("hammondID", "Split on picking up John Hammond's ID");
    settings.Add("grantID", false, "Alan Grant", "idCards");
    settings.SetToolTip("grantID", "Split on picking up Alan Grant's ID");
    settings.Add("sattlerID", false, "Ellie Sattler", "idCards");
    settings.SetToolTip("sattlerID", "Split on picking up Ellie Sattlers's ID");
    settings.Add("muldoonID", false, "Rober Muldoon", "idCards");
    settings.SetToolTip("muldoonID", "Split on picking up Rober Muldoon's ID");
    settings.Add("gennaroID", false, "Donald Gennaro", "idCards");
    settings.SetToolTip("gennaroID", "Split on picking up Donald Gennaro's ID");
    settings.Add("wuID", false, "Henry Wu", "idCards");
    settings.SetToolTip("wuID", "Split on picking up Henry Wu's ID");
    settings.Add("arnoldID", false, "Ray Arnold", "idCards");
    settings.SetToolTip("arnoldID", "Split on picking up Ray Arnold's ID");
    settings.Add("nedryID", false, "Dennis Nedry", "idCards");
    settings.SetToolTip("nedryID", "Split on picking up Dennis Nedry's ID");

    settings.Add("shipFloors", false, "Ship Floor");
    settings.SetToolTip("shipFloors", "Split on clearing floors on the ship");
    settings.Add("entryLevel", false, "Entry Level Cleared", "shipFloors");
    settings.SetToolTip("entryLevel", "Split on clearing Entry Level of Ship");
    settings.Add("sub1Level", false, "Sub Level 1 Cleared", "shipFloors");
    settings.SetToolTip("sub1Level", "Split on clearing Sub Level 1 of Ship");
    settings.Add("sub2Level", false, "Sub Level 2 Cleared", "shipFloors");
    settings.SetToolTip("sub2Level", "Split on clearing Sub Level 2 of Ship");
    settings.Add("sub3Level", false, "Sub Level 3 Cleared", "shipFloors");
    settings.SetToolTip("sub3Level", "Split on clearing Sub Level 3 of Ship");
    settings.Add("sub4Level", false, "Sub Level 4 Cleared", "shipFloors");
    settings.SetToolTip("sub4Level", "Split on clearing Sub Level 4 of Ship");

    settings.Add("rtaFinish", false, "Chopper Finish");
    settings.SetToolTip("rtaFinish", "Split on entering the helipad");

    settings.Add("fractalsFinish", false, "Fractals Finish");
    settings.SetToolTip("fractalsFinish", "Split on clicking on a fractals");
    
    vars.frameRate = 60.0;

    Action<string> DebugOutput = (text) => {
        print("[Jurasic Park SNES Autosplitter] "+text);
    };
    vars.DebugOutput = DebugOutput;
}

init
{
    IntPtr memoryOffset = IntPtr.Zero;

    if (memory.ProcessName.ToLower().Contains("snes9x")) {
        // TODO: These should probably be module-relative offsets too. Then
        // some of this codepath can be unified with the RA stuff below.
        var versions = new Dictionary<int, long>{
            { 10330112, 0x789414 },   // snes9x 1.52-rr
            { 7729152, 0x890EE4 },    // snes9x 1.54-rr
            { 5914624, 0x6EFBA4 },    // snes9x 1.53
            { 6909952, 0x140405EC8 }, // snes9x 1.53 (x64)
            { 6447104, 0x7410D4 },    // snes9x 1.54/1.54.1
            { 7946240, 0x1404DAF18 }, // snes9x 1.54/1.54.1 (x64)
            { 6602752, 0x762874 },    // snes9x 1.55
            { 8355840, 0x1405BFDB8 }, // snes9x 1.55 (x64)
            { 6856704, 0x78528C },    // snes9x 1.56/1.56.2
            { 9003008, 0x1405D8C68 }, // snes9x 1.56 (x64)
            { 6848512, 0x7811B4 },    // snes9x 1.56.1
            { 8945664, 0x1405C80A8 }, // snes9x 1.56.1 (x64)
            { 9015296, 0x1405D9298 }, // snes9x 1.56.2 (x64)
            { 6991872, 0x7A6EE4 },    // snes9x 1.57
            { 9048064, 0x1405ACC58 }, // snes9x 1.57 (x64)
            { 7000064, 0x7A7EE4 },    // snes9x 1.58
            { 9060352, 0x1405AE848 }, // snes9x 1.58 (x64)
            { 8953856, 0x975A54 },    // snes9x 1.59.2
            { 12537856, 0x1408D86F8 },// snes9x 1.59.2 (x64)
            { 9646080, 0x97EE04 },    // Snes9x-rr 1.60
            { 13565952, 0x140925118 },// Snes9x-rr 1.60 (x64)
            { 9027584, 0x94DB54 },    // snes9x 1.60
            { 12836864, 0x1408D8BE8 } // snes9x 1.60 (x64)
        };

        long pointerAddr;
        if (versions.TryGetValue(modules.First().ModuleMemorySize, out pointerAddr)) {
            memoryOffset = memory.ReadPointer((IntPtr)pointerAddr);
        }
    } else if (memory.ProcessName.ToLower().Contains("higan") || memory.ProcessName.ToLower().Contains("bsnes") || memory.ProcessName.ToLower().Contains("emuhawk") || memory.ProcessName.ToLower().Contains("lsnes-bsnes")) {
        var versions = new Dictionary<int, long>{
            { 12509184, 0x915304 },      // higan v102
            { 13062144, 0x937324 },      // higan v103
            { 15859712, 0x952144 },      // higan v104
            { 16756736, 0x94F144 },      // higan v105tr1
            { 16019456, 0x94D144 },      // higan v106
            { 15360000, 0x8AB144 },      // higan v106.112
            { 22388736, 0xB0ECC8 },      // higan v107
            { 23142400, 0xBC7CC8 },      // higan v108
            { 23166976, 0xBCECC8 },      // higan v109
            { 23224320, 0xBDBCC8 },      // higan v110
            { 23781376, 0xBB0CC8 },      // higan v110 (x64)
            { 10096640, 0x72BECC },      // bsnes v107
            { 10338304, 0x762F2C },      // bsnes v107.1
            { 47230976, 0x765F2C },      // bsnes v107.2/107.3
            { 142282752, 0xA65464 },     // bsnes v108
            { 131354624, 0xA6ED5C },     // bsnes v109
            { 131543040, 0xA9BD5C },     // bsnes v110
            { 51924992, 0xA9DD5C },      // bsnes v111
            { 52056064, 0xAAED7C },      // bsnes v112
            // Unfortunately v113/114 cannot be supported with this style
            // of check because their size matches v115, with a different offset
            //{ 52477952, 0xB15D7C },      // bsnes v113/114
            // This is the official release of v115, the Nightly releases report as v115 but won't work with this
            { 52477952, 0xB16D7C },      // bsnes v115
            { 7061504,  0x36F11500240 }, // BizHawk 2.3
            { 7249920,  0x36F11500240 }, // BizHawk 2.3.1
            { 6938624,  0x36F11500240 }, // BizHawk 2.3.2
            { 4538368,  0x36F05F94040 }, // BizHawk 2.6.0
            { 4546560, 0x36F05F94040 },  // BizHawk 2.6.1
            { 35414016, 0x023A1BF0 },    // lsnes rr2-B23
        };

        long wramAddr;
        if (versions.TryGetValue(modules.First().ModuleMemorySize, out wramAddr)) {
            memoryOffset = (IntPtr)wramAddr;
        }
    } else if (memory.ProcessName.ToLower().Contains("retroarch")) {
        // RetroArch stores a pointer to the emulated WRAM inside itself (it
        // can get this pointer via the Core API). This happily lets this work
        // on any variant of Snes9x cores, depending only on the RA version.

        var retroarchVersions = new Dictionary<int, int>{
            { 18649088, 0x608EF0 }, // Retroarch 1.7.5 (x64)
        };
        IntPtr wramPointer = IntPtr.Zero;
        int ptrOffset;
        if (retroarchVersions.TryGetValue(modules.First().ModuleMemorySize, out ptrOffset)) {
            wramPointer = memory.ReadPointer(modules.First().BaseAddress + ptrOffset);
        }

        if (wramPointer != IntPtr.Zero) {
            memoryOffset = wramPointer;
        } else {
            // Unfortunately, Higan doesn't support that API. So if the address
            // is missing, try to grab the memory from the higan core directly.

            var higanModule = modules.FirstOrDefault(m => m.ModuleName.ToLower() == "higan_sfc_libretro.dll");
            if (higanModule != null) {
                var versions = new Dictionary<int, int>{
                    { 4980736, 0x1F3AC4 }, // higan 106 (x64)
                };
                int wramOffset;
                if (versions.TryGetValue(higanModule.ModuleMemorySize, out wramOffset)) {
                    memoryOffset = higanModule.BaseAddress + wramOffset;
                }
            }
        }
    }

    if (memoryOffset == IntPtr.Zero) {
        vars.DebugOutput("Unsupported emulator version");
        var interestingModules = modules.Where(m =>
            m.ModuleName.ToLower().EndsWith(".exe") ||
            m.ModuleName.ToLower().EndsWith("_libretro.dll"));
        foreach (var module in interestingModules) {
            vars.DebugOutput("Module '" + module.ModuleName + "' sized " + module.ModuleMemorySize.ToString());
        }
        vars.watchers = new MemoryWatcherList{};
        // Throwing prevents initialization from completing. LiveSplit will
        // retry it until it eventually works. (Which lets you load a core in
        // RA for example.)
        throw new InvalidOperationException("Unsupported emulator version");
    }

    vars.DebugOutput("Found WRAM address: 0x" + memoryOffset.ToString("X8"));
    vars.watchers = new MemoryWatcherList
    {
        new MemoryWatcher<byte>(memoryOffset + 0x000263) { Name = "malcomCard" },
        new MemoryWatcher<byte>(memoryOffset + 0x000253) { Name = "hammondCard" },
        new MemoryWatcher<byte>(memoryOffset + 0x000259) { Name = "grantCard" },
        new MemoryWatcher<byte>(memoryOffset + 0x000255) { Name = "sattlerCard" },
        new MemoryWatcher<byte>(memoryOffset + 0x000257) { Name = "muldoonCard" },
        new MemoryWatcher<byte>(memoryOffset + 0x00025B) { Name = "gennaroCard" },
        new MemoryWatcher<byte>(memoryOffset + 0x000261) { Name = "wuCard" },
        new MemoryWatcher<byte>(memoryOffset + 0x00025D) { Name = "arnoldCard" },
        new MemoryWatcher<byte>(memoryOffset + 0x00025F) { Name = "nedryCard" },

        new MemoryWatcher<byte>(memoryOffset + 0x00026B) { Name = "generatorIsOn" },
        new MemoryWatcher<byte>(memoryOffset + 0x00026D) { Name = "rebootCom" },
        new MemoryWatcher<byte>(memoryOffset + 0x00026F) { Name = "vcSeal" },
        new MemoryWatcher<byte>(memoryOffset + 0x000265) { Name = "sec1" },
        new MemoryWatcher<byte>(memoryOffset + 0x000267) { Name = "sec2" },
        new MemoryWatcher<byte>(memoryOffset + 0x001DEF) { Name = "gasPickup" },  
        new MemoryWatcher<byte>(memoryOffset + 0x000273) { Name = "gasDeployed" },
        new MemoryWatcher<byte>(memoryOffset + 0x001DF5) { Name = "shipComSent" },
        new MemoryWatcher<byte>(memoryOffset + 0x000275) { Name = "mainlandComSent" },

        new MemoryWatcher<byte>(memoryOffset + 0x001E1B) { Name = "entryLevel" },
        new MemoryWatcher<byte>(memoryOffset + 0x001E28) { Name = "subLevel1" },
        new MemoryWatcher<byte>(memoryOffset + 0x001E29) { Name = "subLevel2" },
        new MemoryWatcher<byte>(memoryOffset + 0x001E2A) { Name = "subLevel3" },
        new MemoryWatcher<byte>(memoryOffset + 0x001E2B) { Name = "subLevel4" },
        
        new MemoryWatcher<byte>(memoryOffset + 0x000E0F) { Name = "eggCount" },
        new MemoryWatcher<byte>(memoryOffset + 0x000289) { Name = "allEggs" },
        new MemoryWatcher<byte>(memoryOffset + 0x00038B) { Name = "gameDone" },
        new MemoryWatcher<byte>(memoryOffset + 0x0018AB) { Name = "fractalsDone" },
    };
}

update
{
    vars.watchers.UpdateAll(game);
}

start
{
    var start   = vars.watchers["eggCount"].Old == 0    && vars.watchers["eggCount"].Current == 18;
    
    if (start) {
        vars.DebugOutput("Timer started");
    }
    return start;
}

reset
{
    return vars.watchers["eggCount"].Old != 0 && vars.watchers["eggCount"].Current == 0 && vars.watchers["allEggs"].Current == 0;
}

split
{
    // Card section
    var malcom  = settings["malcomID"] && (vars.watchers["malcomCard"].Old == 0 && vars.watchers["malcomCard"].Current > 0);
    var hammond = settings["hammondID"] && (vars.watchers["hammondCard"].Old == 0 && vars.watchers["hammondCard"].Current > 0);
    var grant   = settings["grantID"] && (vars.watchers["grantCard"].Old == 0 && vars.watchers["grantCard"].Current > 0);
    var sattler = settings["sattlerID"] && (vars.watchers["sattlerCard"].Old == 0 && vars.watchers["sattlerCard"].Current > 0);
    var muldoon = settings["muldoonID"] && (vars.watchers["muldoonCard"].Old == 0 && vars.watchers["muldoonCard"].Current > 0);
    var gennaro = settings["gennaroID"] && (vars.watchers["gennaroCard"].Old == 0 && vars.watchers["gennaroCard"].Current > 0);
    var wu      = settings["wuID"] && (vars.watchers["wuCard"].Old == 0 && vars.watchers["wuCard"].Current > 0);
    var arnold  = settings["arnoldID"] && (vars.watchers["arnoldCard"].Old == 0 && vars.watchers["arnoldCard"].Current > 0);
    var nedry   = settings["nedryID"] && (vars.watchers["nedryCard"].Old == 0 && vars.watchers["nedryCard"].Current > 0);

    var cards = malcom || hammond || grant || sattler || muldoon || gennaro || wu || arnold || nedry ;

    // Split on Objectives
    var generatorOn     = settings["generator"] && (vars.watchers["generatorIsOn"].Old == 0 && vars.watchers["generatorIsOn"].Current > 0);
    var rebootCom       = settings["reboot"] && (vars.watchers["rebootCom"].Old == 0 && vars.watchers["rebootCom"].Current > 0);
    var vcSealed        = settings["visitorCenter"] && (vars.watchers["vcSeal"].Old == 0 && vars.watchers["vcSeal"].Current > 0);
    var gasPickup       = settings["gasPicked"] && (vars.watchers["gasPickup"].Old == 0 && vars.watchers["gasPickup"].Current > 0);
    var gasPlanted      = settings["gasSet"] && (vars.watchers["gasDeployed"].Old == 0 && vars.watchers["gasDeployed"].Current > 0);
    var sec1granted     = settings["security1"] && (vars.watchers["sec1"].Old == 0 && vars.watchers["sec1"].Current > 0);
    var sec2granted     = settings["security2"] && (vars.watchers["sec2"].Old == 0 && vars.watchers["sec2"].Current > 0);
    var shipComSent     = settings["shipSent"] && (vars.watchers["shipComSent"].Old == 0 && vars.watchers["shipComSent"].Current > 0);
    var mainlandComSent = settings["mainlandSent"] && (vars.watchers["mainlandComSent"].Old == 0 && vars.watchers["mainlandComSent"].Current > 0);

    var objectives      = generatorOn || rebootCom || vcSealed || gasPickup || gasPlanted || sec1granted || sec2granted || shipComSent || mainlandComSent ;

    // Split on floors
    var entry     = settings["entryLevel"] && (vars.watchers["entryLevel"].Old == 0 && vars.watchers["entryLevel"].Current > 0);
    var sub1      = settings["sub1Level"] && (vars.watchers["subLevel1"].Old == 0 && vars.watchers["subLevel1"].Current > 0);
    var sub2      = settings["sub2Level"] && (vars.watchers["subLevel2"].Old == 0 && vars.watchers["subLevel2"].Current > 0);
    var sub3      = settings["sub3Level"] && (vars.watchers["subLevel3"].Old == 0 && vars.watchers["subLevel3"].Current > 0);
    var sub4      = settings["sub4Level"] && (vars.watchers["subLevel4"].Old == 0 && vars.watchers["subLevel4"].Current > 0);    

    var floors      = entry || sub1 || sub2 || sub3 || sub4;

    // Run-ending splits
    var finish = settings["rtaFinish"] && (vars.watchers["gameDone"].Old == 0 && vars.watchers["gameDone"].Current > 0);

    // Fractals Run-ending splits
    var fFinish = settings["fractalsFinish"] && (vars.watchers["fractalsDone"].Old == 8 && (vars.watchers["fractalsDone"].Current == 140 || vars.watchers["fractalsDone"].Current == 129 || vars.watchers["fractalsDone"].Current == 132 || vars.watchers["fractalsDone"].Current == 133 || vars.watchers["fractalsDone"].Current == 139 || vars.watchers["fractalsDone"].Current == 138 || vars.watchers["fractalsDone"].Current == 128 || vars.watchers["fractalsDone"].Current == 136 ) );


    if(malcom){
        vars.DebugOutput("Split due to malcom card pickup");
    }
    if(hammond){
        vars.DebugOutput("Split due to hammond card pickup");
    }
    if(grant){
        vars.DebugOutput("Split due to grant card pickup");
    }
    if(sattler){
        vars.DebugOutput("Split due to sattler card pickup");
    }
    if(muldoon){
        vars.DebugOutput("Split due to muldoon card pickup");
    }
    if(gennaro){
        vars.DebugOutput("Split due to gennaro card pickup");
    }
    if(wu){
        vars.DebugOutput("Split due to wu card pickup");
    }
    if(arnold){
        vars.DebugOutput("Split due to arnold card pickup");
    }
    if(nedry){
        vars.DebugOutput("Split due to nedry card pickup");
    }

    if(generatorOn){
        vars.DebugOutput("Split due to generatorOn done");
    }
    if(rebootCom){
        vars.DebugOutput("Split due to rebootCom done");
    }
    if(vcSealed){
        vars.DebugOutput("Split due to vcSealed done");
    }
    if(sec1granted){
        vars.DebugOutput("Split due to sec1granted done");
    }
    if(sec2granted){
        vars.DebugOutput("Split due to sec2granted done");
    }
    if(shipComSent){
        vars.DebugOutput("Split due to shipComSent done");
    }
    if(mainlandComSent){
        vars.DebugOutput("Split due to mainlandComSent done");
    }
    if(gasPickup){
        vars.DebugOutput("Split due to gasPickup done");
    }
    if(gasPlanted){
        vars.DebugOutput("Split due to gasPlanted done");
    }
    
    return cards || objectives || floors || finish || fFinish;
}
