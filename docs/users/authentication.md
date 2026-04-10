# Authentication

Users can sign in with Auth0 from the main navigation using the `Login` button.

After a successful sign-in, the app opens the profile page at `/user`. This page shows the basic identity details returned by Auth0, such as the user name, nickname, email address, and the raw profile payload stored in the session.

Users can sign out with the `Logout` button in the top navigation area. Signing out clears the local session and returns the browser through Auth0's logout flow back to the home page.

For local development, Auth0 must allow these URLs in the application settings:

- Callback URL: `http://localhost:3000/auth/auth0/callback`
- Logout URL: `http://localhost:3000`
