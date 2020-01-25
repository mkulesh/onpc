package com.mkulesh.onpc.rememberedgroups.db;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.ForeignKey;
import static androidx.room.ForeignKey.CASCADE;

@Entity(primaryKeys = {"group_name", "device"},
        foreignKeys = @ForeignKey(
                entity = GroupName.class,
                parentColumns = {"group_name"},
                childColumns = {"group_name"},
                onDelete = CASCADE,
                onUpdate = CASCADE,
                deferred = true
        )
)
public class GroupSlaveSelection {
    /**
     * Represents whether a (slave) member of a group, or not.
     *
     * Currently the membership/not-membership is explicitly stored via
     * the boolean "connected", rather than implicitly via existence
     * of the corresponding (group_name, device) row.
     *
     * Not sure if this is a good way to do this,
     * but it seems more convenient for handling the case
     * when a group is updated, but some of its member devices
     * may currently be offline:
     * with this explicit approach, such currently-offline devices
     * will stay in the group when a set of GroupSlaveSelections is
     * inserted for currently-connected devices.
     * With the implicit
     * approach, one would need a more elaborate query that
     * inserts all explicitly-selected devices, deletes all
     * currently-conneted-but-not-selected devices, and doesn't
     * touch the devices that are not currently connected.
     */

    @ColumnInfo(name = "group_name")
    @NonNull
    public String group;

    @ColumnInfo(name = "device")
    @NonNull
    public String device;

    @ColumnInfo(name = "connected")
    @NonNull
    public boolean connected;

    public GroupSlaveSelection(String group, String device, boolean connected){
        this.group = group;
        this.device = device;
        this.connected = connected;
    }
}