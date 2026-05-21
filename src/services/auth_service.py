import httpx
from PySide6.QtCore import QObject, Signal
from config import SUPABASE_URL
from lib.supabase_client import client as _supabase
from lib.worker import Worker


class AuthWorker(QObject):
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
        self._client = _supabase
        self._access_token: str | None = None
        self._running: set[Worker] = set()

    def _run(self, fn, on_result=None, on_error=None) -> None:
        w = Worker(fn)
        if on_result is not None:
            w.result.connect(on_result)
        if on_error is not None:
            w.error.connect(on_error)
        self._running.add(w)
        w.finished.connect(lambda: self._running.discard(w))
        w.start()

    def sign_in(self, email: str, password: str) -> None:
        def work():
            return self._client.auth.sign_in_with_password({
                "email": email, "password": password,
            })

        def on_ok(response):
            if response.user:
                self._access_token = response.session.access_token
                self.loginSuccess.emit({
                    "id":    response.user.id,
                    "email": response.user.email,
                })
            else:
                self.loginFailed.emit("Invalid email or password.")

        self._run(work, on_ok, self.loginFailed)

    def sign_up(self, email: str, password: str,
                nickname: str, full_name: str) -> None:
        def work():
            return self._client.auth.sign_up({
                "email": email,
                "password": password,
                "options": {
                    "data": {"nickname": nickname, "full_name": full_name},
                },
            })

        def on_ok(response):
            if response.user:
                if response.session:
                    self._access_token = response.session.access_token
                self.signupSuccess.emit({
                    "id":    response.user.id,
                    "email": response.user.email,
                })
            else:
                self.signupFailed.emit("Could not create account.")

        self._run(work, on_ok, self.signupFailed)

    def sign_out(self) -> None:
        def work():
            try:
                self._client.auth.sign_out()
            except Exception:
                pass

        def on_done(_):
            self._access_token = None
            self.signoutDone.emit()

        self._run(work, on_done)

    def update_password(self, new_password: str) -> None:
        def work():
            return self._client.auth.update_user({"password": new_password})

        def on_ok(response):
            if response.user:
                self.passwordUpdated.emit()
            else:
                self.passwordUpdateFailed.emit("Could not update password.")

        self._run(work, on_ok, self.passwordUpdateFailed)

    def reset_password_for_email(self, email: str) -> None:
        def work():
            return self._client.auth.reset_password_for_email(
                email,
                options={"redirect_to": "com.doneinlove.auth://reset-callback"},
            )

        def on_ok(_):
            self.passwordResetSent.emit()

        self._run(work, on_ok, self.passwordResetFailed)

    def set_recovery_session(self, access_token: str, refresh_token: str) -> None:
        """Establishes a Supabase session from a recovery deep link.
        Emits recoverySessionReady instead of loginSuccess so the UI
        navigates to the password-reset screen rather than home."""
        def work():
            return self._client.auth.set_session(access_token, refresh_token)

        def on_ok(response):
            if response.user:
                self._access_token = response.session.access_token
                self.recoverySessionReady.emit()
            else:
                self.loginFailed.emit("Could not verify reset link.")

        self._run(work, on_ok, self.loginFailed)

    def set_session(self, access_token: str, refresh_token: str) -> None:
        def work():
            return self._client.auth.set_session(access_token, refresh_token)

        def on_ok(response):
            if response.user:
                self._access_token = response.session.access_token
                self.loginSuccess.emit({
                    "id":    response.user.id,
                    "email": response.user.email,
                })
            else:
                self.loginFailed.emit("Session could not be established.")

        self._run(work, on_ok, self.loginFailed)

    def delete_account(self) -> None:
        if not self._access_token:
            self.accountDeleteFailed.emit("Not authenticated.")
            return
        token = self._access_token

        def work():
            response = httpx.post(
                f"{SUPABASE_URL}/functions/v1/delete-account",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json",
                },
            )
            if response.status_code != 200:
                raise RuntimeError(response.text)

        def on_done(_):
            self._access_token = None
            self.accountDeleted.emit()

        self._run(work, on_done, self.accountDeleteFailed)
