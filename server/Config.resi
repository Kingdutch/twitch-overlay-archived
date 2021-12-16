type twitch_config = {
  client_id: string,
  client_secret: string,
  scopes: array<string>,
  redirect_path: string
}

type t = {
  salt: string,
  twitch: twitch_config,
}

let load : () => t;
