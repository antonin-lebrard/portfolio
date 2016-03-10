// Copyright (c) 2015, <Antonin Lebrard>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math';

List<Element> presSections = querySelectorAll('.presSection');

bool doingScroll = false;
num startY = 0;
num curY = -1;
bool isYInit = false;

void main() {
  presSections.forEach((Element el){
    el.onTouchStart.listen((TouchEvent evt){
      if (doingScroll) return;
      startY = evt.touches[0].page.y;
      print("Start $startY");
      isYInit = true;
    });
    el.onTouchMove.listen((TouchEvent evt){
      if (doingScroll) return;
      if (!isYInit){
        startY = evt.touches[0].page.y;
        print("Move Start $startY");
        isYInit = true;
      }
      curY = evt.touches[0].page.y;
    });
    el.onTouchEnd.listen((TouchEvent evt){
      if (doingScroll) return;
      isYInit = false;
      if (curY == -1) return;
      print("End $curY");
      num delta = curY - startY;
      int curIndex = 0;
      for (int i = 0; i < presSections.length ; i++){
        if (presSections[i].id == el.id) {
          curIndex = i;
          break;
        }
      }
      if (delta < 0){
        if (curIndex == presSections.length-1) return;
        doingScroll = true;
        smoothScrolling(presSections[curIndex+1]);
      } else {
        if (curIndex == 0) return;
        doingScroll = true;
        smoothScrolling(presSections[curIndex-1]);
      }
    });
    el.onMouseWheel.listen((WheelEvent evt){
      evt.preventDefault();
      if (doingScroll) return;
      int curIndex = 0;
      for (int i = 0; i < presSections.length ; i++){
        if (presSections[i].id == el.id) {
          curIndex = i;
          break;
        }
      }
      num delta = evt.deltaY;
      if (delta > 0){
        if (curIndex == presSections.length-1) return;
        doingScroll = true;
        smoothScrolling(presSections[curIndex+1]);
      } else {
        if (curIndex == 0) return;
        doingScroll = true;
        smoothScrolling(presSections[curIndex-1]);
      }
    });
  });
}

void smoothScrolling(Element to, {int speed: 100}) {
  num targetPosition = to.offsetTop;
  num time = (window.scrollY - targetPosition).abs() / speed;
  bool isScrollingDown = (window.scrollY - targetPosition < 0);
  num currentTime = 0.0;
  num p=null, t=null, currentPosition=null;

  void animationScrollingDown(num frame){
    currentTime += 1/60;
    p = currentTime / time;
    t = ease_out_sine(p);
    currentPosition = window.scrollY + ((targetPosition - window.scrollY) * t);
    if (currentPosition >= targetPosition - 10) {
      doingScroll = false;
      window.scrollTo( 0, targetPosition );
      print("scrollDown");
    } else {
      window.scrollTo( 0, currentPosition );
      window.animationFrame.then(animationScrollingDown);
      print("scrollDown");
    }
  }

  void animationScrollingUp(num frame) {
    currentTime += 1/60;
    p = currentTime / time;
    t = ease_out_sine(p);
    currentPosition = window.scrollY + ((targetPosition - window.scrollY) * t);
    if (currentPosition <= targetPosition + 10) {
      doingScroll = false;
      window.scrollTo( 0, targetPosition );
      print("scrollUp");
    } else {
      window.scrollTo( 0, currentPosition );
      window.animationFrame.then(animationScrollingUp);
      print("scrollUp");
    }
  }
  window.animationFrame.then(isScrollingDown ? animationScrollingDown : animationScrollingUp);
}

num ease_in_out(pos){
  if ((pos /= 0.5) < 1) {
    return 0.5 * pow(pos, 5);
  }
  return 0.5 * (pow((pos - 2), 5) + 2);
}

num ease_out_sine(pos){
  return sin(pos * (PI / 2));
}