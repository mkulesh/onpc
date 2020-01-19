package com.mkulesh.onpc.rememberedgroups;

import androidx.room.Database;
import androidx.room.RoomDatabase;

@Database(entities = {GroupMembership.class}, version = 1, exportSchema = true)
public abstract class AppDatabase extends RoomDatabase {
    public abstract GroupDao groupDao();
}
