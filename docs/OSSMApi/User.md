[TOC]

## /user/:pkInt [GET]

`auth-token-required`
Return details for an active User. If the User requested is the same as the one authenticated, the additional
details will be returned.

### Returns

- `200` A User structure.

    Example response:
    
        {
          "pk": 1,
          "isActive": true,
          "accessLevel": 1,
          "nickname": "user",
          "timezoneName": "Australia/Sydney",
          "language": "en-au",
          "dateCreated": "2016-01-01 00:00:00+0000",
          "lastLogin": "2016-01-01 00:00:00+0000"
        }
    
    Example response if returning own details:
    
        {
          "pk": 1,
          "email": "user@email.com",
          "authToken": "ABCDEF",
          "verificationCode": nil,
          "isActive": true,
          "accessLevel": 1,
          "nickname": "user",
          "timezoneName": "Australia/Sydney",
          "language": "en-au",
          "dateCreated": "2016-01-01 00:00:00+0000",
          "lastLogin": "2016-01-01 00:00:00+0000"
        }

- `404` The User was not found, or is inactive.


## /user/authenticate [POST]

Attempt to authenticate a user with a username and password. This will fail if the user is inactive, or if the
credentials are incorrect. This view never returns `404` so as to protect the email addresses of users.

### Inputs

- email `String`
- password `String`

### Returns

- `200` Authentication was correct. A pk and current auth token for this User is returned, which should be used in
        future requests.
        
        {
          "pk": 1,
          "authToken": "ABCDEF"
        }
        
- `401` Authentication failed. Either the email doesn't exist, or the password is incorrect.

    

## /user/create [POST]

Creates a user. The user is inactive by default and requires verification.

### Inputs

- email: `String`
- password: `String`
- timezoneName: `String`
- language: `String`
- nickname: `String`

### Returns

- `201` The User was created. The pk and verification code are returned. This verification code must be supplied to
        verify the user and make them active.
        
        {
          "pk": 1,
          "verificationCode": "abcdef"
        }
        
- `400` Creating the User failed.


## /user/regenerateToken/:pkInt [POST]

Force regeneration of a User's authToken. Current password must be supplied to authenticate this request.

### Inputs

- password `String`

### Returns

- `200` The token regeneration request was successful. Returns the new token.

        {
          "authToken": "ABCDEF"
        }

- `401` The password was incorrect.
- `404` The User was not found.


## /user/verify/:pkInt [POST]

Attempt to verify a user. Verification turns the user active.

### Inputs

- code: `String`
    
### Returns

- `204` No content. Verification succeeded.
- `400` The verification failed.
- `404` The User was not found.
