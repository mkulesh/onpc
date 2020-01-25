package com.mkulesh.onpc.rememberedgroups;

import com.mkulesh.onpc.rememberedgroups.db.GroupMaster;
import com.mkulesh.onpc.rememberedgroups.db.GroupSlaveSelection;
import com.mkulesh.onpc.rememberedgroups.db.GroupName;

import androidx.room.Database;
import androidx.room.RoomDatabase;

@Database(
        entities = {GroupSlaveSelection.class, GroupMaster.class, GroupName.class},
        version = 2,
        exportSchema = true)
public abstract class AppDatabase extends RoomDatabase {
    public abstract GroupDao groupDao();
}
