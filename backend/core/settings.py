from pathlib import Path
import os
from dotenv import load_dotenv
from datetime import timedelta

# Load env (for local)
load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent

firebase_admin_credential = os.getenv('FIREBASE_ADMIN_CREDENTIAL', '').strip()
if firebase_admin_credential:
    if os.path.isabs(firebase_admin_credential):
        FIREBASE_ADMIN_CREDENTIAL = firebase_admin_credential
    else:
        FIREBASE_ADMIN_CREDENTIAL = str((BASE_DIR / firebase_admin_credential).resolve())
else:
    FIREBASE_ADMIN_CREDENTIAL = str(BASE_DIR / 'core' / 'firebase-service-account.json')

# Preferred for production platforms (Render, etc.): one-line JSON
# or base64-encoded JSON service account payload.
FIREBASE_ADMIN_CREDENTIAL_JSON = os.getenv('FIREBASE_ADMIN_CREDENTIAL_JSON', '').strip()

# Alternative production format: split service account fields.
FIREBASE_PROJECT_ID = os.getenv('FIREBASE_PROJECT_ID', '').strip()
FIREBASE_PRIVATE_KEY_ID = os.getenv('FIREBASE_PRIVATE_KEY_ID', '').strip()
FIREBASE_PRIVATE_KEY = os.getenv('FIREBASE_PRIVATE_KEY', '').strip()
FIREBASE_CLIENT_EMAIL = os.getenv('FIREBASE_CLIENT_EMAIL', '').strip()
FIREBASE_CLIENT_ID = os.getenv('FIREBASE_CLIENT_ID', '').strip()

# ===== SECURITY =====

SECRET_KEY = os.getenv('SECRET_KEY', 'django-insecure-change-this')
DEBUG = os.getenv('DEBUG', 'True') == 'True'


def _normalize_host(host_value: str) -> str:
    host_value = host_value.strip()
    if not host_value:
        return ''
    if '://' in host_value:
        host_value = host_value.split('://', 1)[1]
    return host_value.split('/', 1)[0].strip()


def _normalize_origin(origin_value: str) -> str:
    origin_value = origin_value.strip().rstrip('/')
    if not origin_value:
        return ''
    if '://' not in origin_value:
        normalized_host = _normalize_host(origin_value)
        return f"https://{normalized_host}" if normalized_host else ''
    scheme, host_part = origin_value.split('://', 1)
    normalized_host = _normalize_host(host_part)
    return f"{scheme.lower()}://{normalized_host}" if normalized_host else ''


def _parse_csv(value: str):
    return [item.strip() for item in value.split(',') if item.strip()]


default_production_hosts = [
    'btwitsabhishek.me',
    'abhishek-sharma-hisabkhata.onrender.com',
]

env_hosts = [_normalize_host(host) for host in _parse_csv(os.getenv('ALLOWED_HOSTS', ''))]

env_csrf_origins = [
    normalized
    for normalized in (_normalize_origin(origin) for origin in _parse_csv(os.getenv('CSRF_TRUSTED_ORIGINS', '')))
    if normalized
]

default_production_origins = [f"https://{host}" for host in default_production_hosts]
local_csrf_origins = ['http://127.0.0.1:8000', 'http://localhost:8000']

# Allowed hosts
if DEBUG:
    # Local development
    ALLOWED_HOSTS = ['*']
    CSRF_TRUSTED_ORIGINS = list(dict.fromkeys(local_csrf_origins + default_production_origins + env_csrf_origins))
else:
    # Production
    ALLOWED_HOSTS = list(dict.fromkeys(default_production_hosts + env_hosts))
    host_based_origins = [f"https://{host}" for host in ALLOWED_HOSTS]
    CSRF_TRUSTED_ORIGINS = list(dict.fromkeys(host_based_origins + env_csrf_origins))

# ===== APPS =====  

INSTALLED_APPS = [
    "daphne",

    # Project apps
    'customer_dashboard',
    'hisabauth',
    'business_dashboard',
    'otp_verification',
    'request',
    'notification',
    'transaction',
    'support_ticket',
    'analytics',
    'realtime_chat',
    'hybrid_switch',

    # Django default
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party
    'rest_framework',
    'rest_framework.authtoken',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'channels',
]

AUTH_USER_MODEL = 'hisabauth.User'

# ===== MIDDLEWARE =====

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # serve static
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# ===== CORE =====

ROOT_URLCONF = 'core.urls'
WSGI_APPLICATION = 'core.wsgi.application'
ASGI_APPLICATION = 'core.asgi.application'

# ===== TEMPLATES =====

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# ===== DATABASE =====

if os.getenv("DATABASE_URL"):
    import dj_database_url
    DATABASES = {
        'default': dj_database_url.parse(os.getenv("DATABASE_URL"))
    }
else:
    # local db
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# ===== CHANNELS =====

if os.getenv("REDIS_URL"):
    # production (Redis)
    CHANNEL_LAYERS = {
        "default": {
            "BACKEND": "channels_redis.core.RedisChannelLayer",
            "CONFIG": {
                "hosts": [os.getenv("REDIS_URL")],
            },
        },
    }
else:
    # local (no Redis)
    CHANNEL_LAYERS = {
        "default": {
            "BACKEND": "channels.layers.InMemoryChannelLayer"
        }
    }

# ===== AUTH =====

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# ===== I18N =====

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'

USE_I18N = True
USE_TZ = True

# ===== STATIC / MEDIA =====

STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# compress static files
STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# ===== EMAIL =====

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True

EMAIL_HOST_USER = os.getenv('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = os.getenv('EMAIL_HOST_PASSWORD')

DEFAULT_FROM_EMAIL = EMAIL_HOST_USER

# ===== API =====

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}

# ===== JWT =====

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=7),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'user_id',
    'USER_ID_CLAIM': 'user_id',
}

# ===== DEFAULT =====

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'