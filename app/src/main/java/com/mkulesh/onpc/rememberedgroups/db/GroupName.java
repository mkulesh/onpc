package com.mkulesh.onpc.rememberedgroups.db;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.ForeignKey;
import androidx.room.PrimaryKey;

import static androidx.room.ForeignKey.CASCADE;

@Entity(foreignKeys = @ForeignKey(
        entity = GroupMaster.class,
        parentColumns = {"group_name"},
        childColumns = {"group_name"},
        onDelete = CASCADE,
        onUpdate = CASCADE,
        deferred = true
))
public class GroupName {
    @ColumnInfo(name = "group_name")
    @PrimaryKey
    @NonNull
    public String group_name;

    public GroupName(String group_name){
        this.group_name = group_name;
    }
}