# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.0.1/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "stimulus-reveal-controller", to: "https://ga.jspm.io/npm:stimulus-reveal-controller@4.0.0/dist/stimulus-reveal-controller.es.js"
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@6.0.5/lib/assets/compiled/rails-ujs.js"
pin "tom-select", to: "https://ga.jspm.io/npm:tom-select@2.0.3/dist/js/tom-select.complete.js"
pin "stimulus-rails-nested-form", to: "https://ga.jspm.io/npm:stimulus-rails-nested-form@4.0.0/dist/stimulus-rails-nested-form.es.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.6/src/index.js"
pin "tailwindcss-stimulus-components", to: "https://ga.jspm.io/npm:tailwindcss-stimulus-components@3.0.4/dist/tailwindcss-stimulus-components.modern.js"
pin "stimulus-clipboard", to: "https://ga.jspm.io/npm:stimulus-clipboard@3.2.0/dist/stimulus-clipboard.es.js"
