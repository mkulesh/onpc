package com.mkulesh.onpc.rememberedgroups;


import android.content.Context;

import com.mkulesh.onpc.rememberedgroups.db.GroupMaster;
import com.mkulesh.onpc.rememberedgroups.db.GroupName;
import com.mkulesh.onpc.rememberedgroups.db.GroupSlaveSelection;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.room.Room;


public class GroupStore {
    /**
     * indirection between GroupDao and callers, seems useful for flexibility but maybe the DAO
     * could actually provide full flexibility -- in that case this class could be merged into it
     */
    private static GroupStore singleton;
    private AppDatabase db;

    private GroupStore(Context context){
        db = Room.databaseBuilder(context.getApplicationContext(),
                AppDatabase.class, "oncp-group-database").allowMainThreadQueries().build();

    }

    public static GroupStore getI(Context context){
        if (singleton == null){
            singleton = new GroupStore(context);
        }
        return singleton;
    }

    public List<String> allGroups(){  // possible improvement: any ordering desired?
        return db.groupDao().allGroups();
    }

    public List<String> groupsWithMaster(String master){
        return db.groupDao().groupsWithMaster(master);
    }

    public void save(String name, GroupConfig group){
        // TODO probably we should rather save the id/mac,
        //  not the current ip?
        String master_host = group.getMaster();
        int master_port = group.getMaster_port();
        Map<String, Boolean> slave_selection = group.getSlave_selection();

        List<GroupSlaveSelection> slaves = new ArrayList<>();
        for (String d: slave_selection.keySet()){
            boolean connected = false;
            Boolean _connected = slave_selection.get(d);
            if (_connected != null){
                connected = _connected;
            }
            slaves.add(new GroupSlaveSelection(name, d, connected));
        }

        db.groupDao().saveOrUpdateGroup(
                new GroupName(name),
                new GroupMaster(name, master_host, master_port),
                slaves);
    }

    public GroupConfig get(String name){
        List<GroupMaster> group_master_list = db.groupDao().getGroupMaster(name);
        if(group_master_list.size() != 1){
            throw new RuntimeException("unexpected result when retrieving stored group master: "
                    + name + ", " + group_master_list.size());
        }

        GroupMaster master = group_master_list.get(0);

        Map<String, Boolean> connectedness = new HashMap<>();
        for (GroupSlaveSelection m: db.groupDao().getGroupSlaveSelection(name)){
            connectedness.put(m.device, m.connected);
        }
        return new GroupConfig(
                master.master_device,
                master.port,
                connectedness);
    }

    public void deleteGroup(String name){
        db.groupDao().deleteGroup(name);
    }

}



