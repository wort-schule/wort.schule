# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "stimulus-reveal-controller", to: "stimulus-reveal-controller.js"
pin "tom-select", to: "tom-select.js"
pin "@rails/request.js", to: "@rails--request.js"
pin "tailwindcss-stimulus-components", to: "tailwindcss-stimulus-components.js"
pin "stimulus-clipboard", to: "stimulus-clipboard.js"
pin "@codemirror/state", to: "@codemirror--state.js"
pin "@codemirror/view", to: "@codemirror--view.js"
pin "style-mod", to: "style-mod.js"
pin "w3c-keyname", to: "w3c-keyname.js"
pin "@codemirror/commands", to: "@codemirror--commands.js"
pin "@codemirror/language", to: "@codemirror--language.js"
pin "@lezer/common", to: "@lezer--common.js"
pin "@lezer/highlight", to: "@lezer--highlight.js"
pin "@codemirror/lang-html", to: "@codemirror--lang-html.js"
pin "@codemirror/autocomplete", to: "@codemirror--autocomplete.js"
pin "@codemirror/lang-css", to: "@codemirror--lang-css.js"
pin "@codemirror/lang-javascript", to: "@codemirror--lang-javascript.js"
pin "@lezer/css", to: "@lezer--css.js"
pin "@lezer/html", to: "@lezer--html.js"
pin "@lezer/javascript", to: "@lezer--javascript.js"
pin "@lezer/lr", to: "@lezer--lr.js"
