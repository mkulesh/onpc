package com.mkulesh.onpc.rememberedgroups;


import java.util.List;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

@Dao
public interface GroupDao {
    @Query("SELECT * FROM GroupMembership WHERE group_name = :group")
    List<GroupMembership> getGroup(String group);

    @Query(("SELECT DISTINCT group_name FROM GroupMembership"))
    List<String> knownGroups();

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertAll(GroupMembership... memberships);

    @Query("DELETE FROM GroupMembership WHERE group_name = :group")
    int deleteGroup(String group);
}
