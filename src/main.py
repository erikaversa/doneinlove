import sys
from pathlib import Path
from urllib.parse import urlparse, parse_qs

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Slot, QTimer
from PySide6.QtNetwork import QLocalServer, QLocalSocket

from lib.error_capture import record
from services.auth_service import AuthWorker
from services.memorial_service import MemorialService
from services.crew_service import CrewService
from services.settings_service import SettingsService
from services.will_service import WillService
from services.chat_service import ChatService
from services.direct_chat_service import DirectChatService
from services.content_service import ContentService

sys.excepthook = lambda exc_type, exc_value, tb: record(exc_value)

_DEEP_LINK_SCHEME = "com.doneinlove.auth://"
_IPC_SERVER_NAME  = "doneinlove-auth"


def _parse_supabase_callback(url: str) -> tuple[str, str, str] | None:
    """
    Supabase email-link callbacks carry tokens in the URL fragment, e.g.:
      com.doneinlove.auth://login-callback/#access_token=X&refresh_token=Y&type=recovery
    Returns (access_token, refresh_token, type) or None if tokens are absent.
    """
    fragment = urlparse(url).fragment
    params   = parse_qs(fragment)
    access   = params.get("access_token",  [None])[0]
    refresh  = params.get("refresh_token", [None])[0]
    link_type = params.get("type", [""])[0]
    return (access, refresh, link_type) if access and refresh else None


class AuthBridge(QObject):
    loginSuccess         = Signal(dict)
    loginFailed          = Signal(str)
    signupSuccess        = Signal(dict)
    signupFailed         = Signal(str)
    signoutDone          = Signal()
    passwordResetSent    = Signal()
    passwordResetFailed  = Signal(str)
    recoverySessionReady = Signal()
    passwordUpdated      = Signal()
    passwordUpdateFailed = Signal(str)
    accountDeleted       = Signal()
    accountDeleteFailed  = Signal(str)

    def __init__(self):
        super().__init__()
        self._auth = AuthWorker()
        self._auth.loginSuccess.connect(self.loginSuccess)
        self._auth.loginFailed.connect(self.loginFailed)
        self._auth.signupSuccess.connect(self.signupSuccess)
        self._auth.signupFailed.connect(self.signupFailed)
        self._auth.signoutDone.connect(self.signoutDone)
        self._auth.passwordResetSent.connect(self.passwordResetSent)
        self._auth.passwordResetFailed.connect(self.passwordResetFailed)
        self._auth.recoverySessionReady.connect(self.recoverySessionReady)
        self._auth.passwordUpdated.connect(self.passwordUpdated)
        self._auth.passwordUpdateFailed.connect(self.passwordUpdateFailed)
        self._auth.accountDeleted.connect(self.accountDeleted)
        self._auth.accountDeleteFailed.connect(self.accountDeleteFailed)

    @Slot(str, str)
    def signIn(self, email: str, password: str) -> None:
        self._auth.sign_in(email, password)

    @Slot(str, str, str, str)
    def signUp(self, email: str, password: str,
               nickname: str, full_name: str) -> None:
        self._auth.sign_up(email, password, nickname, full_name)

    @Slot()
    def signOut(self) -> None:
        self._auth.sign_out()

    @Slot(str)
    def requestPasswordReset(self, email: str) -> None:
        self._auth.reset_password_for_email(email)

    @Slot(str)
    def updatePassword(self, new_password: str) -> None:
        self._auth.update_password(new_password)

    @Slot()
    def deleteAccount(self) -> None:
        self._auth.delete_account()

    @Slot(str, str)
    def setSession(self, access_token: str, refresh_token: str) -> None:
        self._auth.set_session(access_token, refresh_token)

    def handle_deep_link(self, url: str) -> None:
        parsed = _parse_supabase_callback(url)
        if not parsed:
            self.loginFailed.emit("Auth callback URL is missing tokens.")
            return
        access, refresh, link_type = parsed
        if link_type == "recovery":
            self._auth.set_recovery_session(access, refresh)
        else:
            self._auth.set_session(access, refresh)


def main():
    app = QGuiApplication(sys.argv)
    app.setApplicationName("doneinlove")

    incoming_url = sys.argv[1] if len(sys.argv) > 1 else None

    # If another instance is already running, forward the URL to it and quit.
    if incoming_url and incoming_url.startswith(_DEEP_LINK_SCHEME):
        sock = QLocalSocket()
        sock.connectToServer(_IPC_SERVER_NAME)
        if sock.waitForConnected(500):
            sock.write(incoming_url.encode())
            sock.waitForBytesWritten(500)
            sock.disconnectFromServer()
            sys.exit(0)

    # Primary instance: claim the IPC server so future launches can find us.
    QLocalServer.removeServer(_IPC_SERVER_NAME)
    ipc_server = QLocalServer()
    ipc_server.listen(_IPC_SERVER_NAME)

    engine = QQmlApplicationEngine()

    src_dir = Path(__file__).parent.resolve()
    qml_dir = src_dir / "qml"
    engine.addImportPath(str(qml_dir))

    auth = AuthBridge()
    engine.rootContext().setContextProperty("Auth", auth)

    memorial = MemorialService()
    engine.rootContext().setContextProperty("MemorialService", memorial)

    crew = CrewService()
    engine.rootContext().setContextProperty("CrewService", crew)

    settings = SettingsService()
    engine.rootContext().setContextProperty("SettingsService", settings)

    will = WillService()
    engine.rootContext().setContextProperty("WillService", will)

    chat = ChatService()
    engine.rootContext().setContextProperty("ChatService", chat)

    direct_chat = DirectChatService()
    engine.rootContext().setContextProperty("DirectChatService", direct_chat)

    content = ContentService()
    engine.rootContext().setContextProperty("ContentService", content)

    engine.load(str(qml_dir / "main.qml"))

    if not engine.rootObjects():
        print("ERROR: Could not load main.qml")
        sys.exit(1)

    # Handle a deep-link URL that arrived on first launch via sys.argv.
    if incoming_url and incoming_url.startswith(_DEEP_LINK_SCHEME):
        QTimer.singleShot(0, lambda: auth.handle_deep_link(incoming_url))

    # Handle URLs forwarded from later launches via the IPC socket.
    def _on_ipc_connection():
        conn = ipc_server.nextPendingConnection()
        conn.waitForReadyRead(500)
        url = conn.readAll().data().decode()
        conn.close()
        if url.startswith(_DEEP_LINK_SCHEME):
            auth.handle_deep_link(url)

    ipc_server.newConnection.connect(_on_ipc_connection)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
