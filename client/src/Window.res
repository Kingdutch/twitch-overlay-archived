module Location = {
  @scope(("window", "location")) @val
  external hash: option<string> = "hash"

  @scope(("window", "location")) @val
  external protocol : string = "protocol"

  @scope(("window", "location")) @val
  external host: string = "host"

  let getOrigin = () => `${protocol}//${host}`
}