@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path {
    | list{} => <PageIndex />
    | list{"controller"} => <PageController /> 
    | list{"viewer", viewerCode} => <PageViewer viewerCode />
    | _ => <PageNotFound/>
  }
}