# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.0.1/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "stimulus-reveal-controller", to: "https://ga.jspm.io/npm:stimulus-reveal-controller@4.0.0/dist/stimulus-reveal-controller.es.js"
pin "tom-select", to: "https://ga.jspm.io/npm:tom-select@2.0.3/dist/js/tom-select.complete.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.6/src/index.js"
pin "tailwindcss-stimulus-components", to: "https://ga.jspm.io/npm:tailwindcss-stimulus-components@3.0.4/dist/tailwindcss-stimulus-components.modern.js"
pin "stimulus-clipboard", to: "https://ga.jspm.io/npm:stimulus-clipboard@3.2.0/dist/stimulus-clipboard.es.js"
pin "@codemirror/state", to: "https://ga.jspm.io/npm:@codemirror/state@6.1.3/dist/index.js"
pin "@codemirror/view", to: "https://ga.jspm.io/npm:@codemirror/view@6.4.2/dist/index.js"
pin "style-mod", to: "https://ga.jspm.io/npm:style-mod@4.0.0/src/style-mod.js"
pin "w3c-keyname", to: "https://ga.jspm.io/npm:w3c-keyname@2.2.6/index.es.js"
pin "@codemirror/commands", to: "https://ga.jspm.io/npm:@codemirror/commands@6.1.2/dist/index.js"
pin "@codemirror/language", to: "https://ga.jspm.io/npm:@codemirror/language@6.3.0/dist/index.js"
pin "@lezer/common", to: "https://ga.jspm.io/npm:@lezer/common@1.0.1/dist/index.js"
pin "@lezer/highlight", to: "https://ga.jspm.io/npm:@lezer/highlight@1.1.2/dist/index.js"
pin "@codemirror/lang-html", to: "https://ga.jspm.io/npm:@codemirror/lang-html@6.1.3/dist/index.js"
pin "@codemirror/autocomplete", to: "https://ga.jspm.io/npm:@codemirror/autocomplete@6.3.0/dist/index.js"
pin "@codemirror/lang-css", to: "https://ga.jspm.io/npm:@codemirror/lang-css@6.0.1/dist/index.js"
pin "@codemirror/lang-javascript", to: "https://ga.jspm.io/npm:@codemirror/lang-javascript@6.1.1/dist/index.js"
pin "@lezer/css", to: "https://ga.jspm.io/npm:@lezer/css@1.0.1/dist/index.es.js"
pin "@lezer/html", to: "https://ga.jspm.io/npm:@lezer/html@1.0.1/dist/index.es.js"
pin "@lezer/javascript", to: "https://ga.jspm.io/npm:@lezer/javascript@1.0.2/dist/index.es.js"
pin "@lezer/lr", to: "https://ga.jspm.io/npm:@lezer/lr@1.2.4/dist/index.js"
