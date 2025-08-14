/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2025 by Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details. You should have received a copy of the GNU General
 * Public License along with this program.
 */

package com.mkulesh.onpc.fragments;

import android.graphics.drawable.Drawable;
import android.os.Build;
import android.text.Html;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.view.LayoutInflater;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.mkulesh.onpc.MainActivity;
import com.mkulesh.onpc.R;
import com.mkulesh.onpc.config.CfgFavoriteShortcuts;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.DcpSearchMsg;
import com.mkulesh.onpc.iscp.messages.FirmwareUpdateMsg;
import com.mkulesh.onpc.iscp.messages.NetworkStandByMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.PresetMemoryMsg;
import com.mkulesh.onpc.utils.Utils;
import com.mkulesh.onpc.widgets.HorizontalNumberPicker;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.view.ContextThemeWrapper;
import androidx.appcompat.widget.AppCompatEditText;
import androidx.appcompat.widget.AppCompatRadioButton;

public class Dialogs
{
    private final MainActivity activity;

    public interface ButtonListener
    {
        void onPositiveButton();
    }

    public interface TextEditListener
    {
        void onRename(final String text);
    }

    public Dialogs(final MainActivity activity)
    {
        this.activity = activity;
    }

    public AlertDialog createOkDialog(@NonNull final FrameLayout frameView, @DrawableRes final int iconId, @StringRes final int titleId)
    {
        final Drawable icon = Utils.getDrawable(activity, iconId);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        return new AlertDialog.Builder(activity)
                .setTitle(titleId)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView)
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog1, which) -> dialog1.dismiss())
                .create();
    }

    public void showDcpSearchDialog(@NonNull final State state, final ButtonListener bl)
    {
        if (state.getDcpSearchCriteria() == null)
        {
            return;
        }

        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_dcp_search_layout, frameView);

        final RadioGroup searchCriteria = frameView.findViewById(R.id.search_criteria_group);
        for (int i = 0; i < state.getDcpSearchCriteria().size(); i++)
        {
            final ContextThemeWrapper wrappedContext = new ContextThemeWrapper(activity, R.style.RadioButtonStyle);
            final AppCompatRadioButton b = new AppCompatRadioButton(wrappedContext, null, 0);
            final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            b.setLayoutParams(lp);
            b.setText(getTranslatedName(activity, state.getDcpSearchCriteria().get(i).first));
            b.setTag(state.getDcpSearchCriteria().get(i).second);
            b.setChecked(i == 0);
            b.setTextColor(Utils.getThemeColorAttr(activity, android.R.attr.textColor));
            b.setOnClickListener((v) -> {
                for (int k = 0; k < searchCriteria.getChildCount(); k++)
                {
                    final AppCompatRadioButton b1 = (AppCompatRadioButton) searchCriteria.getChildAt(k);
                    b1.setChecked(b1.getTag().equals(v.getTag()));
                }
            });
            searchCriteria.addView(b);
        }
        searchCriteria.invalidate();
        final AppCompatEditText searchText = frameView.findViewById(R.id.search_string);
        searchText.setText(activity.getStateManager().getState().artist);

        final Drawable icon = Utils.getDrawable(activity, R.drawable.cmd_search);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.medialist_search)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView)
                .setNegativeButton(activity.getResources().getString(R.string.action_cancel), (dialog1, which) ->
                {
                    Utils.showSoftKeyboard(activity, searchText, false);
                    dialog1.dismiss();
                })
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog2, which) ->
                {
                    Utils.showSoftKeyboard(activity, searchText, false);
                    for (int i = 0; i < searchCriteria.getChildCount(); i++)
                    {
                        final AppCompatRadioButton b = (AppCompatRadioButton) searchCriteria.getChildAt(i);
                        if (b.isChecked() && searchText.getText() != null && searchText.getText().length() > 0)
                        {
                            activity.getStateManager().sendMessage(new DcpSearchMsg(
                                    activity.getStateManager().getState().mediaListSid,
                                    b.getTag().toString(),
                                    searchText.getText().toString()));
                            if (bl != null)
                            {
                                bl.onPositiveButton();
                            }
                        }
                    }
                    dialog2.dismiss();
                })
                .create();

        dialog.show();
        Utils.fixDialogLayout(dialog, android.R.attr.textColorSecondary);
    }

    @NonNull
    static String getTranslatedName(@NonNull MainActivity activity, String item)
    {
        final String[] sourceNames = new String[]{
                "Artist",
                "Album",
                "Track",
                "Station",
                "Playlist"
        };
        final int[] targetNames = new int[]{
                R.string.medialist_search_artist,
                R.string.medialist_search_album,
                R.string.medialist_search_track,
                R.string.medialist_search_station,
                R.string.medialist_search_playlist
        };
        for (int i = 0; i < sourceNames.length; i++)
        {
            if (sourceNames[i].equalsIgnoreCase(item))
            {
                return activity.getString(targetNames[i]);
            }
        }
        return item;
    }

    public void showTextEditDialog(@StringRes int titleId, @DrawableRes int iconId, final String oldText, final TextEditListener bl)
    {
        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_text_edit_layout, frameView);

        final EditText textField = frameView.findViewById(R.id.text_field);
        textField.setText(oldText);

        final Drawable icon = Utils.getDrawable(activity, iconId);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(titleId)
                .setIcon(icon)
                .setCancelable(false)
                .setView(frameView)
                .setNegativeButton(activity.getResources().getString(R.string.action_cancel), (dialog1, which) ->
                {
                    Utils.showSoftKeyboard(activity, textField, false);
                    dialog1.dismiss();
                })
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog2, which) ->
                {
                    Utils.showSoftKeyboard(activity, textField, false);
                    if (bl != null)
                    {
                        bl.onRename(textField.getText().toString());
                    }
                    dialog2.dismiss();
                })
                .create();

        dialog.show();
        Utils.fixDialogLayout(dialog, android.R.attr.textColorSecondary);
    }

    public void showFirmwareUpdateDialog()
    {
        final Drawable icon = Utils.getDrawable(activity, R.drawable.cmd_firmware_update);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.device_firmware)
                .setIcon(icon)
                .setCancelable(true)
                .setMessage(R.string.device_firmware_confirm)
                .setNegativeButton(R.string.action_cancel, (d, which) -> d.dismiss())
                .setPositiveButton(R.string.action_ok, (d, which) ->
                {
                    if (activity.isConnected())
                    {
                        activity.getStateManager().sendMessageToGroup(
                                new FirmwareUpdateMsg(FirmwareUpdateMsg.Status.NET));
                    }
                    d.dismiss();
                })
                .create();

        dialog.show();
        Utils.fixDialogLayout(dialog, android.R.attr.textColorSecondary);
    }

    public void showNetworkStandByDialog()
    {
        final Drawable icon = Utils.getDrawable(activity, R.drawable.menu_power_standby);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.device_network_standby)
                .setIcon(icon)
                .setCancelable(true)
                .setMessage(R.string.device_network_standby_confirm)
                .setNegativeButton(R.string.action_cancel, (d, which) -> d.dismiss())
                .setPositiveButton(R.string.action_ok, (d, which) ->
                {
                    if (activity.isConnected())
                    {
                        activity.getStateManager().sendMessage(new NetworkStandByMsg(NetworkStandByMsg.Status.OFF));
                    }
                    d.dismiss();
                })
                .create();

        dialog.show();
        Utils.fixDialogLayout(dialog, android.R.attr.textColorSecondary);
    }

    public void showAvInfoDialog(@Nullable final State state)
    {
        if (state == null)
        {
            return;
        }

        if (state.avInfoAudioInput.isEmpty() && state.avInfoAudioOutput.isEmpty() &&
                state.avInfoVideoInput.isEmpty() && state.avInfoVideoOutput.isEmpty())
        {
            return;
        }

        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_av_info, frameView);

        if (activity.getResources() != null)
        {
            ((TextView) frameView.findViewById(R.id.av_info_audio_input)).setText(
                    String.format(activity.getResources().getString(
                            R.string.av_info_input), state.avInfoAudioInput));

            ((TextView) frameView.findViewById(R.id.av_info_audio_output)).setText(
                    String.format(activity.getResources().getString(
                            R.string.av_info_output), state.avInfoAudioOutput));

            ((TextView) frameView.findViewById(R.id.av_info_video_input)).setText(
                    String.format(activity.getResources().getString(
                            R.string.av_info_input), state.avInfoVideoInput));

            ((TextView) frameView.findViewById(R.id.av_info_video_output)).setText(
                    String.format(activity.getResources().getString(
                            R.string.av_info_output), state.avInfoVideoOutput));
        }

        final AlertDialog dialog = createOkDialog(frameView, state.getServiceIcon(), R.string.av_info_dialog);
        dialog.show();
        Utils.fixDialogLayout(dialog, android.R.attr.textColorSecondary);
    }

    public void showPresetMemoryDialog(@NonNull final State state)
    {
        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_preset_memory, frameView);

        final HorizontalNumberPicker numberPicker = frameView.findViewById(R.id.preset_memory_number);
        numberPicker.minValue = 1;
        numberPicker.maxValue = PresetMemoryMsg.MAX_NUMBER;
        numberPicker.setValue(state.nextEmptyPreset());
        numberPicker.setEnabled(true);

        final Drawable icon = Utils.getDrawable(activity, R.drawable.cmd_track_menu);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.cmd_preset_memory)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView)
                .setNegativeButton(activity.getResources().getString(R.string.action_cancel), (dialog1, which) ->
                {
                    Utils.showSoftKeyboard(activity, numberPicker, false);
                    dialog1.dismiss();
                })
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog12, which) ->
                {
                    Utils.showSoftKeyboard(activity, numberPicker, false);
                    // in order to get updated preset list, we need to request Receiver Information
                    activity.getStateManager().requestRIonPreset(true);
                    activity.getStateManager().sendMessage(new PresetMemoryMsg(numberPicker.getValue()));
                })
                .create();

        dialog.show();
        Utils.fixDialogLayout(dialog, android.R.attr.textColorSecondary);
    }

    public void showEditShortcutDialog(@NonNull final CfgFavoriteShortcuts.Shortcut shortcut, final ButtonListener bl)
    {
        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_favorite_shortcut_layout, frameView);

        final TextView path = frameView.findViewById(R.id.favorite_shortcut_path);
        path.setText(shortcut.getLabel(activity));

        final EditText alias = frameView.findViewById(R.id.favorite_shortcut_alias);
        alias.setText(shortcut.alias);

        final Drawable icon = Utils.getDrawable(activity, R.drawable.drawer_edit_item);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.favorite_shortcut_edit)
                .setIcon(icon)
                .setCancelable(false)
                .setView(frameView)
                .setNegativeButton(activity.getResources().getString(R.string.action_cancel), (dialog1, which) ->
                {
                    Utils.showSoftKeyboard(activity, alias, false);
                    dialog1.dismiss();
                })
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog2, which) ->
                {
                    Utils.showSoftKeyboard(activity, alias, false);
                    activity.getConfiguration().favoriteShortcuts.updateShortcut(
                            shortcut, alias.getText().toString());
                    if (bl != null)
                    {
                        bl.onPositiveButton();
                    }
                    dialog2.dismiss();
                })
                .create();

        dialog.show();
        Utils.fixDialogLayout(dialog, android.R.attr.textColorSecondary);
    }

    public void showOnStandByDialog(@NonNull final PowerStatusMsg cmdMsg)
    {
        final Drawable icon = Utils.getDrawable(activity, R.drawable.menu_power_standby);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.menu_power_standby)
                .setIcon(icon)
                .setCancelable(true)
                .setMessage(R.string.menu_switch_off_group)
                .setNeutralButton(R.string.action_cancel, (d, which) -> d.dismiss())
                .setNegativeButton(R.string.action_no, (d, which) ->
                {
                    activity.getStateManager().sendMessage(cmdMsg);
                    d.dismiss();
                })
                .setPositiveButton(R.string.action_ok, (d, which) ->
                {
                    activity.getStateManager().sendMessageToGroup(cmdMsg);
                    d.dismiss();
                }).create();
        dialog.show();
        Utils.fixDialogLayout(dialog, android.R.attr.textColorSecondary);
    }

    public void showHtmlDialog(@DrawableRes int icon, @StringRes int title, @StringRes int textId)
    {
        final AlertDialog dialog = buildHtmlDialog(icon, title, activity.getResources().getString(textId), true);
        dialog.show();
        Utils.fixDialogLayout(dialog, null);
    }

    public void showXmlDialog(@DrawableRes int icon, @StringRes int title, final String text)
    {
        final AlertDialog dialog = buildHtmlDialog(icon, title, text, false);
        dialog.show();
        Utils.fixDialogLayout(dialog, null);
    }

    /**
     * @noinspection RedundantSuppression
     */
    @SuppressWarnings("deprecation")
    private AlertDialog buildHtmlDialog(@DrawableRes int icon, @StringRes int title, final String text, final boolean isHtml)
    {
        final FrameLayout frameView = new FrameLayout(activity);
        final AlertDialog alertDialog = new AlertDialog.Builder(activity)
                .setTitle(title)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView)
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog, which) -> { /* empty */ }).create();

        final LayoutInflater inflater = alertDialog.getLayoutInflater();
        final FrameLayout dialogFrame = (FrameLayout) inflater.inflate(R.layout.dialog_html_layout, frameView);

        if (text.isEmpty())
        {
            return alertDialog;
        }

        final TextView aboutMessage = dialogFrame.findViewById(R.id.text_message);
        if (isHtml)
        {
            Spanned result;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
            {
                result = Html.fromHtml(text, Html.FROM_HTML_MODE_LEGACY);
            }
            else
            {
                result = Html.fromHtml(text);
            }
            aboutMessage.setText(result);
            aboutMessage.setMovementMethod(LinkMovementMethod.getInstance());
        }
        else
        {
            aboutMessage.setText(text);
        }

        return alertDialog;
    }
}
