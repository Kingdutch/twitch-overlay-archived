type twitch_config = {
  client_id: string,
  client_secret: string,
  scopes: array<string>,
  redirect_path: string
}

type t = {
  public_dir: string,
  salt: string,
  twitch: twitch_config,
}

%%raw(`
const configShape = {
  public_dir: 'string',
  salt: 'string',
  twitch: {
    client_id: 'string',
    client_secret: 'string',
    scopes: 'array',
    redirect_path: 'string',
  },
  ws_secret_viewer: 'string',
  ws_secret_admin: 'string',
}

function validateConfig(shape, config, parents = []) {
  let errors = [];
  for (const [key, type] of Object.entries(shape)) {
    const field = [...parents, key].join(".");
    if (typeof type === "string") {
      // Arrays need special handling because typeof === array doesn't work.
      if (type === 'array') {
        if (!Array.isArray(config[key]) || !config[key].length) {
          errors.push(field + " must be a non-empty array");
        }
      }
      else if (typeof config[key] !== type || !config[key].length) {
        errors.push(field + " must be a non-empty " + type);
      }
    }
    else if (typeof type === "object") {
      if (typeof config[key] !== "object" || !Object.keys(config[key]).length) {
        errors.push(field + " must be a non-empty object");
      }
      // For objects we must validate their subkeys
      else {
        errors.push(...validateConfig(shape[key], config[key], [...parents, key]));
      }
    }
    else {
      throw new Error("configShape must only contain strings and objects.");
    }
  }
  return errors;
}
`);

let assertHasShape : Js.Json.t => () = %raw(`function assertHasShape(config) {
  const configErrors = validateConfig(configShape, config);
  if (configErrors.length) {
    configErrors.forEach(error => console.error(error));
    process.exit(-1);
  }
}
`)

@module("../../config.mjs")
external config : Js.Json.t = "default"
external make : Js.Json.t => t = "%identity"
let load = () => {
  assertHasShape(config)
  make(config)
}
