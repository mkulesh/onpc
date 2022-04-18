/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
// @dart=2.9
import 'dart:math';

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "CustomTextLabel.dart";

typedef CaptionCallback = String Function(double);
typedef NewValueCallback = void Function(int);

class CustomProgressBar extends StatefulWidget
{
    final String caption;
    final String minValueStr, maxValueStr;
    final int maxValueNum, currValue;
    final CaptionCallback onCaption;
    final NewValueCallback onMoving;
    final NewValueCallback onChanged;
    final Widget extendedCmd;
    final int divisions;

    CustomProgressBar({
        this.caption,
        this.minValueStr,
        this.maxValueStr,
        this.maxValueNum,
        this.currValue,
        this.onCaption,
        this.onMoving,
        this.onChanged,
        this.extendedCmd,
        this.divisions = 0
    });

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

        final String extCaption = widget.onCaption != null ? widget.onCaption(currValue) : "";
        final List<Widget> controls = [];
        if (widget.caption != null)
        {
            final String caption = widget.caption + ": " + extCaption;
            if (widget.extendedCmd != null)
            {
                controls.add(Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [CustomTextLabel.small(caption), widget.extendedCmd],
                ));
            }
            else
            {
                controls.add(Container(
                    constraints: BoxConstraints(maxHeight: ButtonDimens.smallButtonSize),
                    child: Align(alignment: Alignment.centerLeft, child: CustomTextLabel.small(caption))
                ));
            }
        }

        final double radius = ActivityDimens.progressBarRadius;
        final double minV = 0.0;
        final double maxV = widget.maxValueNum.toDouble();

        final Widget slider = SliderTheme(
            data: SliderTheme.of(context).copyWith(
                trackShape: CustomTrackShape(),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: radius),
                thumbColor: td.accentColor,
                activeTrackColor: td.accentColor,
                inactiveTrackColor: td.disabledColor.withAlpha(125),
                activeTickMarkColor: td.disabledColor,
                inactiveTickMarkColor: td.disabledColor),
            child: Slider(
                min: minV,
                max: maxV,
                divisions: widget.divisions > 0 ? widget.divisions : null,
                value: min(max(currValue, minV), maxV),
                onChangeStart: widget.onChanged != null ? _onChangeStart : null,
                onChanged: widget.onChanged != null ? _onChanged : null,
                onChangeEnd: widget.onChanged != null ? _onChangeEnd : null)
        );

        final Widget sliderBox = Container(
            constraints: BoxConstraints(maxHeight: ActivityDimens.progressBarHeight),
            padding: EdgeInsets.symmetric(horizontal: 2.0 * radius),
            child: Align(alignment: Alignment.center, child: slider)
        );

        controls.add(Row(
            mainAxisSize: MainAxisSize.max,
            children: [
                CustomTextLabel.small(widget.minValueStr, textAlign: TextAlign.left),
                Expanded(child: sliderBox),
                CustomTextLabel.small(widget.maxValueStr, textAlign: TextAlign.right)
            ]
        ));

        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controls);
    }

    void _onChangeStart(double v)
    {
        isSeeking = true;
        setState(()
        {
            _newSeekValue = v.round();
            _currValue = DEF_VALUE;
        });
    }

    void _onChanged(double v)
    {
        isSeeking = true;
        final int intVal = v.round();
        if (intVal != _newSeekValue && widget.onMoving != null)
        {
            widget.onMoving(intVal);
        }
        setState(()
        {
            _newSeekValue = intVal;
        });
    }

    void _onChangeEnd(double v)
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

// See https://github.com/flutter/flutter/issues/37057 for more details
class CustomTrackShape extends RoundedRectSliderTrackShape
{
    @override
    Rect getPreferredRect({
        @required RenderBox parentBox,
        Offset offset = Offset.zero,
        @required SliderThemeData sliderTheme,
        bool isEnabled = false,
        bool isDiscrete = false,
    })
    {
        final double trackHeight = 1.5;
        final double trackLeft = offset.dx;
        final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
        final double trackWidth = parentBox.size.width;
        return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
    }
}