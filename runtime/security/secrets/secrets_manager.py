import os
from typing import Optional, Dict


class SecretsManager:
    def __init__(self):
        self.demo_mode = True

    def get_secret(self, path: str) -> Optional[Dict]:
        return None


_secrets_manager: Optional[SecretsManager] = None


def get_secrets_manager() -> SecretsManager:
    global _secrets_manager

    if _secrets_manager is None:
        _secrets_manager = SecretsManager()

    return _secrets_manager
