/**
 * Created by Sambit Mohanty on 9/29/16.
 * This file contains scripts to connect and communicate with different nodes in WebSocket
 */

var webSocket, uuid, userId, orgId, orgChannel, profileName;
var connections = {};
var groupMembers = [];
var badgedChannels = [];

var sProtocole, wProtocole;
if (window.location.protocol == "http:") {
    sProtocole = "ws://";
    wProtocole = "http://"
} else {
    sProtocole = "wss://";
    wProtocole = "https://";
}
var host = window.location.hostname;
var port = (window.location.port == "") ? "" : (":" + window.location.port);
var socketURL = sProtocole + host + port + "/";
var webURL = wProtocole + host + port + "/";

$(function () {
    $("#chat-icon").on("click", function () {
        $.ajax({
            url: '/chat_panel',
            type: 'GET',
            success: function (res) {
                $("#overlay").show();
                $("#chat-panel").html(res).show();
                console.log("chat panel opened.");
            }
        });
        return false;
    });

    window.Notification.requestPermission(function () {
        console.log('Permissions state: ' + window.Notification.permission);
    });
});

function initializeWebSocket(channel, org, groups, badges) {
    console.log("=============================== Function initializeWebSocket ===============================");
    userId = channel;
    orgId = org;
    badgedChannels = badges.split(",");
    var ws = new WebSocket(socketURL + channel);
    console.log("Websocket initialized: " + ws.url);
    ws.onmessage = function (event) {
        console.log("xxxxxxxxxxxxxxxxxxxxxxxxxxxx Message Received xxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        console.log("Message received on individual channel (from initializeWebSocket function): " + event.data);
        displayChatMessage(event.data);
    };

    orgChannel = new WebSocket(socketURL + org);

    orgChannel.onopen = function () {
        var message = "true";
        message += "|~||~|" + userId;
        orgChannel.send(message);
    };

    orgChannel.onmessage = function (event) {
        console.log("xxxxxxxxxxxxxxxxxxxxxxxxxxxx Message Received xxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        console.log("Message received on Organization channel (from initializeWebSocket function): " + event.data);
        var res = JSON.parse(event.data);
        addOnlineToggleClass(res['sender'], res['message']);
        subscribeToGroup(res['uuid'], res['members']);
    };

    groups = groups.split(",").filter(function (v) {
        return (v !== '');
    });
    console.log("Total groups: " + groups);
    $.each(groups, function (index, value) {
        subscribeToGroup(value, userId);
    });

}

function subscribeChannel(channel) {
    console.log("=============================== Function subscribeChannel ===============================");
    if (webSocket) webSocket.close();
    webSocket = new WebSocket(socketURL + channel);
    webSocket.onmessage = function (event) {
        console.log("xxxxxxxxxxxxxxxxxxxxxxxxxxxx Message Received xxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        console.log("Message received on other member's Individual channel (from subscribeChannel function): " + event.data);
        displayChatMessage(event.data);
    };
}

function closeChat() {
    console.log("=============================== Function closeChat ===============================");
    $("#overlay").hide();
    $("#chat-panel").hide();
    resetLastChatActivity();
}

function resetLastChatActivity() {
    console.log("=============================== Function resetLastChatActivity ===============================");
    console.log(uuid);
    if ($.trim(uuid) == "") {
        return false;
    }
    $.ajax({
        url: '/reset_last_chat_activity',
        type: 'POST',
        data: {channel_id: uuid},
        success: function () {
            uuid = "";
        },
        error: function () {
        }
    });
}

function individualClick(liNode) {
    console.log("=============================== Function individualClick ===============================");
    var btnSendMessage = $("#send-message");
    $(".chat-loader").show();
    profileName = $(liNode).find(".pf-name").text();
    $(".top-header-pf-fname").text(profileName);
    $(".send-message").show();

    var channel = $(liNode).data('channel');
    console.log("channel: " + channel);
    btnSendMessage.data("channel", channel);
    btnSendMessage.data("msgType", 'individual');
    $("#chat-messages").html('');
    changeBadge(channel);
    //  Create unique channel identifier for this chat.
    $.ajax({
        url: '/create_channel',
        type: 'POST',
        data: {to: channel, type: 'individual'},
        success: function (res) {
            console.log("Create Channel response: " + JSON.stringify(res));
            uuid = res['channel'];
            badgedChannels = $.grep(badgedChannels, function (value) {
                return value != uuid;
            });
            $(liNode).data('uuid', uuid);
            $("#send-message").data('uuid', uuid);
            $("#chat-messages").data('uuid', uuid);
            $("#chat-body").show();
            subscribeChannel(channel);
            fetchHistory(res['channel']);
        },
        error: function () {
            $("#chat-messages").html('Unable to load chat window for this conversation.')
        }
    });
}

function groupClick(liNode) {
    console.log("=============================== Function groupClick ===============================");
    profileName = $(liNode).find(".pf-name").text();
    var channel = $(liNode).data('channel');
    uuid = channel;
    console.log(channel);
    var gid = $(liNode).data('gid');
    var btnSendMessage = $("#send-message");
    var txtChatMessage = $("#chat-messages");

    $(".chat-loader").show();
    $(".top-header-pf-fname").text(profileName);
    $("#ctrl-btns").html("<span data-channel='" + channel + "' data-gid='" + gid + "' onclick='showEditControls(this);'><i class='fa fa-pencil fa-lg'></i></span>");
    btnSendMessage.data("channel", channel);
    btnSendMessage.data('uuid', channel);
    btnSendMessage.data("msgType", 'group');
    $(".send-message").show();

    txtChatMessage.data('uuid', channel);
    txtChatMessage.html('');

    $(liNode).data('uuid', channel);
    $("#chat-body").show();
    displaGroupMembers(gid, "sample");
    fetchHistory(channel);
    changeBadge(channel);
    badgedChannels = $.grep(badgedChannels, function (value) {
        return value != channel;
    });
}

function showEditControls(inNode) {
    console.log("=============================== Function showEditControls ===============================");
    var channel = $(inNode).data('channel');
    var gid = $(inNode).data('gid');
    var ctrlBtn = "<span><i class='fa fa-check' data-channel='" + channel + "' data-gid='" + gid + "' onclick='updateGroupName(this);'></i></span>" +
        "<span><i class='fa fa-times' onclick='resetGroupName();'></i></span>";
    var textBox = "<input type='text' class='rename-group' value='" + profileName + "' />";

    $(".top-header-pf-fname").html(textBox);
    $("#ctrl-btns").html(ctrlBtn);

}

function resetGroupName() {
    console.log("=============================== Function resetGroupName ===============================");
    $(".top-header-pf-fname").html(profileName);
    $("#ctrl-btns").html("<span onclick='showEditControls();'><i class='fa fa-pencil fa-lg'></i></span>");
}

function updateGroupName(inNode) {
    console.log("=============================== Function updateGroupName ===============================");
    var groupName = $(".rename-group").val();
    var channel = $(inNode).data('channel');
    var groupId = $(inNode).data("gid");

    $.ajax({
        url: '/update_group_name',
        type: 'POST',
        data: {gid: groupId, name: groupName},
        success: function (res) {
            if (res.success) {
                profileName = groupName;
                $("#" + channel + "_online").find(".pf-name").html(groupName);
            }
            resetGroupName();
        }
    });
}

function fetchHistory(channel) {
    console.log("=============================== Function fetchHistory ===============================");
    $.ajax({
        url: '/chat_history',
        type: 'GET',
        data: {channel_id: channel, user_id: userId},
        success: function (res) {
            var html = "";
            var chatBody = $("#chat-messages");
            if (res.data.length > 0) {
                $.each(res.data, function (index, value) {
                    if (value["attachment_name"] == "") {
                        html += generateHTML(value["message"], value["timestamp"], value["sender"]);
                    }
                    else {
                        html += generateAttachmentHTML(value["message"], value["timestamp"], value["sender"], value["attachment_name"], value["attachment_type"]);
                    }
                });
                chatBody.html(html);
                chatBody.animate({scrollTop: chatBody.prop("scrollHeight")}, 0);
            } else {
                chatBody.html("<div class='default-chat-div'>No conversation found</div>")
            }
            $(".chat-loader").hide();
        },
        error: function () {
            $("#chat-messages").html('Unable to load chat history for this conversation.')
        }
    });
}

function displaGroupMembers(gid, listType) {
    console.log("=============================== Function displaGroupMembers ===============================");
    $.ajax({
        url: "/get_group_members/" + gid,
        type: 'GET',
        data: {list_type: listType},
        success: function (res) {
            if (listType == "sample") {
                $("#sample-group-members").html(res);
            }
            else {
                $(".group-members-popup").show();
                $("#all-group-members").html(res);
            }
        }
    });
}

function sendMessage(sendBtn) {
    console.log("=============================== Function sendMessage ===============================");
    var textArea = $("#message-text");
    if ($.trim(textArea.val()) == "") return false;
    var channel = $(sendBtn).data('channel');
    uuid = $(sendBtn).data('uuid');
    var msgType = $(sendBtn).data("msgType");
    console.log("Channel: " + channel + " and message type: " + msgType);
    if (channel == "") {
        return false;
    }
    var message = textArea.val();
    message += "|~|" + uuid + "|~|" + userId + "|~|" + channel + "|~||~|" + msgType;
    console.log("Message before send: " + message);
    if (msgType == "group") {
        connections[channel].send(message);
    }
    else {
        webSocket.send(message);
    }
    textArea.val('');
}

function sendAttachment(data) {
    console.log("=============================== Function sendAttachment ===============================");
    var sendBtn = $("#send-message");
    var channel = sendBtn.data('channel');
    uuid = sendBtn.data('uuid');
    var msgType = sendBtn.data("msgType");
    if (channel == "") {
        return false;
    }
    var message = data['url'];
    var attachment_id = data['id'];
    message += "|~|" + uuid + "|~|" + userId + "|~|" + channel + "|~||~|" + msgType + "|~|" + attachment_id;
    if (msgType == "group") {
        connections[channel].send(message);
    }
    else {
        webSocket.send(message);
    }
}

function sendMessageText(event) {
    console.log("=============================== Function sendMessageText ===============================");
    if (event.keyCode == 13) {
        console.log("Enter key pressed. Broadcasting message now.");
        $("#send-message").trigger("click");
        return false;
    }
    return true;
}

function generateHTML(message, timestamp, channel) {
    console.log("=============================== Function generateHTML ===============================");
    var html;
    if (channel == userId) {
        html = "<div class='sender-part'>\
                    <div class='pull-left reciver'>" +
            message +
            "<div class='time'>" + timestamp + "</div>\
        </div>\
        <div class='pull-right pf-image'>\
            <img src='/images/man.png' />\
        </div>\
        <div class='clearfix'></div>\
    </div>";
    } else {
        html = "<div class='recevier-part'>\
                    <div class='pull-left pf-image'>\
                        <img src='/images/man.png' />\
                    </div>\
                    <div class='pull-right sender'>" +
            message +
            "<div class='time'>" + timestamp + "</div>\
                    </div>\
                    <div class='clearfix'></div>\
                </div>";
    }

    return html;
}

function generateAttachmentHTML(message, timestamp, channel, name, attType) {
    console.log("=============================== Function generateAttachmentHTML ===============================");
    var html;
    var previewHtml = (attType.indexOf("image/") !== -1) ? "<img class='preview-image' src='" + message + "'>" : "<i class='fa fa-file-text fa-3x'></i>";

    if (channel == userId) {
        html = "<div class='sender-part'>\
                    <div class='pull-left reciver'>" +
            "<a href='" + message + "' download='" + name + "' target='_blank' title='Click to download or preview'>" +
            previewHtml + "<br>" + name + "</a>" +
            "<div class='time'>" + timestamp + "</div>\
        </div>\
        <div class='pull-right pf-image'>\
            <img src='/images/man.png' />\
        </div>\
        <div class='clearfix'></div>\
    </div>";
    } else {
        html = "<div class='recevier-part'>\
                    <div class='pull-left pf-image'>\
                        <img src='/images/man.png' />\
                    </div>\
                    <div class='pull-right sender'>" +
            "<a href='" + message + "' download='" + name + "' target='_blank' title='Click to download or preview'>" +
            previewHtml + "<br>" + name + "</a>" +
            "<div class='time'>" + timestamp + "</div>\
                    </div>\
                    <div class='clearfix'></div>\
                </div>";
    }

    return html;
}

function displayChatMessage(data) {
    console.log("=============================== Function displayChatMessage ===============================");
    var content = JSON.parse(data);
    console.log("Content: " + JSON.stringify(content));
    var chatBody = $("#chat-messages");
    if ((chatBody.data("uuid") == content['uuid']) && $("#chat-panel").is(":visible")) {
        console.log("Displaying chat message on chat board.");

        if (content["att_name"] != "") {
            chatBody.append(generateAttachmentHTML(content["message"], content["timestamp"], content["sender"], content["att_name"], content["att_type"]));
        }
        else {
            chatBody.append(generateHTML(content["message"], content["timestamp"], content["sender"]));
        }
        chatBody.animate({scrollTop: chatBody.prop("scrollHeight")}, 1000);
        chatBody.find(".default-chat-div").hide();
    } else if ((content["channel"] == userId) || (connections[content["channel"]] != null)) {
        console.log("Displaying message badge. Not on board.");
        displayBadge(((content["chat_type"] == 'group') ? content["uuid"] : content["sender"]), content['uuid']);
        displayTitleAlert();
        displayNotification(content["sender_name"], content["message"]);
    }
}

function displayNotification(title, body) {
    console.log("=============================== Function displayChatMessage ===============================");
    title += " says...";
    if (window.Notification.permission == "granted") {
        if (window.Notification) {
            console.log("For safari and chrome.");
            // Safari 6, Chrome (23+) /
            console.log('SC');
            var notification = new window.Notification(title, {
                // The notification's icon - For Chrome in Windows, Linux & Chrome OS /
                icon: 'http://localhost:3000/chat-icon.png',
                // The notification’s subtitle. /
                body: body,

                tag: 'this ia a tag'
            });

        } else if (window.webkitNotifications) {
            // FF with html5Notifications plugin installed /
            console.log('For FF browser');
            var notification = window.webkitNotifications.createNotification((webURL + "/chat-icon.png"), title, body);
            notification.show();
        } else if (navigator.mozNotification) {
            // Firefox Mobile /
            console.log('Firefox mobile');
            notification = navigator.mozNotification.createNotification(title, body, (webURL + "/chat-icon.png"));
            notification.show();
        } else if (window.external && window.external.msIsSiteMode()) {
            // IE9+ /
            console.log('IE Browser');

            //Clear any previous notifications
            window.external.msSiteModeClearIconOverlay();
            window.external.msSiteModeSetIconOverlay((webURL + "/chat-icon.png"), title);
            window.external.msSiteModeActivate();
        }

    }
}

function displayTitleAlert() {
    console.log("=============================== Function displayTitleAlert ===============================");
//  Title bar alert.
    $.titleAlert("New chat message!", {
        requireBlur: false,
        stopOnFocus: false,
        duration: 4000,
        interval: 700
    });
}

function displayBadge(channel, uuid) {
    console.log("=============================== Function displayBadge ===============================");
    var badge_channel = $("#" + channel + "_online");
    var chatBadge = badge_channel.find(".chat-badge");
    var chatIconBadge = $("#chat-icon-badge");
    var chatBadgeCount = chatBadge.html();
    var chatIconBadgeCount = chatIconBadge.html();

    console.log("chatBadgeCount: " + chatBadgeCount);
    console.log("chatIconBadgeCount: " + chatIconBadgeCount);
    if ($.inArray(uuid, badgedChannels) < 0) {
        badgedChannels.push(uuid);
        chatIconBadge.html(((parseInt(chatIconBadgeCount, 10) || 0) + 1)).show();
        console.log("Chat icon badge shown for channels: " + badgedChannels.join(", "));
    }

    chatBadge.show();
    chatBadge.html(((parseInt(chatBadgeCount, 10) || 0) + 1));
}

function changeBadge(channel) {
    console.log("=============================== Function changeBadge ===============================");
    var chatBadge = $("#" + channel + "_online").find(".chat-badge");
    var chatBadgeCount = $.trim(chatBadge.html());
    console.log("chatBadgeCount: " + chatBadgeCount);
    if (chatBadgeCount != "" && chatBadgeCount != "0") {
        var chatIconBadge = $("#chat-icon-badge");
        var chatIconBadgeCount = (parseInt($.trim(chatIconBadge.html()), 10) || 0);
        chatIconBadge.html(chatIconBadgeCount - 1);
        console.log("Chat icon badge count deducted by 1.");
    }
    chatBadge.html('').hide();
}

function addOnlineToggleClass(user, status) {
    console.log("=============================== Function addOnlineToggleClass ===============================");
    if (status === 'true') {
        $("#" + user + "_online").find("div > span").removeClass("bg-rnd-npf").addClass("bg-rnd-pf");
    } else {
        $("#" + user + "_online").find("div > span").removeClass("bg-rnd-pf").addClass("bg-rnd-npf");
    }
}

//  Remove online class.
function logoutFromChat() {
    var message = "false";
    message += "|~||~|" + userId;
    orgChannel.send(message);
}
//  Search existing users from chat window.

//  Create a pseudo expression "containsi" for case insensitive search.
$.expr[":"].containsi = $.expr.createPseudo(function (arg) {
    return function (elem) {
        return $(elem).text().toLowerCase().indexOf(arg.toLowerCase()) >= 0;
    };
});

//  Search users by user input.
function searchUsers(e, sel) {
    var txtSearch = $(e.target),
        searchQuery = $.trim(txtSearch.val());
    if (searchQuery.length > 0) {
        $("." + sel + " .individual:not(:containsi(" + searchQuery + "))").hide();
        $("." + sel + " .individual:containsi(" + searchQuery + ")").show();
    }
    else {
        $(".chat-people .individual").show();
    }
}
//  End Search


//  Group

function addToNewGroupMembers(liNode) {
    console.log("=============================== Function addToNewGroupMembers ===============================");
    var channel = $(liNode).data("channel");
    var chkArea = $("#chk_" + channel);

    if ($.inArray(channel, groupMembers) > -1) {
        groupMembers.splice($.inArray(channel, groupMembers), 1);
    }
    else {
        groupMembers.push(channel);
    }
    $("#group-members").val(groupMembers);

    $("#create-group").prop("disabled", (groupMembers.length == 0));
    chkArea.toggleClass("fa-check");
}

function createGroup() {
    console.log("=============================== Function createGroup ===============================");
    if (groupMembers.length == 0) return false;
    groupMembers.push(userId);
    $.ajax({
        url: '/create_channel',
        type: 'POST',
        data: {type: 'group', members: groupMembers.join(',')},
        success: function (res) {
            var message = "";
            message += "|~|" + res['channel'] + "|~|" + userId + "|~|" + res['receiver'] + "|~|" + groupMembers.join(',');
            console.log("Message broadcasted after creating a group: " + message);
            orgChannel.send(message);
            $("#group-tab").trigger("click");
            $("#create-group").prop("disabled", true);
            discardChanges();
        }
    });
}

function discardChanges() {
    console.log("=============================== Function discardChanges ===============================");
    groupMembers = [];
    $(".groupPopup").hide();
    $(".chk-group-member").removeClass("fa-check");
    $("#group-members").val('');
}

function showGroupChatPopup() {
    console.log("=============================== Function showGroupChatPopup ===============================");
    groupMembers = [];
    $(".groupPopup").show();
}

function subscribeToGroup(channel, users) {
    console.log("=============================== Function subscribeToGroup ===============================");
    users = users.split(",");
    if ($.inArray(userId, users) > -1) {
        var ws = new WebSocket(socketURL + channel);
        ws.onmessage = function (event) {
            console.log("xxxxxxxxxxxxxxxxxxxxxxxxxxxx Message Received xxxxxxxxxxxxxxxxxxxxxxxxxxxx");
            console.log("Message received on Group channel (from subscribeToGroup function): " + event.data);
            displayChatMessage(event.data);
        };
        connections[channel] = ws;
    }
}

//  Group tab click
function displaymembers(inputNode) {
    console.log("=============================== Function displaymembers ===============================");
    resetLastChatActivity();
    var id = $(inputNode).attr("id");
    var txtMessage = $("#chat-messages");
    txtMessage.data("uuid", "");
    var cnvType = "";
    if (id == 'all-tab') {
        cnvType = 'individual';
    }
    else if (id == 'group-tab') {
        cnvType = 'group';
    }
    else if (id == 'recent-tab') {
        cnvType = 'recent';
    }
    $.ajax({
        url: '/conversation_members/' + cnvType,
        type: 'GET',
        success: function (res) {
            $(".li-tabs").removeClass("active");
            $(inputNode).addClass("active");
            $(".top-header-pf-fname").html('');
            $("#ctrl-btns").html('');
            $("#sample-group-members").html('');
            $("#chat-people").html(res);
            txtMessage.find('.default-chat-div').html('');
            if (id == 'all-tab') {
                txtMessage.html("<div class='default-chat-div'>\
                            <p>Welcome to CRM4Beauty Chat</p>\
                            <p>Click on a member to start conversation</p>\
                        </div>");
            } else {
                txtMessage.html("<div class='default-chat-div'>\
                            <p>Welcome to CRM4Beauty Chat</p>\
                            <p>Click on a group to start conversation</p>\
                        </div>");
            }
        }
    });
}
