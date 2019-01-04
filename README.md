# Elm (0.19) Example

## Getting Started

```
npm install
elm reactor
```

Assuming that succeeded ... open your browser to http://localhost:8000/src/Main.elm.

That's it.

## Key Decoding


### Background

I ran onto this while doing the upgrade of the application, I noticed the following value defined in our `Msg` Custom Type:

```
~~~
     KeyMsg Keyboard.KeyCode
~~~
```

The `Keyboard` module is no longer part of the Elm core libraries. I was going to need to manually tweak this.

What was `Keyboard`?

> Keyboard
>
> This library lets you listen to global keyboard events.

source: https://package.elm-lang.org/packages/elm-lang/keyboard/1.0.1/Keyboard

And it turns out [the `KeyCode` was really just an alias to `Int`](https://package.elm-lang.org/packages/elm-lang/keyboard/1.0.1/Keyboard#KeyCode
), the integer representation for the key provided in the keyboard event.

Because Elm is awesome, and thorough, I know that `KeyMsg Keyboard.KeyCode` has to be handled in the `update` function for the application:

```elm
        KeyMsg keyCode ->
            if keyCode == 27 then
                update (CloseDialog NoOp) model

            else
                ( model, Cmd.none )
```

I'm upgrading to 0.19 in January 2019, I know I'm late to the party, so I looked in the Elm Discourse to see if there was any chatter about the topic:

https://discourse.elm-lang.org/search?q=Keyboard

There was a few mentions (circa 2019-01-03), but nothing quite what I was looking for. However, there was information on where keyboard input functionality moved.

The events around keyboard input have moved into `Browser.Events`, and the `Browser` modules documentation had some greatly helpful notes:

- https://github.com/elm/browser/blob/50095262bd4e1202b3f3bfe093d707fc078d9db7/notes/keyboard.md

I knew that `keyCode == 27` was an attempt to trap the <kbd>ESC</kbd> key and close an open dialog. The notes had some links over to [MDN about Modifier keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Modifier_keys) (note: "Escape" is defined as part of [UI Keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#UI_keys))

I really liked one of the examples that MDN provided where you could see the key and code for live keyboard events:

- https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code#Exercising_KeyboardEvent

The _notes_ from `elm/browser` give you the types and functions for decoding keys:

- https://github.com/elm/browser/blob/50095262bd4e1202b3f3bfe093d707fc078d9db7/notes/keyboard.md#decoding-for-user-input

But I was still puzzling over how the application I was upgrading had _"hooked"_ into the global keyboard events in the first place to produce `KeyMsg Keyboard.KeyCode` so that it would be handled in the `update` function. I wasn't sure I could do keyboard events in Ellie, so I thought putting together a [Short, Self Contained, Correct (Compilable), Example](http://sscce.org/) would either lead to me understanding how to fix it, or put me in a position to ask for help.

I thought doing a [SSCCE](http://sscce.org/) mimicking the [MDN keyboard event example](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code#Exercising_KeyboardEvent) would be a good approach.

I've been working on a large-ish Elm application that is hosted within an ASP.NET MVC (legacy) application not for 9-10 months. I was comfortable within the application, but I hadn't done all the normal bootstrapped learning via `reactor` and `elm-live`, or did simple examples in Ellie. I was still not comfortable with `Navigation.programWithFlags` (or even the `beginnerProgram` variations), plus - these are different in Elm 0.19. My first misstep that created me writing this as an `elm reactor` app was that I thought Ellie wouldn't allow _subscriptions_ (I'll get back to that). One way to harvest Elm examples is to search GitHub using the Advanced Search option. I knew I wanted to find an example that was using [`onKeyPress`](https://package.elm-lang.org/packages/elm/browser/1.0.1/Browser-Events#onKeyPress) (from [`Browser.Events`](https://package.elm-lang.org/packages/elm/browser/1.0.1/Browser-Events)). Thanks to @mi-lee for having their [VIM Adventures ported](https://github.com/mi-lee/vim-adventures-in-elm/blob/ef21adf45a07637faefbbf9cc216c6c6018a8ea1/src/Main.elm#L727-L731).

## Lessons

### Lesson 1 - If you want modifier keys, you want `onKeyDown`

I originally did this with `onKeyPress` and noticed that only the alphanumeric keys were triggering `Msg`s. I was puzzled. I went back to the documentation and was pleased by what was mentioned:

> Subscribe to key presses that normally produce characters. So you should not rely on this for arrow keys.

source: https://package.elm-lang.org/packages/elm/browser/1.0.1/Browser-Events#onKeyPress

I was not working with arrow keys, but I was looking at Modifier keys, which I have as `Control String` in the decoding functions. If you switch to `onKeyDown`, as done in this example, you will see both _characters_ and modifier keys.

### Lesson 2 - Don't just check your `Msg`s being _handled_, look for where they are emitted

I am not sure if "emitting" is the right verb for when you create a `Msg` value to be handled by `update`. But, I made a classic mistake in that I found the code mentioned in "Background" where it was defined and, thus, **handled** in `update`. I never found where it was being "emitted", or "produced". I had imagined that there was a _global_ hook or flag passed into the _now-moved_ `Navigation.programWithFlags` function. I went and re-tested the Elm 0.18 version of application and found that the keyCode was not being trapped and handled. It appears to be that it is **never** emitted/produced (ugh, don't know which _term_ I like for that).

So the lesson? Look for: 1) see what `Msg`s are defined, 2) inspect how the `Msg` is handled, 3) look for where a `Msg` is _emitted_.

### Lesson 3 - I know how to do define `subscriptions` now

It was I was going to "find" where `KeyMsg Keyboard.KeyCode` was emitted it would have been in a `subscription` that uses [`presses`](https://package.elm-lang.org/packages/elm-lang/keyboard/1.0.1/Keyboard#presses), [`downs`](https://package.elm-lang.org/packages/elm-lang/keyboard/1.0.1/Keyboard#downs), or [`ups`](https://package.elm-lang.org/packages/elm-lang/keyboard/1.0.1/Keyboard#ups). I had not really done anything with `Sub Msg` or `Sub.batch`, so that was a _learning_.
