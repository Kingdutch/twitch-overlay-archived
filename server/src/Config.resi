type twitch_config = {
  client_id: string,
  client_secret: string,
  scopes: array<string>,
}

type t = {
  public_dir: string,
  salt: string,
  twitch: twitch_config,
}

let load : () => t;
