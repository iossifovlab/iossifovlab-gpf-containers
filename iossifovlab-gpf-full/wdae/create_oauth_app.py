# To create the dev apps, run the following command:
# wdaemanage.py shell < create_oauth_app.py

import os
from oauth2_provider.models import get_application_model  # type: ignore
from django.contrib.auth import get_user_model

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "project.settings")

gpfjs_url = "https://gpf.sfari.org/hg19test"


User = get_user_model()
Application = get_application_model()

# on test instance the first admin user is Lubo with id=2
user = User.objects.get(id=2)  # Get admin user, should be the first one


new_application = Application(**{
    "name": "gpfjs dev app",
    "user_id": user.id,
    "client_type": "public",
    "authorization_grant_type": "authorization-code",
    "redirect_uris": f"{gpfjs_url}/datasets",
    "client_id": "gpfjs",
})
new_application.full_clean()
new_application.save()
