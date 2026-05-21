import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 390
    height: 844
    title: "doneinlove"
    color: "#f5ede4"

    property string currentUserId: ""

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: loginPage
    }

    Component {
        id: loginPage
        LoginPage {
            onGoToSignup: stack.push(signupPage)
            onGoToForgotPassword: stack.push(forgotPasswordPage)
            onLoginSuccess: stack.replace(homePage)
        }
    }

    Component {
        id: forgotPasswordPage
        ForgotPasswordPage {
            onGoToLogin: stack.pop()
        }
    }

    Component {
        id: signupPage
        SignupPage {
            onGoToLogin: stack.pop()
            //onSignupSuccess: stack.replace(homePage)
            onSignupSuccess: console.log("signup — awaiting email confirmation")
        }
    }

    Component {
        id: homePage
        HomePage {
            userId: root.currentUserId
            onOpenMemories:  stack.push(memoriesPageOwn)
            onOpenInvitations: stack.push(invitationsPage)
            onOpenSettings:  stack.push(settingsPage)
            onOpenWill:      stack.push(willPage)
            onOpenFamily:    stack.push(familyPage)
            onOpenStory:     stack.push(storyPage)
            onOpenLegal:     stack.push(legalPage)
            onOpenUpdates:   stack.push(updatesPage)
        }
    }

    Component {
        id: aiChatPage
        AiChatPage {
            onGoBack: stack.pop()
        }
    }

    Component {
        id: memoriesPageOwn
        MemoriesPage {
            ownerId: root.currentUserId
            userId:  root.currentUserId
            onGoBack:      stack.pop()
            onGoToSettings: stack.push(settingsPage)
            onGoToFamily:   stack.push(familyPage)
            onOpenAiChat:   stack.push(aiChatPage)
        }
    }

    Component {
        id: memoriesPageGuest
        MemoriesPage {
            userId: root.currentUserId
            onGoBack: stack.pop()
            onGoToSettings: stack.push(settingsPage)
            onGoToFamily:   stack.push(familyPage)
        }
    }

    Component {
        id: invitationsPage
        InvitationsPage {
            userId: root.currentUserId
            onGoBack: stack.pop()
            onOpenMemories: function(ownerId) {
                stack.push(memoriesPageGuest, { "ownerId": ownerId })
            }
        }
    }

    Component {
        id: familyPage
        FamilyPage {
            userId: root.currentUserId
            onGoBack: stack.pop()
        }
    }

    Component {
        id: settingsPage
        SettingsPage {
            userId: root.currentUserId
            onGoBack: stack.pop()
            onSignedOut: {
                root.currentUserId = ""
                stack.replace(loginPage)
            }
        }
    }

    Component {
        id: willPage
        WillPage {
            userId: root.currentUserId
            onGoBack: stack.pop()
        }
    }

    Component {
        id: storyPage
        StoryPage { onGoBack: stack.pop() }
    }

    Component {
        id: legalPage
        LegalPage { onGoBack: stack.pop() }
    }

    Component {
        id: updatesPage
        UpdatesPage {
            onGoBack:    stack.pop()
            onGoToLegal: stack.push(legalPage)
        }
    }

    Component {
        id: resetPasswordPage
        ResetPasswordPage {
            onGoBack:    stack.pop()
            onGoToLogin: stack.replace(loginPage)
        }
    }

    Connections {
        target: Auth
        function onLoginSuccess(user)  { root.currentUserId = user.id }
        function onSignupSuccess(user) { root.currentUserId = user.id }
        function onSignoutDone()       { root.currentUserId = "" }
        function onAccountDeleted()    { root.currentUserId = "" }
        function onRecoverySessionReady() {
            // Session is now live; go straight to the password-reset form.
            // replace() so the user can't press Back into a half-authenticated state.
            stack.replace(resetPasswordPage)
        }
    }
}
