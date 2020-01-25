package com.mkulesh.onpc.rememberedgroups;

import java.util.Map;

public class GroupConfig {
    /**
     * this class is meant to encapsulate all info that is needed to restore a group
     */
    String master;  // host ip, TODO should probably rather store the MAC
    int master_port;
    Map<String, Boolean> slave_selection;


    public GroupConfig(String master, int master_port, Map<String, Boolean> slave_selection){
        this.master = master;
        this.master_port = master_port;
        this.slave_selection = slave_selection;
    }

    public String getMaster() {
        return master;
    }

    public int getMaster_port() {
        return master_port;
    }

    public Map<String, Boolean> getSlave_selection() {
        return slave_selection;
    }
}
