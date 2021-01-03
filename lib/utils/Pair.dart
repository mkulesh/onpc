/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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

import 'package:quiver/core.dart';

class Pair<T1, T2>
{
    // Returns the first item of the pair
    final T1 item1;

    // Returns the second item of the pair
    final T2 item2;

    // Creates a new pair value with the specified items.
    const Pair(this.item1, this.item2);

    // Create a new pair value with the specified list [items].
    factory Pair.fromList(List items) 
    {
        if (items.length != 2)
        {
            throw ArgumentError('items must have length 2');
        }

        return Pair<T1, T2>(items[0] as T1, items[1] as T2);
    }

    // Returns a pair with the first item set to the specified value.
    Pair<T1, T2> withItem1(T1 v)
    {
        return Pair<T1, T2>(v, item2);
    }

    // Returns a pair with the second item set to the specified value.
    Pair<T1, T2> withItem2(T2 v)
    {
        return Pair<T1, T2>(item1, v);
    }

    // Creates a [List] containing the items of this [Pair].
    //
    // The elements are in item order. The list is variable-length
    // if [growable] is true.
    List toList({bool growable = false})
    => List.from([item1, item2], growable: growable);

    @override
    String toString()
    => '[$item1, $item2]';

    @override
    bool operator ==(other)
    => other is Pair && other.item1 == item1 && other.item2 == item2;

    @override
    int get hashCode
    => hash2(item1.hashCode, item2.hashCode);
}