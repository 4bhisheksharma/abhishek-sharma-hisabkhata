# Generated manually to add fcm_token field

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hisabauth', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='fcm_token',
            field=models.TextField(blank=True, help_text='Firebase Cloud Messaging token for push notifications', null=True),
        ),
    ]
