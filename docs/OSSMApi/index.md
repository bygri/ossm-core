OSSMApi runs a built-in HTTP server which allows clients to interact with the OSSM core system.

## Common return codes

All views may return the following:

- `400` Not all required input vars were provided, or those vars were invalid.
- `401` An invalid auth token was provided to a view which requires an auth token.
- `403` The authenticated user does not have access to the given view.
- `500` Unhandled server error.
