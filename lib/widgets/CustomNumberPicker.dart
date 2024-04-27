/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../utils/Convert.dart";
import "CustomTextLabel.dart";

enum PickerAction
{
    DECREASE, INCREASE
}

class CustomNumberPicker extends StatefulWidget
{
    final Function(int) onValue;
    final int maxValue;
    final int minValue;
    final int initialValue;
    final int step;

    CustomNumberPicker({Key? key,
        required this.onValue,
        required this.initialValue,
        required this.maxValue,
        required this.minValue,
        required this.step})
        : super(key: key);

    @override
    _CustomNumberPickerState createState()
    => _CustomNumberPickerState();
}

class _CustomNumberPickerState extends State<CustomNumberPicker>
{
    int _initialValue = 0;
    Timer? _timer;

    @override
    void initState()
    {
        super.initState();
        _initialValue = widget.initialValue;
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        final RoundedRectangleBorder shape = RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0)),
            side: BorderSide(width: 0.3, color: td.disabledColor));

        return Card(
            shadowColor: Colors.transparent,
            elevation: 0.0,
            semanticContainer: true,
            color: Colors.transparent,
            shape: shape,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    GestureDetector(
                        onTap: _decrease,
                        onTapDown: (details)
                        {
                            _onLongPress(PickerAction.DECREASE);
                        },
                        onTapUp: (details)
                        {
                            if (_timer != null)
                            {
                                _timer!.cancel();
                            }
                        },
                        onTapCancel: ()
                        {
                            if (_timer != null)
                            {
                                _timer!.cancel();
                            }
                        },
                        child: Padding(
                            padding: ButtonDimens.imgButtonPadding,
                            child: SvgPicture.asset(
                                Drawables.numeric_negative_1,
                                height: ButtonDimens.smallButtonSize,
                                colorFilter: Convert.toColorFilter(td.disabledColor),
                            ),
                        ),
                    ),
                    CustomTextLabel.normal(_initialValue.toString()),
                    GestureDetector(
                        onTap: _increase,
                        onTapDown: (details)
                        {
                            _onLongPress(PickerAction.INCREASE);
                        },
                        onTapUp: (details)
                        {
                            if (_timer != null)
                            {
                                _timer!.cancel();
                            }
                        },
                        onTapCancel: ()
                        {
                            if (_timer != null)
                            {
                                _timer!.cancel();
                            }
                        },
                        child: Padding(
                            padding: ButtonDimens.imgButtonPadding,
                            child: SvgPicture.asset(
                                Drawables.numeric_positive_1,
                                height: ButtonDimens.smallButtonSize,
                                colorFilter: Convert.toColorFilter(td.disabledColor),
                            ),
                        ),
                    )
                ],
            ),
        );
    }

    void _decrease()
    {
        if (_canDoAction(PickerAction.DECREASE))
        {
            setState(()
            {
                _initialValue -= widget.step;
            });
        }
        widget.onValue(_initialValue);
    }

    void _increase()
    {
        if (_canDoAction(PickerAction.INCREASE))
        {
            setState(()
            {
                _initialValue += widget.step;
            });
        }
        widget.onValue(_initialValue);
    }

    void _onLongPress(PickerAction action)
    {
        final Timer timer = Timer.periodic(Duration(milliseconds: 300), (t)
        {
            action == PickerAction.DECREASE ? _decrease() : _increase();
        });
        setState(()
        {
            _timer = timer;
        });
    }

    bool _canDoAction(PickerAction action)
    {
        if (action == PickerAction.DECREASE)
        {
            return _initialValue - widget.step >= widget.minValue;
        }
        if (action == PickerAction.INCREASE)
        {
            return _initialValue + widget.step <= widget.maxValue;
        }
        return false;
    }
}
