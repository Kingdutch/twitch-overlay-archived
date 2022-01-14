@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path {
    | list{} => <PageIndex />
    | list{"viewer", viewerCode} => <PageViewer viewerCode />
    | _ => <PageNotFound/>
  }
}