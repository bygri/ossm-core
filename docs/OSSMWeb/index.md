[TOC]

## /

Welcome page. Includes login form.


## /user/signup/

GET: Show the user signup form.

POST: Process the user signup form.


## /user/verify/

GET (with no query params): Explain that email verification is required.


## /user/verify/?code=[verificationCode]&pk=[userPk]

GET: Attempt to verify the user.


## /user/login/

GET: Show the login form.

POST: Process the login form.


## /user/logout/

GET: Log out the user.


## /user/change_password/

`auth-required`

GET: Show the password change form.

POST: Process password change.


## /user/forgot_password/

GET: Show the forgot password page.

POST: Commence forgot password process.


## /user/forgot_password/?code=[verificationCode]&pk=[userPk]

GET: Show the enter-new-password form.

POST: Process the enter-new-password form.


## /user/api/

`auth-required`

GET: Show the user's API token.

POST: Perform a custom action (currently just reset token).


## /user/

`auth-required`

GET: Show logged in user's profile.


## /user/:pk/

`auth-required`

GET: Show specified user profile info, or redirect to /user/ if own profile.


## /user/edit/

`auth-required`

GET: Show user profile edit form.

POST: Process user profile edit form.
