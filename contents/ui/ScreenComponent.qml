import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: screenItem
    visible: false
    smooth: false
    antialiasing: false

    property alias desktopsBarRepeater: desktopsBarRepeater
    property alias bigDesktopsRepeater: bigDesktopsRepeater
    property alias desktopBackground: desktopBackground

    property int desktopsBarHeight: Math.round(height / 6) // valid only if position of desktopsBar is top or bottom
    property int desktopsBarWidth: Math.round(width / 6) // valid only if position of desktopsBar is left or right
    property real ratio: width / height

    property int screenIndex: model.index

    PlasmaCore.WindowThumbnail {
        id: desktopBackground
        anchors.fill: parent
        visible: winId !== 0
        opacity: mainWindow.configBlurBackground ? 0 : 1
    }

    FastBlur {
        id: blurBackground
        anchors.fill: parent
        source: desktopBackground
        radius: 64
        visible: desktopBackground.winId !== 0 && mainWindow.configBlurBackground
        cached: true
    }

    ScrollView {
        id: desktopsBar

        background: Rectangle {
        id: desktopsBarBackground
            anchors.fill: parent
        color: "black"
        opacity: 0.1
        visible: mainWindow.configShowDesktopsBarBackground
    }

        states: [
            State {
                when: mainWindow.horizontalDesktopsLayout
                PropertyChanges {
                    target: desktopsBar
                    height: desktopsBarHeight
                }
                AnchorChanges {
                    target: desktopsBar
                    anchors.bottom: mainWindow.configDesktopsBarPlacement === Enums.Position.Top ? bigDesktops.top : undefined
                    anchors.top: mainWindow.configDesktopsBarPlacement === Enums.Position.Bottom ? bigDesktops.bottom : undefined
                    anchors.left: screenItem.left
                    anchors.right: screenItem.right
                }
                PropertyChanges {
                    target: desktopsWrapper
                    columns: desktopsBarRepeater.count
                    rows: 1
                    leftPadding: mainWindow.desktopBarSpacing
                    rightPadding: mainWindow.desktopBarSpacing
                }
            },
            State {
                when: !mainWindow.horizontalDesktopsLayout
                PropertyChanges {
                    target: desktopsBar
                    width: desktopsBarWidth
                }
                AnchorChanges {
                    target: desktopsBar
                    anchors.bottom: screenItem.bottom
                    anchors.top: screenItem.top
                    anchors.left: mainWindow.configDesktopsBarPlacement === Enums.Position.Right ? bigDesktops.right : undefined
                    anchors.right: mainWindow.configDesktopsBarPlacement === Enums.Position.Left ? bigDesktops.left : undefined
                }
                PropertyChanges {
                    target: desktopsWrapper
                    columns: 1
                    rows: desktopsBarRepeater.count
                    topPadding: mainWindow.desktopBarSpacing
                    bottomPadding: mainWindow.desktopBarSpacing
                }
            }
        ]

        Grid {
            id: desktopsWrapper
            spacing: mainWindow.desktopBarSpacing
            // anchors.centerIn: parent // <== don't know why but this doesn't work here
            x: desktopsBar.width < desktopsWrapper.width ? 0 : (desktopsBar.width - desktopsWrapper.width) / 2
            y: desktopsBar.height < desktopsWrapper.height ? 0 : (desktopsBar.height - desktopsWrapper.height) / 2

            Repeater {
                id: desktopsBarRepeater
                model: mainWindow.workWithActivities ? workspace.activities.length : workspace.desktops

                DesktopComponent {
                    id: smallDesktop
                    activity: mainWindow.workWithActivities ? workspace.activities[model.index] : ""

                    states: [
                        State {
                            when: mainWindow.horizontalDesktopsLayout
                            PropertyChanges {
                                target: smallDesktop
                                width: (smallDesktop.height / screenItem.height) * screenItem.width
                                height: desktopsBar.height - mainWindow.desktopBarSpacing * 2
                            }
                        },
                        State {
                            when: !mainWindow.horizontalDesktopsLayout
                            PropertyChanges {
                                target: smallDesktop
                                width: desktopsBar.width - mainWindow.desktopBarSpacing * 2
                                height: (smallDesktop.width / screenItem.width) * screenItem.height
                            }
                        }
                    ]

                    TapHandler {
                        acceptedButtons: Qt.AllButtons
                        onTapped: {
                            switch (eventPoint.event.button) {
                                case Qt.LeftButton:
                            if (workspace.currentDesktop === model.index + 1)
                                mainWindow.toggleActive();
                            else
                                workspace.currentDesktop = model.index + 1;
                                    break;
                                case Qt.MiddleButton:
                                    mainWindow.selectedClientItem.client.closeWindow();
                                    break;
                                case Qt.RightButton:
                                    if (mainWindow.workWithActivities)
                                        if (mainWindow.selectedClientItem.client.activities.length === 0)
                                            mainWindow.selectedClientItem.client.activities.push(workspace.activities[model.index]);
                                        else
                                            mainWindow.selectedClientItem.client.activities = [];
                                    else
                                        if (mainWindow.selectedClientItem.client.desktop === -1)
                                            mainWindow.selectedClientItem.client.desktop = model.index + 1;
                                        else
                                            mainWindow.selectedClientItem.client.desktop = -1;
                                    break;
                            }
                        }
                    }
                }
            }
        }
    }

    SwipeView {
        id: bigDesktops
        anchors.fill: parent
        currentIndex: mainWindow.currentActivityOrDesktop
        orientation: mainWindow.horizontalDesktopsLayout ? Qt.Horizontal : Qt.Vertical

        Behavior on anchors.topMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation

            NumberAnimation {
                duration: mainWindow.configAnimationsDuration
                easing.type: mainWindow.easingType

                onRunningChanged: {
                    mainWindow.animating = running;

                    if (!running && mainWindow.activated && mainWindow.easingType === Easing.InExpo) {
                        mainWindow.deactivate();
                    }
                }  
            }
        }

        Behavior on anchors.bottomMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation

            NumberAnimation {
                duration: mainWindow.configAnimationsDuration
                easing.type: mainWindow.easingType

                onRunningChanged: {
                    mainWindow.animating = running;

                    if (!running && mainWindow.activated && mainWindow.easingType === Easing.InExpo) {
                        mainWindow.deactivate();
                    }
                }   
            }
        }

        Behavior on anchors.leftMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation

            NumberAnimation {
                duration: mainWindow.configAnimationsDuration
                easing.type: mainWindow.easingType

                onRunningChanged: {
                    mainWindow.animating = running;

                    if (!running && mainWindow.activated && mainWindow.easingType === Easing.InExpo) {
                        mainWindow.deactivate();
                    }
                }
            }
        }

        Behavior on anchors.rightMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation

            NumberAnimation {
                duration: mainWindow.configAnimationsDuration
                easing.type: mainWindow.easingType

                onRunningChanged: {
                    mainWindow.animating = running;

                    if (!running && mainWindow.activated && mainWindow.easingType === Easing.InExpo) {
                        mainWindow.deactivate();
                    }
                }
            }
        }

        Repeater {
            id: bigDesktopsRepeater
            model: mainWindow.workWithActivities ? workspace.activities.length : workspace.desktops

            Item { // Cannot set geometry of SwipeView's root item
                property alias bigDesktop: bigDesktop

                TapHandler {
                    acceptedButtons: Qt.AllButtons

                    onTapped: {
                        if (mainWindow.selectedClientItem)
                            switch (eventPoint.event.button) {
                                case Qt.LeftButton:
                                    mainWindow.toggleActive();
                                    break;
                                case Qt.MiddleButton:
                                    mainWindow.selectedClientItem.client.closeWindow();
                                    break;
                                case Qt.RightButton:
                                    if (mainWindow.workWithActivities)
                                        if (mainWindow.selectedClientItem.client.activities.length === 0)
                                            mainWindow.selectedClientItem.client.activities.push(workspace.activities[model.index]);
                                        else
                                            mainWindow.selectedClientItem.client.activities = [];
                                    else
                                        if (mainWindow.selectedClientItem.client.desktop === -1)
                                            mainWindow.selectedClientItem.client.desktop = model.index + 1;
                                        else
                                            mainWindow.selectedClientItem.client.desktop = -1;
                                    break;
                            }
                        else 
                            mainWindow.toggleActive();
                    }
                }

                DesktopComponent {
                    id: bigDesktop
                    visible: model.index === mainWindow.currentActivityOrDesktop
                    big: true
                    activity: mainWindow.workWithActivities ? workspace.activities[model.index] : ""
                    anchors.centerIn: parent
                    width: desktopRatio < ratio ? parent.width - mainWindow.bigDesktopMargin
                            : parent.height / screenItem.height * screenItem.width - mainWindow.bigDesktopMargin
                    height: desktopRatio > ratio ? parent.height - mainWindow.bigDesktopMargin
                            : parent.width / screenItem.width * screenItem.height - mainWindow.bigDesktopMargin

                    property real desktopRatio: parent.width / parent.height
                }
            }
        }

        onCurrentIndexChanged: {
            mainWindow.workWithActivities ? workspace.currentActivity = workspace.activities[currentIndex]
                    : workspace.currentDesktop = currentIndex + 1;
        }
    }

    function showDesktopsBar() {
        switch (mainWindow.configDesktopsBarPlacement) {
            case Enums.Position.Top:
                bigDesktops.anchors.topMargin = desktopsBarHeight;
                break;
            case Enums.Position.Bottom:
                bigDesktops.anchors.bottomMargin = desktopsBarHeight;
                break;
            case Enums.Position.Left:
                bigDesktops.anchors.leftMargin = desktopsBarWidth;
                break;
            case Enums.Position.Right:
                bigDesktops.anchors.rightMargin = desktopsBarWidth;
                break;
        }
    }

    function hideDesktopsBar() {
        bigDesktops.anchors.topMargin = 0;
        bigDesktops.anchors.bottomMargin = 0;
        bigDesktops.anchors.leftMargin = 0;
        bigDesktops.anchors.rightMargin = 0;
    }

    function updateDesktopWindowId() {
        const clients = workspace.clientList(); 
        for (let i = 0; i < clients.length; i++) {
            if (clients[i].desktopWindow && clients[i].screen === screenIndex) {
                desktopBackground.winId = clients[i].windowId;
                return;
            }
        }
    }

    Component.onCompleted: {
        updateDesktopWindowId();
    }
}