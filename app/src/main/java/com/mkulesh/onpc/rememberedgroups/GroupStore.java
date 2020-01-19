package com.mkulesh.onpc.rememberedgroups;


import android.content.Context;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.room.Room;


public class GroupStore {
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

    public List<String> knownGroups(){  // possible improvement: any ordering desired?
        return db.groupDao().knownGroups();
    }

    public void save(String group, Map<String, Boolean> connectedness){
        List<GroupMembership> tuples = new ArrayList<>();
        for (String d: connectedness.keySet()){
            boolean connected = false;
            Boolean _connected = connectedness.get(d);
            if (_connected != null){
                connected = _connected;
            }

            tuples.add(new GroupMembership(group, d, connected));
        }
        db.groupDao().insertAll(tuples.toArray(new GroupMembership[0]));
    }

    public Map<String, Boolean> get(String name){
        Map<String, Boolean> connectedness = new HashMap<>();
        for (GroupMembership m: db.groupDao().getGroup(name)){
            connectedness.put(m.device, m.connected);
        }
        return connectedness;
    }

    public void deleteGroup(String name){
        db.groupDao().deleteGroup(name);
    }

}



