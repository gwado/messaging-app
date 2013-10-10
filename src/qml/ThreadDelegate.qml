/*
 * Copyright 2012-2013 Canonical Ltd.
 *
 * This file is part of messaging-app.
 *
 * messaging-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * messaging-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Ubuntu.Telephony 0.1
import Ubuntu.Contacts 0.1
import QtContacts 5.0

ListItem.Empty {
    id: delegate
    property bool unknownContact: delegateHelper.isUnknown
    property bool selectionMode: false
    anchors.left: parent.left
    anchors.right: parent.right
    height: units.gu(10)

    // FIXME: the selected state should be handled by the UITK
    Rectangle {
        id: selectionIndicator
        visible: selectionMode
        height: parent.height
        anchors.right: parent.right
        anchors.top: parent.top
        width: visible ? units.gu(6) : 0
        color: "black"
        opacity: 0.2
    }
    Icon {
        visible: selectionIndicator.visible
        anchors.centerIn: selectionIndicator
        name: "select"
        height: units.gu(3)
        width: units.gu(3)
        color: selected ? "white" : "grey"
    }

    UbuntuShape {
        id: avatar
        height: units.gu(6)
        width: units.gu(6)
        radius: "medium"
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        image: Image {
            property bool defaultAvatar: unknownContact || delegateHelper.avatar === ""
            anchors.fill: parent
            fillMode: defaultAvatar ? Image.PreserveAspectFit : Image.PreserveAspectCrop
            source: defaultAvatar ? Qt.resolvedUrl("assets/contact_defaulticon.png") : delegateHelper.avatar
            asynchronous: true
        }
    }

    Label {
        id: contactName
        anchors {
            top: avatar.top
            left: avatar.right
            leftMargin: units.gu(2)
        }
        fontSize: "medium"
        text: unknownContact ? delegateHelper.phoneNumber : delegateHelper.alias
    }

    Label {
        id: time
        anchors {
            verticalCenter: contactName.verticalCenter
            right: selectionIndicator.left
            rightMargin: units.gu(3)
        }
        fontSize: "x-small"
        color: "white"
        text: Qt.formatDateTime(eventTimestamp,"hh:mm AP")
    }

    Label {
        id: phoneType
        anchors {
            top: contactName.bottom
            left: contactName.left
        }
        text: delegateHelper.phoneNumberSubTypeLabel
        color: "gray"
        fontSize: "x-small"
    }

    Label {
        id: latestMessage
        height: units.gu(3)
        anchors {
            top: phoneType.bottom
            topMargin: units.gu(0.5)
            left: phoneType.left
            right: selectionIndicator.left
            rightMargin: units.gu(3)
        }
        elide: Text.ElideRight
        maximumLineCount: 2
        fontSize: "small"
        wrapMode: Text.WordWrap
        text: eventTextMessage == undefined ? "" : eventTextMessage
        opacity: 0.2
    }
    onItemRemoved: {
        threadModel.removeThread(accountId, threadId, type)
    }

    Item {
        id: delegateHelper
        property alias phoneNumber: watcherInternal.phoneNumber
        property alias alias: watcherInternal.alias
        property alias avatar: watcherInternal.avatar
        property alias contactId: watcherInternal.contactId
        property alias subTypes: phoneDetail.subTypes
        property alias contexts: phoneDetail.contexts
        property alias isUnknown: watcherInternal.isUnknown
        property string phoneNumberSubTypeLabel: ""

        function updateSubTypeLabel() {
            phoneNumberSubTypeLabel = isUnknown ? "" : phoneTypeModel.get(phoneTypeModel.getTypeIndex(phoneDetail)).label
        }

        onSubTypesChanged: updateSubTypeLabel();
        onContextsChanged: updateSubTypeLabel();
        onIsUnknownChanged: updateSubTypeLabel();

        ContactWatcher {
            id: watcherInternal
            phoneNumber: participants[0]
        }

        PhoneNumber {
            id: phoneDetail
            contexts: watcherInternal.phoneNumberContexts
            subTypes: watcherInternal.phoneNumberSubTypes
        }

        ContactDetailPhoneNumberTypeModel {
            id: phoneTypeModel
        }
    }
}
