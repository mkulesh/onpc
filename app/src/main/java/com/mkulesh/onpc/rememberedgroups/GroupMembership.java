package com.mkulesh.onpc.rememberedgroups;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(primaryKeys = {"group_name", "device"})
public class GroupMembership {

    // TODO the corresponding master device must be saved too
    // Blocker: I have not yet figuered out how the master device is represented in the
    // addCmd etc commands
    // Also, some general understanding of the commumication with the speakers
    // would be helpful, so that we can store all information that is needed to
    // enable / disable stored groups from android 8+ homescreen shortcuts
    // *without* opening the corresponding view in the app

    @ColumnInfo(name = "group_name")
    @NonNull
    public String group;

    @ColumnInfo(name = "device")
    @NonNull
    public String device;

    @ColumnInfo(name = "connected")
    @NonNull
    public boolean connected;

    public GroupMembership(String group, String device, boolean connected){
        this.group = group;
        this.device = device;
        this.connected = connected;
    }
}