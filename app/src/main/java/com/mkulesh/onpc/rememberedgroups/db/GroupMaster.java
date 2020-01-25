package com.mkulesh.onpc.rememberedgroups.db;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.ForeignKey;
import androidx.room.PrimaryKey;

import static androidx.room.ForeignKey.CASCADE;

@Entity(foreignKeys = @ForeignKey(
        entity = GroupName.class,
        parentColumns = {"group_name"},
        childColumns = {"group_name"},
        onDelete = CASCADE,
        onUpdate = CASCADE,
        deferred = true
))
public class GroupMaster {
    @ColumnInfo(name = "group_name")
    @PrimaryKey
    @NonNull
    public String group_name;

    @ColumnInfo(name = "master_device")
    @NonNull
    public String master_device;

    @ColumnInfo(name = "port")  // TODO fix db schema
    @NonNull
    public int port;

    public GroupMaster(String group_name, String master_device, int port){
        this.group_name = group_name;
        this.master_device = master_device;
        this.port = port;
    }
}