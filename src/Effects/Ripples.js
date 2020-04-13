import React, {useEffect, useState} from 'react';
import styled from 'styled-components';

const RippleContainer = styled.div`
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
`;

const MAX_RIPPLES = 10;

function Ripples() {
  const [childData, setChildData] = useState([]);

  useEffect(() => {
    // Add a single child to the current state if there's room.
    const attemptAddChild = (child) => setChildData(
      prevChildren => prevChildren.length < MAX_RIPPLES ? [...prevChildren, child] : prevChildren
    );
    // Remove a single child's props based on it's keys.
    const removeChild = (fKey) => setChildData(prevChildren => prevChildren.filter(({key}) => key !== fKey));

    const animateChildren = () => {
      // Controls chance of spawning, higher chance and larger interval for more
      // consistent ripples. Smaller chance and faster rate for more erratic.
      const shouldSpawn = Math.random() < 0.6;

      // Spawn a new animated ripple.
      if (shouldSpawn) {
        // Where to place the drop.
        const x = Math.floor(Math.random() * window.innerWidth);
        const y = Math.floor(Math.random() * window.innerHeight);
        // The start and end size of the drop.
        const startSize = '1px';
        const scale =  200 + Math.floor(Math.random() * 500);
        // The time it should take a drop to reach full scale.
        // A 315px drop should take about 2s. Value in ms.
        const time = 2000 / 315 * scale;
        // Construct a key based on position. This has a high enough chance of
        // being unique.
        const key = `${x}x${y}`;

        attemptAddChild({
          key,
          x: `${x}px`,
          y: `${y}px`,
          startSize,
          scale,
          time,
          done: () => removeChild(key)
        });
      }
    };

    const interval = setInterval(animateChildren, 800);
    return () => clearInterval(interval);
  }, [setChildData]);

  return <RippleContainer>
    {childData.map(childProps => <AnimatedRipple {...childProps} />)}
  </RippleContainer>;
}

export default Ripples;

const Ripple = styled.div`
  position: absolute;
  left: ${({x}) => x};
  top: ${({y}) => y};
  
  border-radius: 50%;
  width: ${({size}) => size};
  height: ${({size}) => size};
  pointer-events: none;

  opacity: ${({opacity}) => opacity};
  transform: ${({transform}) => transform};
  transition: ${({transition}) => transition};
  
  background-color: rgba(0, 0, 0, 0.3);
`;

function AnimatedRipple({done, x, y, startSize, scale, time}) {
  const [animationState, setAnimationState] = useState({
    opacity: 1,
    transform: '',
    transition: 'initial',
  });

  useEffect(() => {
    const t1 = setTimeout(
      () => setAnimationState({
        opacity: 0,
        transform: `scale(${scale})`,
        transition: `all ${time}ms`,
      }),
      50
    );

    // Signal done after timeout time + transition time.
    const t2 = setTimeout(done, time + 50);

    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
    }
  }, [setAnimationState]);

  return <Ripple x={x} y={y} size={startSize} {...animationState} />
}