// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import { Navbar, TramwaySelect, TableRowPreview, UiCheckbox, Tooltip } from "@tramway/tramway"
eagerLoadControllersFrom("controllers", application)
application.register('tramway-navbar', Navbar)
application.register('tramway-select', TramwaySelect)
application.register('table-row-preview', TableRowPreview)
application.register('ui--checkbox', UiCheckbox)
application.register('tramway-tooltip', Tooltip)
