type oauthToken = {
  accessToken: string,
  refreshToken: string,
  expiresIn: int,
  scope: array<string>,
  tokenType: string,
}

module Client = {
    type t = {
        user_id: string,
        login: string,
        token: oauthToken
    }
}

type t = {
    // Clients indexed by their user_id.
    clients: Js.Dict.t<Client.t>
}

let make = () => ({
    clients: Js.Dict.empty()
})

let addClient = (state, user_id, login, token) => {
    state.clients->Js.Dict.set(
        user_id,
        {
            user_id,
            login,
            token
        } 
    )
}
let getClient = (state, user_id) => state.clients->Js.Dict.get(user_id)
