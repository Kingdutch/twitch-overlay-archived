module Url = {
  type t

  @new external make : (string, string) => t = "URL"; 

  @send @scope("searchParams")
  external searchParamsAppend : (t, string, string) => () = "append"
  @send @scope("searchParams")
  external searchParamsHas : (t, string) => bool = "has"
  @send @scope("searchParams")
  external searchParamsUnsafeget : (t, string) => string = "get"
  let searchParamsGet = (url, param) => {
    switch (url->searchParamsHas(param)) {
      | false => None
      | true => Some(url->searchParamsUnsafeget(param))
    }
  }

  @bs.get external pathname : t => string = "pathname"

  @send external toString : t => string = "toString"
}