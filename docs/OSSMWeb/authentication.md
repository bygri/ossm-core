Authentication is very light-weight, using cookie-based sessions.

(This may need to be changed in future if cookies are found to be unreliable or too large)

An unauthenticated visitor enters their email and password in the login view.
If their credentials match, the following are set on the `session`:

    {
      "user_pk": 1,
      "auth_token": "token",
      "timezone": "Australia/Sydney",
      "language": "en-au",
      "clubs": [
        (1, "Leura FC"),
      ],
      "clubs_view_only": [],
      "active_club": 1,
      "teams_for_club": [
        (1, "Men's Team"),
      ],
      "active_team": 1,
      "comps_for_team": [
        (1, "NSW League"),
        (2, "NSW Cup"),
      ],
      "active_comp": 2
    }

On logout, the cookie is deleted.

Whenever the user changes clubs, teams, or comps, the relevant parts of the session
cookie also need to be updated.
