# Vim to Emacs

https://vim-to-emacs.netlify.app/

Vim to Emacs migration made easy


## Run locally

```
elm reactor
```

## Tests

```
elm-test
```

## Deployment

This site is deployed via netlify.app, see the running instance here -
https://vim-to-emacs.netlify.app/ . There is a small
[issue][netlify-elm-version-issue] with Elm version mismatch, we used
[this workaround][netlify-elm-version-workaround] to solve it, i.e. the build
command is now

```bash
npm i -g elm@latest-0.19.1 && elm make src/Main.elm
```

See the deployment configuration here

https://app.netlify.com/sites/vim-to-emacs/settings/deploys


[netlify-elm-version-issue]: https://github.com/netlify/build-image/issues/464
[netlify-elm-version-workaround]: https://github.com/simonpweller/todomvc-elm/commit/7c543c0cfbc9076bae7c86909ad40f67742fd391
