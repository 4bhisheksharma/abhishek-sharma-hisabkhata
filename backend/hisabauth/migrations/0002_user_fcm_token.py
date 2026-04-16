# Generated manually to add fcm_token field

from django.db import migrations, models


def _column_exists(connection, table_name, column_name):
    with connection.cursor() as cursor:
        description = connection.introspection.get_table_description(cursor, table_name)
    return any(col.name == column_name for col in description)


def add_fcm_token_if_missing(apps, schema_editor):
    user_model = apps.get_model('hisabauth', 'User')
    table_name = user_model._meta.db_table

    if _column_exists(schema_editor.connection, table_name, 'fcm_token'):
        return

    try:
        field = user_model._meta.get_field('fcm_token')
    except Exception:
        field = models.TextField(
            blank=True,
            null=True,
            help_text='Firebase Cloud Messaging token for push notifications',
        )
        field.set_attributes_from_name('fcm_token')

    schema_editor.add_field(user_model, field)


def remove_fcm_token_if_exists(apps, schema_editor):
    user_model = apps.get_model('hisabauth', 'User')
    table_name = user_model._meta.db_table

    if not _column_exists(schema_editor.connection, table_name, 'fcm_token'):
        return

    try:
        field = user_model._meta.get_field('fcm_token')
    except Exception:
        field = models.TextField(
            blank=True,
            null=True,
            help_text='Firebase Cloud Messaging token for push notifications',
        )
        field.set_attributes_from_name('fcm_token')

    schema_editor.remove_field(user_model, field)


class Migration(migrations.Migration):

    dependencies = [
        ('hisabauth', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(
            code=add_fcm_token_if_missing,
            reverse_code=remove_fcm_token_if_exists,
        ),
    ]
