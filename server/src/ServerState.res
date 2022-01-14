module Client = {
    type t = {
        user_id: string,
        login: string,
    }
}

type t = {
    // Clients indexed by their user_id.
    clients: Js.Dict.t<Client.t>
}

let getClient = (state, user_id) => state.clients->Js.Dict.get(user_id)
