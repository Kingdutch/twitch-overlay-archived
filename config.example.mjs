export default {
  // The directory into which bundles are compiled.
  public_dir: __dirname + "/dist/",
  // A salt that can be used for hashing passwords.
  salt: "ChangeMe",
  // The details needed to connect to Twitch.
 twitch: {
   client_id: '',
   client_secret: '',
   scopes: [],
   redirect_path: "/oauth2/complete",
 },
 // The secret used for a viewer to authenticate themselves.
 'ws_secret_viewer': 'secret1',
 // The secret used for an admin to authenticate themselves.
 'ws_secret_admin': 'secret2',
};
