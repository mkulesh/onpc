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
// @dart=2.9
import "../../constants/Strings.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";

enum PrivacyPolicyType
{
    NONE,
    ONKYO,
    GOOGLE,
    SUE
}

/*
 * Privacy Policy Status message
 */
class PrivacyPolicyStatusMsg extends ISCPMessage
{
    static const String CODE = "PPS";

    static const ExtEnum<PrivacyPolicyType> ValueEnum = ExtEnum<PrivacyPolicyType>([
        EnumItem.code(PrivacyPolicyType.NONE, "000", defValue: true),
        EnumItem.code(PrivacyPolicyType.ONKYO, "100",
            descrList: Strings.l_privacy_policy_onkyo),
        EnumItem.code(PrivacyPolicyType.GOOGLE, "010",
            descrList: Strings.l_privacy_policy_google),
        EnumItem.code(PrivacyPolicyType.SUE, "001",
            descrList: Strings.l_privacy_policy_sue)
    ]);

    PrivacyPolicyStatusMsg(EISCPMessage raw) : super(CODE, raw);

    PrivacyPolicyStatusMsg.output(PrivacyPolicyType key) :
            super.output(CODE, ValueEnum.valueByKey(key).code);

    bool isPolicySet(PrivacyPolicyType s)
    {
        if (getData.length < 3)
        {
            return false;
        }
        switch (s)
        {
            case PrivacyPolicyType.NONE:
                return getData == ValueEnum.defValue.code;
            case PrivacyPolicyType.ONKYO:
                return getData.substring(0, 1) == '1';
            case PrivacyPolicyType.GOOGLE:
                return getData.substring(1, 2) == '1';
            case PrivacyPolicyType.SUE:
                return getData.substring(2, 3) == '1';
        }
        return false;
    }

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
