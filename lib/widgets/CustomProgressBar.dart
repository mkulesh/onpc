/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import 'dart:math';

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import 'CustomTextLabel.dart';

typedef CaptionCallback = String Function(double);
typedef NewValueCallback = void Function(int);

class CustomProgressBar extends StatefulWidget
{
    final String caption;
    final String minValueStr, maxValueStr;
    final int maxValueNum, currValue;
    final CaptionCallback onCaption;
    final NewValueCallback onChanged;

    CustomProgressBar({this.caption, this.minValueStr, this.maxValueStr, this.maxValueNum, this.currValue, this.onCaption, this.onChanged});

    @override _CustomProgressBarState createState()
    => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar>
{
    static const int DEF_VALUE = -99999;

    bool isSeeking = false;
    int _newSeekValue = DEF_VALUE;
    int _currValue = DEF_VALUE;

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        double currValue;
        if (_currValue != DEF_VALUE && _currValue != widget.currValue)
        {
            // End of sliding
            // requested to use new widget.currValue when it is changed
            _newSeekValue = DEF_VALUE;
            _currValue = DEF_VALUE;
            currValue = widget.currValue.toDouble();
        }
        else if (_newSeekValue != DEF_VALUE)
        {
            // within the sliding
            currValue = _newSeekValue.toDouble();
        }
        else
        {
            // normal update of widget.currValue
            //Logging.info(this, "build normal update of widget.currValue");
            currValue = widget.currValue.toDouble();
        }

        final List<Widget> controls = List<Widget>();
        if (widget.caption != null)
        {
            String caption = widget.caption;
            if (widget.onCaption != null)
            {
                caption += ": " + widget.onCaption(currValue);
            }
            controls.add(CustomTextLabel.small(caption));
        }

        final double minV = 0.0;
        final double maxV = widget.maxValueNum.toDouble();

        final Widget slider = SliderTheme(
            data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                thumbColor: td.accentColor,
                activeTrackColor: td.accentColor,
                inactiveTrackColor: td.disabledColor.withAlpha(125)),
            child: Slider(
                min: minV,
                max: maxV,
                value: min(max(currValue, minV), maxV),
                onChangeStart: widget.onChanged != null ? _onChangeStart : null,
                onChanged: widget.onChanged != null ? _onChanged : null,
                onChangeEnd: widget.onChanged != null ? _onChangeEnd : null)
        );

        controls.add(Row(
            mainAxisSize: MainAxisSize.max,
            children: [
                CustomTextLabel.small(widget.minValueStr, textAlign: TextAlign.left),
                Expanded(child: slider),
                CustomTextLabel.small(widget.maxValueStr, textAlign: TextAlign.right)
            ]
        ));

        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controls);
    }

    _onChangeStart (double v)
    {
        isSeeking = true;
        setState(()
        {
            _newSeekValue = v.round();
            _currValue = DEF_VALUE;
        });
    }

    _onChanged (double v)
    {
        isSeeking = true;
        setState(()
        {
            _newSeekValue = v.round();
        });
    }

    _onChangeEnd (double v)
    {
        isSeeking = false;
        setState(()
        {
            _newSeekValue = v.round();
            // onChangeEnd is sometime called twice: at the seeking start and at the seeking end.
            // In order to avoid the message sending on the first unexpected call of the onChangeEnd,
            // we delay this message sending and observe whether the seeking is really finished
            Future.delayed(Duration(milliseconds: 100)).whenComplete(()
            {
                if (widget.onChanged != null && !isSeeking)
                {
                    widget.onChanged(_newSeekValue);
                }
            });
            // requested to use new widget.currValue on next build
            _currValue = widget.currValue;
        });
    }
}