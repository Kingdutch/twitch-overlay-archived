
type unauthenticated
type authenticated
type t<'a>

let make : (string, string) => t<unauthenticated>

let getClientId : t<'a> => string
let getClientSecret : t<'a> => string
let getToken : t<authenticated> => string

let authenticateClient : (t<unauthenticated>, string) => t<authenticated>

// let fetchStreamTitle : (t<authenticated>, string) => Promise.t<result<string, string>>