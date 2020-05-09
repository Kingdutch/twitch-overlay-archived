[@bs.scope "Math"] [@bs.val] external random: unit => float = "random";
[@bs.scope "Math"] [@bs.val] external floor: float => int = "floor";
[@bs.val] [@bs.scope "window"] external innerHeight: int = "innerHeight";
[@bs.val] [@bs.scope "window"] external innerWidth: int = "innerWidth";

let max_ripples = 10;

type rippleState = {
  opacity: float,
  transform: string,
  transition: string,
};

// Provides the idividual bubbles on the ripplescreen.
module Ripple = {
  [@react.component]
  let make = (~done_, ~x, ~y, ~startSize, ~scale, ~time) => {
    let (animationState, setAnimationState) =
      React.useState(() =>
        {opacity: 1., transform: "", transition: "initial"}
      );

    // To trigger CSS animations we need an actual state change so we wait 50ms
    // after the object has been rendered and then change its transform and
    // opacity to let CSS do the animation.
    React.useEffect1(
      () => {
        let t1 =
          Js.Global.setTimeout(
            () =>
              setAnimationState(_ =>
                {
                  opacity: 0.,
                  transform: "scale(" ++ string_of_int(scale) ++ ")",
                  transition: "all " ++ string_of_int(time) ++ "ms",
                }
              ),
            50,
          );

        // Signal done after timeout time + transition time.
        let t2 = Js.Global.setTimeout(done_, time + 50);
        Some(
          () => {
            Js.Global.clearTimeout(t1);
            Js.Global.clearTimeout(t2);
          },
        );
      },
      [|setAnimationState|],
    );

    <div
      className="absolute round pointer-ignore background-ripple"
      style={ReactDOMRe.Style.make(
        ~left=x,
        ~top=y,
        ~width=startSize,
        ~height=startSize,
        ~opacity=Js.Float.toString(animationState.opacity),
        ~transform=animationState.transform,
        ~transition=animationState.transition,
        (),
      )}
    />;
  };
};

// The state that keeps track of where all the ripples are.
type rippleChildData = {
  key: string,
  x: string,
  y: string,
  startSize: string,
  scale: int,
  time: int,
  done_: unit => unit,
};

[@react.component]
let make = () => {
  let (childData, setChildData) = React.useState(() => []);

  React.useEffect1(
    () => {
      // Add a single child to the current state if there's room.
      let attemptAddChild = child =>
        setChildData(prevChildren =>
          prevChildren->List.length < max_ripples
            ? [child, ...prevChildren] : prevChildren
        );
      // Remove a single child's props based on it's keys.
      let removeChild = fKey =>
        setChildData(prevChildren =>
          List.filter(c => c.key !== fKey, prevChildren)
        );

      let animateChildren = () => {
        // Controls chance of spawning, higher chance and larger interval for more
        // consistent ripples. Smaller chance and faster rate for more erratic.
        let shouldSpawn = random() < 0.6;

        // Spawn a new animated ripple.
        if (shouldSpawn) {
          // Where to place the drop.
          let x =
            Js.String.make(floor(random() *. float_of_int(innerWidth)));
          let y =
            Js.String.make(floor(random() *. float_of_int(innerHeight)));
          // The start and end size of the drop.
          let startSize = "1px";
          let scale = 200 + floor(random() *. 500.);
          // The time it should take a drop to reach full scale.
          // A 315px drop should take about 2s. Value in ms.
          let time = floor(2000.0 /. 315. *. float_of_int(scale));
          // Construct a key based on position. This has a high enough chance of
          // being unique.
          let key = x ++ "x" ++ y;

          attemptAddChild({
            key,
            x: x ++ "px",
            y: y ++ "px",
            startSize,
            scale,
            time,
            done_: () => removeChild(key),
          });
        };
      };

      let interval = Js.Global.setInterval(animateChildren, 800);
      Some(() => Js.Global.clearInterval(interval));
    },
    [|setChildData|],
  );

  let mapChildren = childProps =>
    <Ripple
      key={childProps.key}
      done_={childProps.done_}
      x={childProps.x}
      y={childProps.y}
      startSize={childProps.startSize}
      scale={childProps.scale}
      time={childProps.time}
    />;

  <div>
    {React.array(Array.of_list(List.map(mapChildren, childData)))}
  </div>;
};