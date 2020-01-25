package com.mkulesh.onpc.rememberedgroups;


import com.mkulesh.onpc.rememberedgroups.db.GroupMaster;
import com.mkulesh.onpc.rememberedgroups.db.GroupName;
import com.mkulesh.onpc.rememberedgroups.db.GroupSlaveSelection;

import java.util.List;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import static androidx.room.OnConflictStrategy.REPLACE;

@Dao
public interface GroupDao {
    @Query("SELECT DISTINCT group_name FROM GroupName")
    List<String> allGroups();

    @Query("SELECT DISTINCT group_name FROM GroupMaster WHERE master_device = :master")
    List<String> groupsWithMaster(String master);

    @Query("DELETE FROM GroupName WHERE group_name = :group_name")
    int deleteGroup(String group_name);

    @Insert(onConflict = REPLACE)
    // this should keep existing slave entries that are not present in the supplied
    // TODO not sure what would happen if a former
        //  slave becomes the master. That won't happen with current UI though
    void saveOrUpdateGroup(GroupName name, GroupMaster master, List<GroupSlaveSelection> slaveSelection);

    @Query("SELECT * FROM GroupSlaveSelection WHERE group_name = :group")
    List<GroupSlaveSelection> getGroupSlaveSelection(String group);

    @Query("SELECT * FROM GroupMaster WHERE group_name = :group")
    List<GroupMaster> getGroupMaster(String group);


}
