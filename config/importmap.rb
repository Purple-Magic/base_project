# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@tramway/tramway-select", to: "tramway/tramway-select_controller.js"
pin "@tramway/table-row-preview", to: "tramway/table_row_preview_controller.js"
pin "@tailwindcss/forms", to: "tailwindcss/forms.js"
pin "@tailwindcss/typography", to: "tailwindcss/typography.js"
pin "@tailwindcss/aspect-ratio", to: "tailwindcss/aspect-ratio.js"
pin "@tailwindcss/container-queries", to: "tailwindcss/container-queries.js"
pin "tailwindcss-animate", to: "tailwindcss-animate.js"
