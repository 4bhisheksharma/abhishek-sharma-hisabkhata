from django.apps import AppConfig


class RealtimeChatConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'realtime_chat'

    def ready(self):
        import realtime_chat.signals  # noqa
